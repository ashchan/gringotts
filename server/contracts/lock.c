#include "blake2b.h"
#include "ckb_syscalls.h"
#include "common.h"
#include "blockchain.h"
#include "secp256k1_helper.h"

#define BLAKE2B_BLOCK_SIZE 32
#define BLAKE160_SIZE 20
#define PUBKEY_SIZE 33
#define TEMP_SIZE 32768
#define RECID_INDEX 64
/* 32 KB */
#define MAX_WITNESS_SIZE 32768
#define SCRIPT_SIZE 32768
#define SIGNATURE_SIZE 65

#if (MAX_WITNESS_SIZE > TEMP_SIZE) || (SCRIPT_SIZE > TEMP_SIZE)
#error "Temp buffer is not big enough!"
#endif

/*
 * Arguments:
 * pubkey blake160 hash, blake2b hash of pubkey first 20 bytes, used to
 * shield the real pubkey.
 *
 * Witness:
 * WitnessArgs with a signature in lock field used to present ownership.
 */
int main() {
  int ret;
  uint64_t len = 0;
  unsigned char temp[TEMP_SIZE];
  unsigned char lock_bytes[SIGNATURE_SIZE];

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

  /* Load witness of first input */
  uint64_t witness_len = MAX_WITNESS_SIZE;
  ret = ckb_load_witness(temp, &witness_len, 0, 0, CKB_SOURCE_GROUP_INPUT);
  if (ret != CKB_SUCCESS) {
    return ERROR_SYSCALL;
  }

  if (witness_len > MAX_WITNESS_SIZE) {
    return ERROR_WITNESS_SIZE;
  }

  /* load signature */
  mol_seg_t lock_bytes_seg;
  ret = extract_witness_lock(temp, witness_len, &lock_bytes_seg);
  if (ret != 0) {
    return ERROR_ENCODING;
  }

  if (lock_bytes_seg.size != SIGNATURE_SIZE) {
    return ERROR_ARGUMENTS_LEN;
  }
  memcpy(lock_bytes, lock_bytes_seg.ptr, lock_bytes_seg.size);

  /* Load tx hash */
  unsigned char tx_hash[BLAKE2B_BLOCK_SIZE];
  len = BLAKE2B_BLOCK_SIZE;
  ret = ckb_load_tx_hash(tx_hash, &len, 0);
  if (ret != CKB_SUCCESS) {
    return ret;
  }
  if (len != BLAKE2B_BLOCK_SIZE) {
    return ERROR_SYSCALL;
  }

  /* Prepare sign message */
  unsigned char message[BLAKE2B_BLOCK_SIZE];
  blake2b_state blake2b_ctx;
  blake2b_init(&blake2b_ctx, BLAKE2B_BLOCK_SIZE);
  blake2b_update(&blake2b_ctx, tx_hash, BLAKE2B_BLOCK_SIZE);

  /* Clear lock field to zero, then digest the first witness */
  memset((void *)lock_bytes_seg.ptr, 0, lock_bytes_seg.size);
  blake2b_update(&blake2b_ctx, (char *)&witness_len, sizeof(uint64_t));
  blake2b_update(&blake2b_ctx, temp, witness_len);

  /* Digest same group witnesses */
  size_t i = 1;
  while (1) {
    len = MAX_WITNESS_SIZE;
    ret = ckb_load_witness(temp, &len, 0, i, CKB_SOURCE_GROUP_INPUT);
    if (ret == CKB_INDEX_OUT_OF_BOUND) {
      break;
    }
    if (ret != CKB_SUCCESS) {
      return ERROR_SYSCALL;
    }
    if (len > MAX_WITNESS_SIZE) {
      return ERROR_WITNESS_SIZE;
    }
    blake2b_update(&blake2b_ctx, (char *)&len, sizeof(uint64_t));
    blake2b_update(&blake2b_ctx, temp, len);
    i += 1;
  }
  /* Digest witnesses that not covered by inputs */
  i = calculate_inputs_len();
  while (1) {
    len = MAX_WITNESS_SIZE;
    ret = ckb_load_witness(temp, &len, 0, i, CKB_SOURCE_INPUT);
    if (ret == CKB_INDEX_OUT_OF_BOUND) {
      break;
    }
    if (ret != CKB_SUCCESS) {
      return ERROR_SYSCALL;
    }
    if (len > MAX_WITNESS_SIZE) {
      return ERROR_WITNESS_SIZE;
    }
    blake2b_update(&blake2b_ctx, (char *)&len, sizeof(uint64_t));
    blake2b_update(&blake2b_ctx, temp, len);
    i += 1;
  }
  blake2b_final(&blake2b_ctx, message, BLAKE2B_BLOCK_SIZE);

  /* Load signature */
  secp256k1_context context;
  uint8_t secp_data[CKB_SECP256K1_DATA_SIZE];
  ret = ckb_secp256k1_custom_verify_only_initialize(&context, secp_data);
  if (ret != 0) {
    return ret;
  }

  secp256k1_ecdsa_recoverable_signature signature;
  if (secp256k1_ecdsa_recoverable_signature_parse_compact(
          &context, &signature, lock_bytes, lock_bytes[RECID_INDEX]) == 0) {
    return ERROR_SECP_PARSE_SIGNATURE;
  }

  /* Recover pubkey */
  secp256k1_pubkey pubkey;
  if (secp256k1_ecdsa_recover(&context, &pubkey, &signature, message) != 1) {
    return ERROR_SECP_RECOVER_PUBKEY;
  }

  /* Check pubkey hash */
  size_t pubkey_size = PUBKEY_SIZE;
  if (secp256k1_ec_pubkey_serialize(&context, temp, &pubkey_size, &pubkey,
                                    SECP256K1_EC_COMPRESSED) != 1) {
    return ERROR_SECP_SERIALIZE_PUBKEY;
  }

  blake2b_init(&blake2b_ctx, BLAKE2B_BLOCK_SIZE);
  blake2b_update(&blake2b_ctx, temp, pubkey_size);
  blake2b_final(&blake2b_ctx, temp, BLAKE2B_BLOCK_SIZE);

  if (memcmp(args_bytes_seg.ptr, temp, BLAKE160_SIZE) == 0) {
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
  } else if (memcmp(&args_bytes_seg.ptr[BLAKE160_SIZE], temp, BLAKE160_SIZE) == 0) {
    /* BUILDER pubkey hash, check change_data or pay logic */
    i = 0;
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
    ret = ckb_load_cell_by_field(output_type_hash, &len, 0, 0,
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
       * TODO: check that correct amount has been paid to the holder
       */
      uint64_t amount_per_period = *((uint64_t*) (&args_bytes_seg.ptr[96]));
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
          break;
        }
        i++;
      }
      uint64_t pay_capacity = 0;
      len = 8;
      ret = ckb_load_cell_by_field((uint8_t*) &pay_capacity, &len, 0, i,
                                   CKB_SOURCE_OUTPUT, CKB_CELL_FIELD_CAPACITY);
      if (ret != CKB_SUCCESS) {
        return ret;
      }
      if (pay_capacity != amount_per_period) {
        return -109;
      }
      ckb_debug("Pay success");
    }
    return 0;
  } else {
    return ERROR_PUBKEY_BLAKE160_HASH;
  }
}
