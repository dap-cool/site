import {PublicKey, SystemProgram} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import {DapCool} from "../idl";

export async function initNewCreator(
    app,
    provider: AnchorProvider,
    program: Program<DapCool>,
    handle: string,
    pda: PublicKey
) {
    // invoke rpc
    await program.methods
        .initNewCreator(
            handle as any
        )
        .accounts(
            {
                creator: pda,
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
                more: JSON.stringify(
                    {
                        handle: handle,
                        wallet: provider.wallet.publicKey.toString()
                    }
                )
            }
        )
    );
}
