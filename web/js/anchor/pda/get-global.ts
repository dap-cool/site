import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
import {DapCool} from "../idl/dap";
import {getHandlePda} from "./handle-pda";
import {deriveCreatorPda, getCreatorPda} from "./creator-pda";
import {deriveCollectorPda, getAllCollectionPda, getCollectorPda} from "./collector-pda";
import {CollectionAuthority, getManyAuthorityPdaForCollector, getManyAuthorityPdaForCreator} from "./authority-pda";

export async function getGlobal(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        token: Program<SplToken>
    },
): Promise<void> {
    // derive creator pda
    const creatorPda = await deriveCreatorPda(
        provider,
        programs.dap
    );
    // derive collector pda
    const collectorPda = await deriveCollectorPda(
        provider,
        programs.dap
    );
    // get all collections collected by collector
    let collected: CollectionAuthority[];
    try {
        const collector = await getCollectorPda(
            programs.dap,
            collectorPda
        );
        const collectedPda = await getAllCollectionPda(
            provider,
            programs.dap,
            collector
        );
        collected = await getManyAuthorityPdaForCollector(
            provider,
            programs,
            collectedPda
        );
    } catch (error) {
        console.log("could not find collector on-chain");
        collected = []
    }
    try {
        // fetch creator
        const creator = await getCreatorPda(
            programs.dap,
            creatorPda
        );
        const handle = await getHandlePda(
            programs.dap,
            creator.handle
        );
        // fetch collections
        const collections = await getManyAuthorityPdaForCreator(
            provider,
            programs,
            handle
        );
        // send success to elm
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: "global-found-wallet-and-handle",
                    more: JSON.stringify(
                        {
                            handle: handle.handle.toString(),
                            wallet: provider.wallet.publicKey.toString(),
                            collections: collections,
                            collected: collected
                        }
                    )
                }
            )
        );
    } catch (error) {
        console.log(error);
        console.log("could not find creator on-chain");
        // send success to elm
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: "global-found-wallet",
                    more: JSON.stringify({
                            wallet: provider.wallet.publicKey.toString(),
                            collected: collected
                        }
                    )
                }
            )
        );
    }
}
