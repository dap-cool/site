import {AnchorProvider, Program} from "@project-serum/anchor";
import {DapCool} from "../idl";
import {getHandlePda} from "./handle-pda";
import {deriveCreatorPda, getCreatorPda} from "./creator-pda";
import {deriveCollectorPda, getAllCollectionPda, getCollectorPda} from "./collector-pda";
import {CollectionAuthority, getManyAuthorityPdaForCollector} from "./authority-pda";

export async function getGlobal(app, provider: AnchorProvider, program: Program<DapCool>): Promise<void> {
    // derive creator pda
    const creatorPda = await deriveCreatorPda(provider, program);
    // derive collector pda
    const collectorPda = await deriveCollectorPda(provider, program);
    // get all collections collected by collector
    let collected: CollectionAuthority[];
    try {
        const collector = await getCollectorPda(program, collectorPda);
        const collectedPda = await getAllCollectionPda(provider, program, collector);
        collected = await getManyAuthorityPdaForCollector(program, collectedPda);
    } catch (error) {
        console.log("could not find collector on-chain");
        collected = []
    }
    try {
        const creator = await getCreatorPda(program, creatorPda);
        const handle = await getHandlePda(program, creator.handle);
        // send success to elm
        // TODO; fetch collections
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: "global-found-wallet-and-handle",
                    more: JSON.stringify(
                        {
                            handle: handle.handle.toString(),
                            wallet: provider.wallet.publicKey.toString(),
                            collections: [],
                            collected: collected
                        }
                    )
                }
            )
        );
    } catch (error) {
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
