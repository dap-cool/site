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
    // get all collections from collector
    let collections: CollectionAuthority[];
    try {
        const collector = await getCollectorPda(program, collectorPda);
        const collected = await getAllCollectionPda(provider, program, collector);
        collections = await getManyAuthorityPdaForCollector(program, collected);
    } catch (error) {
        console.log("could not find collector on-chain");
        collections = []
    }
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
                        wallet: provider.wallet.publicKey.toString(),
                        collections: collections
                    }
                }
            )
        );
    }
}