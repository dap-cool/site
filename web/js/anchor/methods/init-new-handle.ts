import {PublicKey, SystemProgram} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import {DapCool} from "../idl";

export async function initNewHandle(
    app,
    provider: AnchorProvider,
    program: Program<DapCool>,
    handle: string,
    handlePda: PublicKey
) {
    // derive creator pda
    let creatorPda: PublicKey, _;
    [creatorPda, _] = await PublicKey.findProgramAddress(
        [
            provider.wallet.publicKey.toBuffer()
        ],
        program.programId
    );
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
