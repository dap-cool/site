import {Program} from "@project-serum/anchor";
import {DapCool} from "../idl/dap";
import {PublicKey} from "@solana/web3.js";

export interface Verified {
    verified: boolean
}

export async function getVerifiedPda(program: Program<DapCool>, pda: PublicKey): Promise<Verified> {
    return await program.account.verified.fetch(pda) as Verified;
}

export function deriveVerifiedPda(
    program: Program<DapCool>,
    handle: string,
    index: number,
    mint: PublicKey
): PublicKey {
    let pda: PublicKey, _;
    [pda, _] = PublicKey.findProgramAddressSync(
        [
            Buffer.from(SEED),
            Buffer.from(handle),
            Buffer.from([index]),
            mint.toBuffer()
        ],
        program.programId
    )
    return pda
}

const SEED = "verified";
