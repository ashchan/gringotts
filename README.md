# Gringotts

UDT Hackathon Team Goblins Codebase

* [Server](server/)
* [Client (macOS)](client/)

# Smart Contracts

This dapp leverages 2 smart contracts:

* [Main contract](https://github.com/ashchan/gringotts/blob/795c693da37bd0c257b3d8a48b35fe523b8c2d80/server/contracts/lock.c): encodes the main validation logic
* [Secp contract](https://github.com/xxuejie/ckb-miscellaneous-scripts/blob/693a76f1609bd64b4cbf428f0ebb77198b8d57bd/c/secp256k1_blake2b_sighash_all_dual.c): encodes secp256k1 validation logic

The main contract uses dynamic linking techniques to load the secp contract and runs the signature verification code. Hence you can notice the main contract is quite small (7.9K in current example).

The secp contract is an interesting one: it can work as a dynamic linked library as shown above; it can also be used as a standalone executable contract by itself, in which case it will perform the secp256k1-blake2b-sighash-all validation just like the default lock.
