import {PublicKey, SystemProgram} from "@solana/web3.js";
import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
import {DapCool} from "../idl/dap";
import {deriveCreatorPda} from "../pda/creator-pda";
import {deriveCollectorPda, getAllCollectionPda, getCollectorPda} from "../pda/collector-pda";
import {getManyAuthorityPdaForCollector} from "../pda/authority-pda";

export async function initNewHandle(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        token: Program<SplToken>
    },
    handle: string,
    handlePda: PublicKey
) {
    // derive creator pda
    const creatorPda = await deriveCreatorPda(provider, programs.dap);
    // invoke rpc
    await programs.dap.methods
        .initNewCreator(
            handle as any
        )
        .accounts(
            {
                handlePda: handlePda,
                creator: creatorPda.address,
                payer: provider.wallet.publicKey,
                systemProgram: SystemProgram.programId,
            }
        )
        .rpc();
    // derive collector pda
    const collectorPda = await deriveCollectorPda(provider, programs.dap);
    // fetch collector
    let collected;
    try {
        const collector = await getCollectorPda(programs.dap, collectorPda);
        // fetch collected
        const collectedPda = await getAllCollectionPda(provider, programs.dap, collector);
        collected = await getManyAuthorityPdaForCollector(provider, programs, collectedPda);
    } catch (error) {
        console.log("could not find collector on-chain");
        collected = [];
    }
    // send success
    app.ports.success.send(
        JSON.stringify(
            {
                listener: "creator-new-handle-success",
                more: JSON.stringify(
                    {
                        handle: handle,
                        wallet: provider.wallet.publicKey.toString(),
                        collections: [],
                        collected: collected
                    }
                )
            }
        )
    );
}
