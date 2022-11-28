import {getPhantom, getPhantomProvider} from "./phantom";
import {getEphemeralPP, getPP} from "./anchor/util/context";
import {
    validateNewHandle,
    validateHandleForCollector,
    assertHandlePdaDoesNotExistAlready,
    assertHandlePdaDoesExistAlreadyForCollector,
    getHandlePda
} from "./anchor/pda/handle-pda";
import {decodeAuthorityPda, getAuthorityPda, getManyAuthorityPdaForCreator} from "./anchor/pda/authority-pda";
import {initNewHandle} from "./anchor/methods/init-new-handle";
import {createCollection, creatNft} from "./anchor/methods/create-nft";
import {mintNewCopy} from "./anchor/methods/mint-new-copy";
import {getGlobal} from "./anchor/pda/get-global";
import {deriveCreatorPda, getCreatorPda} from "./anchor/pda/creator-pda";

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
                            pp.programs.dap,
                            validated,
                            handle
                        );
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
            const creatorPda = await deriveCreatorPda(pp.provider, pp.programs.dap);
            const creator = await getCreatorPda(pp.programs.dap, creatorPda);
            // fetch handle
            const handle = await getHandlePda(pp.programs.dap, creator.handle);
            // invoke rpc
            await creatNft(
                app,
                pp.provider,
                pp.programs.dap,
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
            const creatorPda = await deriveCreatorPda(pp.provider, pp.programs.dap);
            const creator = await getCreatorPda(pp.programs.dap, creatorPda);
            // decode authority pda
            const authorityObj = decodeAuthorityPda(more);
            await createCollection(
                app,
                pp.provider,
                pp.programs.dap,
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
                    ephemeralPP.programs.dap,
                    validated
                );
                if (handle) {
                    // get collections
                    const collections = await getManyAuthorityPdaForCreator(ephemeralPP.programs.dap, handle);
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
                    ephemeralPP.programs.dap,
                    validated
                );
                if (handle) {
                    // get collection
                    const collection = await getAuthorityPda(ephemeralPP.programs.dap, validated, more.index);
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
                    pp.programs.dap,
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
