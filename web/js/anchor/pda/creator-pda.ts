import {PublicKey} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import {DapCool} from "../idl";
import {getHandlePda} from "./handle-pda";

export interface Creator {
    authority: PublicKey
    handle: PublicKey
}

export async function getCreatorAndHandle(app, provider: AnchorProvider, program: Program<DapCool>): Promise<void> {
    // derive creator pda
    const creatorPda = await deriveCreatorPda(provider, program);
    try {
        const creator = await getCreatorPda(program, creatorPda);
        const handle = await getHandlePda(program, creator.handle);
        // send success to elm
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: "global-connect",
                    global: {
                        handle: handle.handle.toString(),
                        wallet: provider.wallet.publicKey.toString(),
                    }
                }
            )
        );
    } catch (error) {
        console.log("could not find creator on-chain");
        // send success to elm
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: "global-connect",
                    global: {
                        wallet: provider.wallet.publicKey.toString()
                    }
                }
            )
        );
    }
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
            provider.wallet.publicKey.toBuffer()
        ],
        program.programId
    );
    return creatorPda
}
