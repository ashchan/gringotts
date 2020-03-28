#include "ckb_syscalls.h"
#include "blockchain.h"
#include "ckb_dlfcn.h"

/*
 * TODO: generate hash in build step
 */
static uint8_t SECP_BINARY_HASH[32] = {
  0xd2, 0xc5, 0xbe, 0x3b, 0xd1, 0xf3, 0x18, 0xa8,
  0x92, 0x4c, 0x65, 0x49, 0x75, 0x47, 0xe8, 0x80,
  0x5e, 0x25, 0xe7, 0xc9, 0xa7, 0x05, 0x65, 0x56,
  0x2c, 0xa7, 0xe2, 0x4d, 0xc3, 0x22, 0xfd, 0x85
};

#define ERROR_ARGUMENTS_LEN -1
#define ERROR_ENCODING -2
#define ERROR_SYSCALL -3
#define ERROR_SCRIPT_TOO_LONG -21
#define ERROR_PUBKEY_BLAKE160_HASH -31

#define BLAKE2B_BLOCK_SIZE 32
#define BLAKE160_SIZE 20
#define PUBKEY_SIZE 33
#define RECID_INDEX 64
/* 32 KB */
#define MAX_WITNESS_SIZE 32768
#define SCRIPT_SIZE 32768
#define SIGNATURE_SIZE 65
#define ERROR_DYNAMIC_LOADING -103

typedef unsigned __int128 uint128_t;

int main() {
  int ret;
  uint64_t len = 0;

  /* Load args */
  unsigned char script[SCRIPT_SIZE];
  len = SCRIPT_SIZE;
  ret = ckb_load_script(script, &len, 0);
  if (ret != CKB_SUCCESS) {
    return ERROR_SYSCALL;
  }
  if (len > SCRIPT_SIZE) {
    return ERROR_SCRIPT_TOO_LONG;
  }
  mol_seg_t script_seg;
  script_seg.ptr = (uint8_t *)script;
  script_seg.size = len;

  if (MolReader_Script_verify(&script_seg, false) != MOL_OK) {
    return ERROR_ENCODING;
  }

  mol_seg_t code_hash_seg = MolReader_Script_get_code_hash(&script_seg);
  mol_seg_t hash_type_seg = MolReader_Script_get_hash_type(&script_seg);

  mol_seg_t args_seg = MolReader_Script_get_args(&script_seg);
  mol_seg_t args_bytes_seg = MolReader_Bytes_raw_bytes(&args_seg);
  if (args_bytes_seg.size != 104) {
    return ERROR_ARGUMENTS_LEN;
  }

  uint8_t public_key_hash[BLAKE160_SIZE];
  uint8_t secp_code_buffer[100 * 1024] __attribute__((aligned(RISCV_PGSIZE)));
  uint8_t *aligned_code_start = secp_code_buffer;
  size_t aligned_size = ROUNDDOWN(100 * 1024, RISCV_PGSIZE);

  void *handle = NULL;
  uint64_t consumed_size = 0;
  ret = ckb_dlopen(SECP_BINARY_HASH, aligned_code_start,
                       aligned_size, &handle, &consumed_size);
  if (ret != CKB_SUCCESS) {
    return ret;
  }
  int (*verify_func)(uint8_t*);
  *(void **)(&verify_func) =
      ckb_dlsym(handle, "validate_secp256k1_blake2b_sighash_all");
  if (verify_func == NULL) {
    return ERROR_DYNAMIC_LOADING;
  }
  ret = verify_func(public_key_hash);
  if (ret != CKB_SUCCESS) {
    return ret;
  }

  if (memcmp(args_bytes_seg.ptr, public_key_hash, BLAKE160_SIZE) == 0) {
    /*
     * HOLDER pubkey hash, ensure that the cell is overdue:
     * last_payment_time + lease_period + overdue_period < tip_number
     * Since value for current cell should be used to store tip_number.
     */
    uint64_t lease_period = *((uint64_t*) (&args_bytes_seg.ptr[72]));
    uint64_t overdue_period = *((uint64_t*) (&args_bytes_seg.ptr[80]));
    uint64_t last_payment_time = *((uint64_t*) (&args_bytes_seg.ptr[88]));

    uint64_t since = 0;
    len = 8;
    ret = ckb_load_input_by_field((uint8_t*) &since, &len, 0, 0,
                                  CKB_SOURCE_GROUP_INPUT, CKB_INPUT_FIELD_SINCE);
    if (ret != CKB_SUCCESS) {
      return ret;
    }
    if (since >> 56 != 0) {
      return -99;
    }
    if (lease_period + overdue_period + last_payment_time >= since) {
      return -100;
    }
    ckb_debug("Claim success");
    return 0;
  } else if (memcmp(&args_bytes_seg.ptr[BLAKE160_SIZE], public_key_hash, BLAKE160_SIZE) == 0) {
    /* BUILDER pubkey hash, check change_data or pay logic */
    size_t i = 0;
    unsigned char output_script[SCRIPT_SIZE];
    mol_seg_t output_script_seg;
    size_t matched_index = SIZE_MAX;
    while (1) {
      len = SCRIPT_SIZE;
      ret = ckb_load_cell_by_field(output_script, &len, 0, i, CKB_SOURCE_OUTPUT,
                                   CKB_CELL_FIELD_LOCK);
      if (ret != CKB_SUCCESS) {
        return ret;
      }
      i++;
      output_script_seg.ptr = output_script;
      output_script_seg.size = len;

      if (MolReader_Script_verify(&output_script_seg, false) != MOL_OK) {
        return ERROR_ENCODING;
      }
      mol_seg_t output_code_hash_seg = MolReader_Script_get_code_hash(&output_script_seg);
      mol_seg_t output_hash_type_seg = MolReader_Script_get_hash_type(&output_script_seg);

      if ((memcmp(code_hash_seg.ptr, output_code_hash_seg.ptr, 32) == 0) &&
          (output_hash_type_seg.ptr[0] == hash_type_seg.ptr[0])) {
        matched_index = i - 1;
        break;
      }
    }
    while (1) {
      unsigned char temp_script[SCRIPT_SIZE];
      len = SCRIPT_SIZE;
      ret = ckb_load_cell_by_field(temp_script, &len, 0, i, CKB_SOURCE_OUTPUT,
                                   CKB_CELL_FIELD_LOCK);
      if (ret == CKB_INDEX_OUT_OF_BOUND) {
        break;
      }
      if (ret != CKB_SUCCESS) {
        return ret;
      }
      i++;
      mol_seg_t temp_script_seg;
      temp_script_seg.ptr = temp_script;
      temp_script_seg.size = len;

      if (MolReader_Script_verify(&temp_script_seg, false) != MOL_OK) {
        return ERROR_ENCODING;
      }
      mol_seg_t temp_code_hash_seg = MolReader_Script_get_code_hash(&temp_script_seg);
      mol_seg_t temp_hash_type_seg = MolReader_Script_get_hash_type(&temp_script_seg);

      if ((memcmp(code_hash_seg.ptr, temp_code_hash_seg.ptr, 32) == 0) &&
          (temp_hash_type_seg.ptr[0] == hash_type_seg.ptr[0])) {
        // 2 lease cells in one transaction, for simplicity, we reject it here.
        return -101;
      }
    }

    /*
     * First, ensures that the same capacity and type script are used
     * for the input and output cells.
     */
    uint64_t input_capacity = 0, output_capacity = 0;
    len = 8;
    ret = ckb_load_cell_by_field((uint8_t*) &input_capacity, &len, 0, 0,
                                 CKB_SOURCE_GROUP_INPUT, CKB_CELL_FIELD_CAPACITY);
    if (ret != CKB_SUCCESS) {
      return ret;
    }
    len = 8;
    ret = ckb_load_cell_by_field((uint8_t*) &output_capacity, &len, 0, matched_index,
                                 CKB_SOURCE_OUTPUT, CKB_CELL_FIELD_CAPACITY);
    if (ret != CKB_SUCCESS) {
      return ret;
    }
    if (input_capacity != output_capacity) {
      return -102;
    }
    unsigned char input_type_hash[32];
    int has_input_type = 0;
    len = 32;
    ret = ckb_load_cell_by_field(input_type_hash, &len, 0, 0,
                                 CKB_SOURCE_GROUP_INPUT, CKB_CELL_FIELD_TYPE_HASH);
    if (ret != CKB_ITEM_MISSING && ret != CKB_SUCCESS) {
      return ret;
    }
    has_input_type = ret == CKB_SUCCESS;
    unsigned char output_type_hash[32];
    int has_output_type = 0;
    len = 32;
    ret = ckb_load_cell_by_field(output_type_hash, &len, 0, matched_index,
                                 CKB_SOURCE_OUTPUT, CKB_CELL_FIELD_TYPE_HASH);
    if (ret != CKB_ITEM_MISSING && ret != CKB_SUCCESS) {
      return ret;
    }
    has_output_type = ret == CKB_SUCCESS;
    if (has_input_type != has_output_type) {
      return -103;
    }
    if (has_input_type) {
      if (memcmp(input_type_hash, output_type_hash, 32) != 0) {
        return -104;
      }
    }

    mol_seg_t output_args_seg = MolReader_Script_get_args(&output_script_seg);
    mol_seg_t output_args_bytes_seg = MolReader_Bytes_raw_bytes(&output_args_seg);
    if (output_args_bytes_seg.size != 104) {
      return ERROR_ARGUMENTS_LEN;
    }
    if (memcmp(output_args_bytes_seg.ptr, args_bytes_seg.ptr, 104) == 0) {
      /*
       * Change data, no additional logic is required in the checking.
       */
      ckb_debug("Change data success");
    } else {
      /*
       * Pay, ensures that only last_payment_time is updated, and it is updated
       * to the correct value
       */
      if (memcmp(output_args_bytes_seg.ptr, args_bytes_seg.ptr, 88) != 0) {
        return -105;
      }
      if (memcmp(&output_args_bytes_seg.ptr[96], &args_bytes_seg.ptr[96], 8) != 0) {
        return -106;
      }
      /*
       * Ensures last_payment_time is set to the same as since value in the
       * input cell.
       */
      uint64_t last_payment_time = *((uint64_t*) (&output_args_bytes_seg.ptr[88]));
      uint64_t since = 0;
      len = 8;
      ret = ckb_load_input_by_field((uint8_t*) &since, &len, 0, 0,
                                    CKB_SOURCE_GROUP_INPUT, CKB_INPUT_FIELD_SINCE);
      if (ret != CKB_SUCCESS) {
        return ret;
      }
      if (since >> 56 != 0) {
        return -107;
      }
      if (since != last_payment_time) {
        return -108;
      }
      /*
       * Check that correct amount has been paid to the holder.
       */
      uint64_t amount_per_period = *((uint64_t*) (&args_bytes_seg.ptr[96]));
      const uint8_t *coin_hash = &args_bytes_seg.ptr[40];
      int pay_udt = 0;
      for (int j = 0; j < 32; j++) {
        if (coin_hash[j] > 0) {
          pay_udt = 1;
          break;
        }
      }
      i = 0;
      while (1) {
        unsigned char temp_script[SCRIPT_SIZE];
        len = SCRIPT_SIZE;
        ret = ckb_load_cell_by_field(temp_script, &len, 0, i, CKB_SOURCE_OUTPUT,
                                     CKB_CELL_FIELD_LOCK);
        if (ret != CKB_SUCCESS) {
          return ret;
        }
        mol_seg_t temp_script_seg;
        temp_script_seg.ptr = temp_script;
        temp_script_seg.size = len;

        if (MolReader_Script_verify(&temp_script_seg, false) != MOL_OK) {
          return ERROR_ENCODING;
        }
        mol_seg_t temp_code_hash_seg = MolReader_Script_get_code_hash(&temp_script_seg);
        mol_seg_t temp_hash_type_seg = MolReader_Script_get_hash_type(&temp_script_seg);
        mol_seg_t temp_args_seg = MolReader_Script_get_args(&temp_script_seg);
        mol_seg_t temp_args_bytes_seg = MolReader_Bytes_raw_bytes(&temp_args_seg);

        const char DEFAULT_LOCK[32] = {
          0x9b, 0xd7, 0xe0, 0x6f, 0x3e, 0xcf, 0x4b, 0xe0,
          0xf2, 0xfc, 0xd2, 0x18, 0x8b, 0x23, 0xf1, 0xb9,
          0xfc, 0xc8, 0x8e, 0x5d, 0x4b, 0x65, 0xa8, 0x63,
          0x7b, 0x17, 0x72, 0x3b, 0xbd, 0xa3, 0xcc, 0xe8
        };
        if ((memcmp(temp_code_hash_seg.ptr, DEFAULT_LOCK, 32) == 0) &&
            (temp_hash_type_seg.ptr[0] == 1) &&
            (temp_args_bytes_seg.size == 20) &&
            (memcmp(temp_args_bytes_seg.ptr, output_args_bytes_seg.ptr, 20) == 0)) {
          if (pay_udt) {
            /* Check UDT type hash as well */
            unsigned char type_hash[32];
            len = 32;
            ret = ckb_load_cell_by_field(type_hash, &len, 0, i, CKB_SOURCE_OUTPUT,
                                         CKB_CELL_FIELD_TYPE_HASH);
            if (ret == CKB_SUCCESS && len == 32) {
              if (memcmp(type_hash, coin_hash, 32) == 0) {
                break;
              }
            }
          } else {
            break;
          }
        }
        i++;
      }
      uint64_t pay_amount = 0;
      if (pay_udt) {
        uint128_t udt_amount = 0;
        len = 16;
        ret = ckb_load_cell_data((uint8_t *)&udt_amount, &len, 0, i,
                                 CKB_SOURCE_OUTPUT);
        if (ret != CKB_SUCCESS) {
          return ret;
        }
        if (len != 16) {
          return -109;
        }
        if (udt_amount > UINT64_MAX) {
          return -110;
        }
        pay_amount = (uint64_t) udt_amount;
      } else {
        len = 8;
        ret = ckb_load_cell_by_field((uint8_t*) &pay_amount, &len, 0, i,
                                     CKB_SOURCE_OUTPUT, CKB_CELL_FIELD_CAPACITY);
        if (ret != CKB_SUCCESS) {
          return ret;
        }
        if (len != 8) {
          return -111;
        }
      }
      if (pay_amount != amount_per_period) {
        return -112;
      }
      ckb_debug("Pay success");
    }
    return 0;
  } else {
    return ERROR_PUBKEY_BLAKE160_HASH;
  }
}
