import {web3} from "@project-serum/anchor";

export async function initNewCreator(app, provider, program, handle, pda) {
    try {
        await program.methods
            .initNewCreator(
                handle
            )
            .accounts(
                {
                    creator: pda,
                    payer: provider.wallet.publicKey,
                    systemProgram: web3.SystemProgram.programId,
                }
            )
            .rpc();
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
    } catch (error) {
        const msg = error.toString();
        console.log(msg);
        app.ports.error.send(
            msg
        );
    }
}
