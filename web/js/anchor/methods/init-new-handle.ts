import {PublicKey, SystemProgram} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import {DapCool} from "../idl";
import {deriveCreatorPda} from "../pda/creator-pda";

export async function initNewHandle(
    app,
    provider: AnchorProvider,
    program: Program<DapCool>,
    handle: string,
    handlePda: PublicKey
) {
    // derive creator pda
    const creatorPda = await deriveCreatorPda(provider, program);
    // invoke rpc
    await program.methods
        .initNewCreator(
            handle as any
        )
        .accounts(
            {
                handlePda: handlePda,
                creator: creatorPda,
                payer: provider.wallet.publicKey,
                systemProgram: SystemProgram.programId,
            }
        )
        .rpc();
    // send success
    app.ports.success.send(
        JSON.stringify(
            {
                listener: "creator-new-handle-success",
                global: {
                    handle: handle,
                    wallet: provider.wallet.publicKey.toString()
                }
            }
        )
    );
}
