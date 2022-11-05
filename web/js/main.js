import {getPhantom} from "./phantom";
import {getEphemeralPP, getPP} from "./anchor/util/context";
import {
    validateHandleForNewCreator,
    validateHandleForExistingCreator,
    validateHandleForCollector,
    assertCreatorPdaDoesNotExistAlready,
    assertCreatorPdaDoesExistAlreadyForCreator,
    assertCreatorPdaDoesExistAlreadyForCollector
} from "./anchor/pda/creator-pda";
import {getCreatorCollections} from "./anchor/pda/get-creator-collections";
import {initNewCreator} from "./anchor/methods/init-new-creator";
import {creatNft} from "./anchor/methods/create-nft";
import {getAuthorityPda} from "./anchor/pda/authority-pda";
import {mintNewCopy} from "./anchor/methods/mint-new-copy";

// init phantom
let phantom = null;

export async function main(app, json) {
    console.log(json);
    try {
        // parse json as object
        const parsed = JSON.parse(json);
        // match on sender role
        const sender = parsed.sender;
        // new creator confirm handle
        if (sender === "new-creator-confirm-handle") {
            // parse more json
            const more = JSON.parse(parsed.more);
            // validate handle
            const validated = validateHandleForNewCreator(app, more.handle);
            if (validated) {
                // get ephemeral provider & program
                const ephemeralPP = getEphemeralPP();
                // assert creator pda does-not-exist
                const creator = await assertCreatorPdaDoesNotExistAlready(
                    app,
                    ephemeralPP.program,
                    validated
                );
                // create pda
                if (creator) {
                    // get phantom
                    phantom = await getPhantom(app);
                    // get provider & program
                    const pp = getPP(phantom);
                    // invoke init-new-creator
                    await initNewCreator(app, pp.provider, pp.program, validated, creator);
                }
            }
            // or existing creator confirm handle
        } else if (sender === "existing-creator-confirm-handle") {
            // parse more json
            const more = JSON.parse(parsed.more);
            // validate handle
            const validated = validateHandleForExistingCreator(app, more.handle);
            if (validated) {
                // get ephemeral provider & program
                const ephemeralPP = getEphemeralPP();
                // asert creator pda exists
                const creator = await assertCreatorPdaDoesExistAlreadyForCreator(
                    app,
                    ephemeralPP.program,
                    validated
                );
                // authorize pda
                if (creator) {
                    // get phantom
                    phantom = await getPhantom(app);
                    // get provider & program
                    const pp = getPP(phantom);
                    // assert authority is current user
                    const current = pp.provider.wallet.publicKey.toString();
                    if (creator.authority.toString() === current) {
                        // get collections
                        const collections = await getCreatorCollections(pp.program, creator);
                        app.ports.success.send(
                            JSON.stringify(
                                {
                                    listener: "creator-authorized",
                                    more: JSON.stringify(
                                        {
                                            handle: validated,
                                            wallet: current,
                                            collections: collections
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
                                            wallet: current
                                        }
                                    )
                                }
                            )
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
            // invoke rpc
            await creatNft(
                app,
                pp.provider,
                pp.program,
                more.handle,
                more.name,
                more.symbol
            );
            // or collector search collector
        } else if (sender === "collector-search-handle") {
            // parse more json
            const more = JSON.parse(parsed.more);
            // validate handle
            const validated = validateHandleForCollector(app, more.handle);
            if (validated) {
                // get ephemeral provider & program
                const ephemeralPP = getEphemeralPP();
                // asert creator pda exists
                const creator = await assertCreatorPdaDoesExistAlreadyForCollector(
                    app,
                    ephemeralPP.program,
                    validated
                );
                if (creator) {
                    // get collections
                    const collections = await getCreatorCollections(ephemeralPP.program, creator);
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
            const validated = validateHandleForCollector(app, more.handle);
            if (validated) {
                // get ephemeral provider & program
                const ephemeralPP = getEphemeralPP();
                // asert creator pda exists
                const creator = await assertCreatorPdaDoesExistAlreadyForCollector(
                    app,
                    ephemeralPP.program,
                    validated
                );
                if (creator) {
                    // get collection
                    const collection = await getAuthorityPda(ephemeralPP.program, validated, more.index);
                    app.ports.success.send(
                        JSON.stringify(
                            {
                                listener: "collector-collection-found",
                                more: JSON.stringify(
                                    {
                                        handle: validated,
                                        collection: collection
                                    }
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
