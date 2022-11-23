import {getPhantom, getPhantomProvider} from "./phantom";
import {getEphemeralPP, getPP} from "./anchor/util/context";
import {
    validateNewHandle,
    validateExistingHandle,
    validateHandleForCollector,
    assertHandlePdaDoesNotExistAlready,
    assertHandlePdaDoesExistAlreadyForCollector,
    assertHandlePdaDoesExistAlreadyForCreator, getHandlePda
} from "./anchor/pda/handle-pda";
import {getAllCollectionsFromHandle} from "./anchor/pda/get-all-collections-from-handle";
import {decodeAuthorityPda, getAuthorityPda, getManyAuthorityPdaForCollector} from "./anchor/pda/authority-pda";
import {initNewHandle} from "./anchor/methods/init-new-handle";
import {createCollection, creatNft} from "./anchor/methods/create-nft";
import {mintNewCopy} from "./anchor/methods/mint-new-copy";
import {getGlobal} from "./anchor/pda/get-global";
import {deriveCreatorPda, getCreatorPda} from "./anchor/pda/creator-pda";
import {deriveCollectorPda, getAllCollectionPda, getCollectorPda} from "./anchor/pda/collector-pda";

// init phantom
let phantom = null;

export async function main(app, json) {
    console.log(json);
    // listen for wallet change
    const phantomProvider = getPhantomProvider();
    if (phantomProvider) {
        phantomProvider.on("accountChanged", async () => {
            console.log("wallet changed");
            // fetch state if previously connected
            if (phantom) {
                phantom = await getPhantom(app);
                const pp = getPP(phantom);
                await getGlobal(
                    app,
                    pp.provider,
                    pp.program
                );
                window.location = "#/creator" // top
            }
        });
    }
    try {
        // parse json as object
        const parsed = JSON.parse(json);
        // match on sender role
        const sender = parsed.sender;
        // listen for connect
        if (sender === "connect") {
            // get phantom
            phantom = await getPhantom(app);
            if (phantom) {
                // get provider & program
                const pp = getPP(phantom);
                await getGlobal(
                    app,
                    pp.provider,
                    pp.program
                );
            }
            // or listen for disconnect
        } else if (sender === "disconnect") {
            phantom.windowSolana.disconnect();
            phantom = null;
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "global-disconnect-wallet"
                    }
                )
            );
            // or new creator confirm handle
        } else if (sender === "new-creator-confirm-handle") {
            // parse more json
            const more = JSON.parse(parsed.more);
            // validate handle
            const validated = validateNewHandle(
                app,
                more.handle
            );
            if (validated) {
                // get ephemeral provider & program
                const ephemeralPP = getEphemeralPP();
                // assert handle pda does-not-exist
                const handle = await assertHandlePdaDoesNotExistAlready(
                    app,
                    ephemeralPP.program,
                    validated
                );
                // initialize handle
                if (handle) {
                    // get phantom
                    phantom = await getPhantom(app);
                    if (phantom) {
                        // get provider & program
                        const pp = getPP(phantom);
                        // invoke init-new-handle
                        await initNewHandle(
                            app,
                            pp.provider,
                            pp.program,
                            validated,
                            handle
                        );
                    }
                }
            }
            // or existing creator confirm handle
        } else if (sender === "existing-creator-confirm-handle") {
            // parse more json
            const more = JSON.parse(parsed.more);
            // validate handle
            const validated = validateExistingHandle(
                app,
                more.handle
            );
            if (validated) {
                // get ephemeral provider & program
                const ephemeralPP = getEphemeralPP();
                // asert handle pda exists
                const handle = await assertHandlePdaDoesExistAlreadyForCreator(
                    app,
                    ephemeralPP.program,
                    validated
                );
                // authorize pda
                if (handle) {
                    // get phantom
                    phantom = await getPhantom(app);
                    if (phantom) {
                        // get provider & program
                        const pp = getPP(phantom);
                        // get collections
                        const collections = await getAllCollectionsFromHandle(pp.program, handle);
                        // derive collector pda
                        const collectorPda = await deriveCollectorPda(pp.provider, pp.program);
                        let collected;
                        try {
                            // fetch collector
                            const collector = await getCollectorPda(pp.program, collectorPda);
                            // fetch collected
                            const collectedPda = await getAllCollectionPda(pp.provider, pp.program, collector);
                            collected = await getManyAuthorityPdaForCollector(pp.program, collectedPda);
                        } catch (error) {
                            console.log("could not find collector on-chain");
                            collected = [];
                        }
                        // assert authority is current user
                        const current = pp.provider.wallet.publicKey.toString();
                        if (handle.authority.toString() === current) {
                            app.ports.success.send(
                                JSON.stringify(
                                    {
                                        listener: "creator-authorized",
                                        more: JSON.stringify(
                                            {
                                                handle: validated,
                                                wallet: current,
                                                collections: collections,
                                                collected: collected
                                            }
                                        )
                                    }
                                )
                            );
                        } else {
                            console.log("user unauthorized");
                            app.ports.success.send(
                                JSON.stringify(
                                    {
                                        listener: "creator-handle-unauthorized",
                                        more: JSON.stringify(
                                            {
                                                handle: validated,
                                                wallet: current,
                                                collections: collections,
                                                collected: collected
                                            }
                                        )
                                    }
                                )
                            );
                        }
                    }
                }
            }
            // or creator prepare image form
        } else if (sender === "creator-prepare-image-form") {
            const img = document.getElementById(
                "dap-cool-collection-logo"
            );
            const imgSelector = document.getElementById(
                "dap-cool-collection-logo-selector"
            );
            imgSelector.addEventListener("change", (selectEvent) => {
                // capture file list
                const fileList = selectEvent.target.files;
                if (fileList.length === 1) {
                    const file = fileList[0];
                    // read image
                    const reader = new FileReader();
                    reader.addEventListener("load", (readEvent) => {
                        img.src = readEvent.target.result;
                    });
                    reader.readAsDataURL(file);
                }
            });
            // or creator create new collection
        } else if (sender === "creator-create-new-collection") {
            // get provider & program
            const pp = getPP(phantom);
            // parse more json
            const more = JSON.parse(parsed.more);
            // derive & fetch creator pda
            const creatorPda = await deriveCreatorPda(pp.provider, pp.program);
            const creator = await getCreatorPda(pp.program, creatorPda);
            // fetch handle
            const handle = await getHandlePda(pp.program, creator.handle);
            // invoke rpc
            await creatNft(
                app,
                pp.provider,
                pp.program,
                creator.handle,
                handle,
                more.name,
                more.symbol
            );
            // or creator mark new collection
        } else if (sender === "creator-mark-new-collection") {
            // get provider & program
            const pp = getPP(phantom);
            // parse more json
            const more = JSON.parse(parsed.more);
            // derive & fetch creator pda
            const creatorPda = await deriveCreatorPda(pp.provider, pp.program);
            const creator = await getCreatorPda(pp.program, creatorPda);
            // decode authority pda
            const authorityObj = decodeAuthorityPda(more);
            await createCollection(
                app,
                pp.provider,
                pp.program,
                creator,
                authorityObj,
                more.index
            );
            // or collector search collector
        } else if (sender === "collector-search-handle") {
            // parse more json
            const more = JSON.parse(parsed.more);
            // validate handle
            const validated = validateHandleForCollector(
                app,
                more.handle
            );
            if (validated) {
                // get ephemeral provider & program
                const ephemeralPP = getEphemeralPP();
                // asert handle pda exists
                const handle = await assertHandlePdaDoesExistAlreadyForCollector(
                    app,
                    ephemeralPP.program,
                    validated
                );
                if (handle) {
                    // get collections
                    const collections = await getAllCollectionsFromHandle(ephemeralPP.program, handle);
                    app.ports.success.send(
                        JSON.stringify(
                            {
                                listener: "collector-handle-found",
                                more: JSON.stringify(
                                    {
                                        handle: validated,
                                        collections: collections
                                    }
                                )
                            }
                        )
                    );
                }
            }
            // or collector select collection
        } else if (sender === "collector-select-collection") {
            // parse more json
            const more = JSON.parse(parsed.more);
            // validate handle
            const validated = validateHandleForCollector(
                app,
                more.handle
            );
            if (validated) {
                // get ephemeral provider & program
                const ephemeralPP = getEphemeralPP();
                // asert handle pda exists
                const handle = await assertHandlePdaDoesExistAlreadyForCollector(
                    app,
                    ephemeralPP.program,
                    validated
                );
                if (handle) {
                    // get collection
                    const collection = await getAuthorityPda(ephemeralPP.program, validated, more.index);
                    app.ports.success.send(
                        JSON.stringify(
                            {
                                listener: "collector-collection-found",
                                more: JSON.stringify(
                                    collection
                                )
                            }
                        )
                    );
                }
            }
            // or collector purchase collection
        } else if (sender === "collector-purchase-collection") {
            // get phantom
            phantom = await getPhantom(app);
            if (phantom) {
                // get provider & program
                const pp = getPP(phantom);
                // parse more json
                const more = JSON.parse(parsed.more);
                // invoke rpc
                await mintNewCopy(
                    app,
                    pp.provider,
                    pp.program,
                    more.handle,
                    more.index
                )
            }
            // or throw error
        } else {
            const msg = "invalid role sent to js: " + sender;
            app.ports.error.send(
                msg
            );
        }
    } catch (error) {
        console.log(error);
        app.ports.error.send(
            error.toString()
        );
    }
}
