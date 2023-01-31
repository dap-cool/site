import {AnchorProvider} from "@project-serum/anchor";
import {PublicKey} from "@solana/web3.js";
import {SPL_ASSOCIATED_TOKEN_PROGRAM_ID, SPL_TOKEN_PROGRAM_ID} from "../util/constants";

export interface RawSplTokenAccount {
    mint: PublicKey
    amount: any // encoded as BN
}

export function deriveAtaPda(provider: AnchorProvider, mint: PublicKey): PublicKey {
    let ataPda: PublicKey, _;
    [ataPda, _] = PublicKey.findProgramAddressSync(
        [
            provider.publicKey.toBuffer(),
            SPL_TOKEN_PROGRAM_ID.toBuffer(),
            mint.toBuffer()
        ],
        SPL_ASSOCIATED_TOKEN_PROGRAM_ID
    )
    return ataPda
}
