import {PublicKey} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import {DapCool} from "../idl/dap";

export interface Creator {
    authority: PublicKey
    handle: PublicKey
}

export async function getCreatorPda(program: Program<DapCool>, pda: PublicKey): Promise<Creator> {
    const fetched = await program.account.creator.fetch(pda);
    return {
        authority: fetched.authority,
        handle: fetched.handle as PublicKey
    }
}

export async function deriveCreatorPda(provider: AnchorProvider, program: Program<DapCool>): Promise<PublicKey> {
    // derive creator pda
    let creatorPda: PublicKey, _;
    [creatorPda, _] = await PublicKey.findProgramAddress(
        [
            Buffer.from(SEED),
            provider.wallet.publicKey.toBuffer()
        ],
        program.programId
    );
    return creatorPda
}

const SEED = "creator";
