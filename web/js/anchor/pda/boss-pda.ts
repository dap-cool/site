import {PublicKey} from "@solana/web3.js";
import {Program} from "@project-serum/anchor";
import {DapCool} from "../idl/dap";

export interface BossPda {
    address: PublicKey
    bump: number
}

export interface Boss {
    authority: PublicKey
    usdc: PublicKey
    fee: number
}

export async function getBossPda(program: Program<DapCool>, pda: BossPda): Promise<Boss> {
    const fetched = await program.account.boss.fetch(pda.address);
    return {
        authority: fetched.authority,
        usdc: fetched.usdc,
        fee: fetched.fee.toNumber()
    }
}

export function deriveBossPda(program: Program<DapCool>): BossPda {
    let pda, bump;
    [pda, bump] = PublicKey.findProgramAddressSync(
        [
            Buffer.from(SEED)
        ],
        program.programId
    );
    return {
        address: pda,
        bump: bump
    }
}

const SEED = "boss";
