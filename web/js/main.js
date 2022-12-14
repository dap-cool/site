import {getPhantom, getPhantomProvider} from "./phantom";
import {getEphemeralPP, getPP} from "./anchor/util/context";
import {
    validateNewHandle,
    validateHandleForCollector,
    assertHandlePdaDoesNotExistAlready,
    assertHandlePdaDoesExistAlreadyForCollector,
    getHandlePda
} from "./anchor/pda/handle-pda";
import {
    deriveAuthorityPda,
    getAuthorityPda,
    getManyAuthorityPdaForCreator
} from "./anchor/pda/authority-pda";
import {initNewHandle} from "./anchor/methods/init-new-handle";
import {creatNft} from "./anchor/methods/create-nft";
import {mintNewCopy} from "./anchor/methods/mint-new-copy";
import {getGlobal} from "./anchor/pda/get-global";
import {deriveCreatorPda, getCreatorPda} from "./anchor/pda/creator-pda";
import {compressImage, readImage} from "./util/read-image";
import {getLogo, getMetaData} from "./shdw/shdw";

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
                    pp.programs
                );
                window.location = "#/" // top
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
                    pp.programs
                );
            }
            // or listen for disconnect
        } else if (sender === "disconnect") {
            // TODO; href to top
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
                    ephemeralPP.programs.dap,
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
                            pp.programs,
                            validated,
                            handle
                        );
                    }
                }
            }
            // or creator prepare image form
        } else if (sender === "creator-prepare-image-form") {
            const imgSelector = document.getElementById(
                "dap-cool-collection-logo-selector"
            );
            imgSelector.addEventListener("change", async (selectEvent) => {
                // capture file list
                const fileList = selectEvent.target.files;
                if (fileList.length === 1) {
                    let file = fileList[0];
                    // compress image
                    file = await compressImage(
                        file
                    );
                    // read image
                    readImage(
                        "dap-cool-collection-logo",
                        file
                    );
                }
            });
            // or creator create new nft
        } else if (sender === "creator-create-new-nft") {
            // get provider & program
            const pp = getPP(phantom);
            // parse more json
            const more = JSON.parse(parsed.more);
            // derive & fetch creator pda
            const creatorPda = await deriveCreatorPda(pp.provider, pp.programs.dap);
            const creator = await getCreatorPda(pp.programs.dap, creatorPda);
            // fetch handle
            const handle = await getHandlePda(pp.programs.dap, creator.handle);
            // invoke create-nft
            await creatNft(
                app,
                pp.provider,
                pp.programs,
                handle,
                more
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
                    ephemeralPP.programs.dap,
                    validated
                );
                if (handle) {
                    // get collections
                    const collections = await getManyAuthorityPdaForCreator(
                        ephemeralPP.provider,
                        ephemeralPP.programs,
                        handle
                    );
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
            // or read logos
        } else if (sender === "collector-read-logos") {
            await new Promise(r => setTimeout(r, 50));
            // parse more json
            const collections = JSON.parse(parsed.more);
            // read logo for each collection
            for (const collection of collections) {
                const metaData = await getMetaData(
                    collection.meta.uri
                );
                await getLogo(
                    collection.accounts.mint,
                    metaData
                );
            }
            // or collector select collection
        } else if (sender === "collector-select-collection") {
            // parse more json
            const more = JSON.parse(parsed.more);
            const target = "#/" + more.handle + "/" + more.index;
            if (window.location.toString().endsWith(target)) {
                // validate handle
                const validated = validateHandleForCollector(
                    app,
                    more.handle
                );
                if (validated) {
                    // get provider & program
                    let pp;
                    if (phantom) {
                        pp = getPP(phantom);
                    } else {
                        pp = getEphemeralPP();
                    }
                    // asert handle pda exists
                    const handle = await assertHandlePdaDoesExistAlreadyForCollector(
                        app,
                        pp.programs.dap,
                        validated
                    );
                    if (handle) {
                        // derive & fetch collection
                        const authorityPda = await deriveAuthorityPda(
                            pp.programs.dap,
                            validated,
                            more.index
                        );
                        const collection = await getAuthorityPda(
                            pp.provider,
                            pp.programs,
                            authorityPda
                        );
                        console.log(collection);
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
            } else {
                // href
                window.location = target;
            }
            // or collector print copy
        } else if (sender === "collector-print-copy") {
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
                    pp.programs,
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
