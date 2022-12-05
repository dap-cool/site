import {PublicKey} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import {DapCool} from "../idl/dap";

export interface CreatorPda {
    address: PublicKey
    bump: number
}

export interface Creator {
    authority: PublicKey
    handle: PublicKey
}

export async function getCreatorPda(program: Program<DapCool>, pda: CreatorPda): Promise<Creator> {
    const fetched = await program.account.creator.fetch(pda.address);
    return {
        authority: fetched.authority,
        handle: fetched.handle as PublicKey
    }
}

export async function deriveCreatorPda(provider: AnchorProvider, program: Program<DapCool>): Promise<CreatorPda> {
    let pda, bump;
    [pda, bump] = await PublicKey.findProgramAddress(
        [
            Buffer.from(SEED),
            provider.wallet.publicKey.toBuffer()
        ],
        program.programId
    );
    return {
        address: pda,
        bump
    }
}

const SEED = "creator";
