import {Program} from "@project-serum/anchor";
import {DapCool} from "../idl/dap";
import {PublicKey} from "@solana/web3.js";

export interface VerifiedPda {
    address: PublicKey
    bump: number
}

export interface Verified {
    verified: boolean
}

export async function getVerifiedPda(program: Program<DapCool>, pda: VerifiedPda): Promise<Verified> {
    return await program.account.verified.fetch(pda.address) as Verified;
}

export function deriveVerifiedPda(
    program: Program<DapCool>,
    handle: string,
    index: number,
    mint: PublicKey
): VerifiedPda {
    let pda, bump;
    [pda, bump] = PublicKey.findProgramAddressSync(
        [
            Buffer.from(SEED),
            Buffer.from(handle),
            Buffer.from([index]),
            mint.toBuffer()
        ],
        program.programId
    )
    return {
        address: pda,
        bump
    }
}

const SEED = "verified";
