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
import {blobToDataUrl, compressImage, dataUrlToBlob} from "./util/blob-util";
import {getUploads, unlockUpload, upload} from "./anchor/pda/datum-pda";
import {initCreatorMetadata} from "./anchor/methods/creator-metadata/init-creator-metadata";
import {uploadLogo} from "./anchor/methods/creator-metadata/upload-logo";
import {uploadBio} from "./anchor/methods/creator-metadata/upload-bio";
import * as FeaturedCreators from "./shdw/creator/featured-creators";

// init phantom
let phantom = null;

export async function main(app, json) {
    console.log(json);
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
            // or fetch featured creators
        } else if (sender === "fetch-featured-creators") {
            // get provider & program
            const pp = getEphemeralPP();
            // invoke method
            await FeaturedCreators.init(
                app,
                pp.programs.dap
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
                    } else {
                        const browse = "https://phantom.app/ul/browse/";
                        const dap = "https://dap.cool/#/admin";
                        const href = browse + encodeURIComponent(dap);
                        app.ports.exception.send(
                            JSON.stringify(
                                {
                                    message: "It looks like there's no wallet installed!",
                                    href: {
                                        url: href,
                                        internal: true
                                    }
                                }
                            )
                        );
                    }
                }
            }
            // or creator provision storage for metadata
        } else if (sender === "creator-provision-metadata") {
            // get provider & program
            const pp = getPP(phantom);
            // invoke rpc
            await initCreatorMetadata(
                app,
                pp.provider,
                pp.programs
            );
            // or creator select logo
        } else if (sender === "creator-select-logo") {
            // select logo
            const imgSelector = document.getElementById(
                "dap-cool-creator-logo-selector"
            );
            if (!imgSelector.hasAttribute("listenerOnClick")) {
                imgSelector.addEventListener("change", async (selectEvent) => {
                    // capture file list
                    const fileList = selectEvent.target.files;
                    if (fileList.length > 0) {
                        const file = fileList[0];
                        const dataUrl = await blobToDataUrl(
                            file
                        );
                        app.ports.success.send(
                            JSON.stringify(
                                {
                                    listener: "creator-selected-new-creator-logo",
                                    more: JSON.stringify(
                                        {
                                            name: file.name,
                                            dataUrl: dataUrl
                                        }
                                    )
                                }
                            )
                        );
                    }
                });
            }
            imgSelector.setAttribute("listenerOnClick", "true");
            // or creator upload logo
        } else if (sender === "creator-upload-logo") {
            // get provider & program
            const pp = getPP(phantom);
            // parse more json
            const logo = JSON.parse(parsed.more);
            // invoke method
            await uploadLogo(
                app,
                pp.provider,
                pp.programs,
                logo
            );
            // or creator upload bio
        } else if (sender === "creator-upload-bio") {
            // get provider & program
            const pp = getPP(phantom);
            // parse more json
            const bio = JSON.parse(parsed.more);
            // invoke method
            await uploadBio(
                app,
                pp.provider,
                pp.programs,
                bio
            );
            // or creator prepare image form
        } else if (sender === "creator-prepare-image-form") {
            const imgSelector = document.getElementById(
                "dap-cool-collection-logo-selector"
            );
            if (!imgSelector.hasAttribute("listenerOnClick")) {
                imgSelector.addEventListener("change", async (selectEvent) => {
                    // capture file list
                    const fileList = selectEvent.target.files;
                    if (fileList.length === 1) {
                        // select file
                        let file = fileList[0];
                        const fileName = file.name;
                        // compress image
                        file = await compressImage(
                            file
                        );
                        // convert to base64
                        const base64 = await blobToDataUrl(
                            file
                        );
                        // send image name to elm
                        app.ports.success.send(
                            JSON.stringify(
                                {
                                    listener: "creator-selected-new-nft-logo",
                                    more: JSON.stringify(
                                        {
                                            name: fileName,
                                            base64: base64
                                        }
                                    )
                                }
                            )
                        );
                    }
                });
            }
            imgSelector.setAttribute("listenerOnClick", "true");
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
                                        collections: collections,
                                        metadata: handle.metadata
                                    }
                                )
                            }
                        )
                    );
                }
            }
            // or creator select files to upload
        } else if (sender === "creator-select-files-to-upload") {
            // select files
            const imgSelector = document.getElementById(
                "dap-cool-collection-upload-selector"
            );
            if (!imgSelector.hasAttribute("listenerOnClick")) {
                imgSelector.addEventListener("change", async (selectEvent) => {
                    // capture file list
                    const fileList = selectEvent.target.files;
                    if (fileList.length > 0) {
                        const files = await Promise.all(
                            Array.from(fileList).map(async (file) => {
                                    const dataUrl = await blobToDataUrl(
                                        file
                                    );
                                    return {
                                        name: file.name,
                                        dataUrl: dataUrl
                                    }
                                }
                            )
                        );
                        app.ports.success.send(
                            JSON.stringify(
                                {
                                    listener: "creator-selected-files-to-upload",
                                    more: JSON.stringify(
                                        {
                                            count: files.length,
                                            files: files
                                        }
                                    )
                                }
                            )
                        );
                    }
                });
            }
            imgSelector.setAttribute("listenerOnClick", "true");
            // or creator upload
        } else if (sender === "creator-upload") {
            // get provider & program
            const pp = getPP(phantom);
            // parse more json
            const more = JSON.parse(parsed.more);
            // select files
            if (more.form.files.count > 0) {
                // unpack data-url array
                const files = await Promise.all(
                    more.form.files.files.map(async (file) => {
                            const blob = await dataUrlToBlob(
                                file.dataUrl
                            );
                            return new File(
                                [blob],
                                file.name,
                                {type: blob.type}
                            )
                        }
                    )
                );
                more.form.files = {
                    count: files.length,
                    files: files
                };
                // upload
                await upload(
                    app,
                    pp.provider,
                    pp.programs.dap,
                    more.collection,
                    more.form
                );
            }
            // or creator select collection
        } else if (sender === "creator-select-collection") {
            // get provider & program
            const pp = getPP(phantom);
            // parse more json
            const more = JSON.parse(parsed.more);
            // get uploads
            const uploads = await getUploads(
                pp.provider,
                pp.programs.dap,
                more
            );
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-selected-collection",
                        more: JSON.stringify(
                            {
                                collection: more,
                                datum: uploads
                            }
                        )
                    }
                )
            );
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
                        // get uploads
                        const uploads = await getUploads(
                            pp.provider,
                            pp.programs.dap,
                            {
                                meta: {
                                    handle: collection.meta.handle
                                },
                                accounts: {
                                    mint: collection.accounts.mint.toString()
                                }
                            }
                        );
                        app.ports.success.send(
                            JSON.stringify(
                                {
                                    listener: "collector-collection-found",
                                    more: JSON.stringify(
                                        {
                                            collection: collection,
                                            datum: uploads
                                        }
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
            // parse more json
            const more = JSON.parse(parsed.more);
            // get phantom
            phantom = await getPhantom(app);
            if (phantom) {
                // get provider & program
                const pp = getPP(phantom);
                // invoke rpc
                await mintNewCopy(
                    app,
                    pp.provider,
                    pp.programs,
                    more.handle,
                    more.index
                )
            } else {
                const browse = "https://phantom.app/ul/browse/";
                const dap = "https://dap.cool/#/" + more.handle + "/" + more.index;
                const href = browse + encodeURIComponent(dap);
                app.ports.exception.send(
                    JSON.stringify(
                        {
                            message: "It looks like there's no wallet installed!",
                            href: {
                                url: href,
                                internal: true
                            }
                        }
                    )
                );
            }
            // or collector unlock datum
        } else if (sender === "collector-unlock-datum") {
            // parse more json
            const datum = JSON.parse(parsed.more);
            // unlock datum
            const unlocked = await unlockUpload(
                datum
            );
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "collector-datum-unlocked",
                        more: JSON.stringify(
                            unlocked
                        )
                    }
                )
            );
            // or throw error
        } else {
            const msg = "invalid role sent to js: " + sender;
            app.ports.exception.send(
                JSON.stringify(
                    {
                        message: msg
                    }
                )
            );
        }
    } catch (error) {
        console.log(error);
        app.ports.exception.send(
            JSON.stringify(
                {
                    message: error.toString()
                }
            )
        );
    }
}

export async function onWalletChange(app) {
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
            }
        });
    }
}
