import {PublicKey, SystemProgram} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import {DapCool} from "../idl";
import {deriveCreatorPda} from "../pda/creator-pda";
import {deriveCollectorPda, getAllCollectionPda, getCollectorPda} from "../pda/collector-pda";
import {getManyAuthorityPdaForCollector} from "../pda/authority-pda";

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
    // derive collector pda
    const collectorPda = await deriveCollectorPda(provider, program);
    // fetch collector
    let collected;
    try {
        const collector = await getCollectorPda(program, collectorPda);
        // fetch collected
        const collectedPda = await getAllCollectionPda(provider, program, collector);
        collected = await getManyAuthorityPdaForCollector(program, collectedPda);
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
