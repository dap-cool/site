import {PublicKey} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import JSZip from "jszip";
import * as DapSdk from "@dap-cool/sdk";
import {deriveHandlePda, getHandlePda} from "./handle-pda";
import {DapCool} from "../idl/dap";
import {ShdwDrive} from "@shadow-drive/sdk";

interface CollectionFromElm {
    meta: {
        handle: string
    }
    accounts: {
        mint: string
    }
}

interface DatumFromElm {
    mint: string
    uploader: string
    index: number
    filtered: boolean
    shadow: {
        account: string,
        url: string
    }
}

interface FormFromElm {
    // math
    step: number
    retries: number
    // meta
    title: string
    // shadow-drive account
    shadow: string | null
    // lit args
    litArgs: DapSdk.LitArgs | null
}

interface Form {
    // math
    step: number
    retries: number
    // meta
    title: string
    // shadow-drive
    shadow: {
        account: PublicKey
        drive: ShdwDrive
    } | null
    // lit args
    litArgs: DapSdk.LitArgs | null
    // encrypted
    encrypted: {
        key: Uint8Array,
        file: File
    } | null
}

interface ToElm extends DapSdk.Datum {
    metadata: {
        title: string
        zip: {
            count: number
            types: string[]
            files: {
                src: string,
                type_: string
            }[]
        }
    }
}

export async function unlockUpload(fromElm: DatumFromElm): Promise<ToElm> {
    // get metadata
    const metadata = await DapSdk.getMetaData(
        fromElm.shadow.url
    );
    // decrypt
    const decryptedZip = await DapSdk.decrypt(
        fromElm.shadow.url,
        metadata
    );
    // read files
    const root = decryptedZip.folder(
        "encryptedAssets"
    );
    const files = Object.values(
        root.files
    );
    const base64Files = (await Promise.all(
        files.map(async (file: JSZip.JSZipObject) => {
                if (!file.dir) {
                    console.log(file.name);
                    const base64: string = await file
                        .async("base64");
                    return {
                        src: "data:image/png;base64," + base64,
                        type_: ""
                    }
                } else {
                    return null
                }
            }
        )
    )).filter(Boolean) as { src: string, type_: string }[];
    return {
        mint: new PublicKey(fromElm.mint),
        uploader: new PublicKey(fromElm.uploader),
        index: fromElm.index,
        filtered: fromElm.filtered,
        shadow: {
            account: new PublicKey(fromElm.shadow.account),
            url: fromElm.shadow.url
        },
        metadata: {
            title: metadata.title,
            zip: {
                count: metadata.zip.count,
                types: metadata.zip.types,
                files: base64Files
            }
        }
    }
}

export async function getUploads(
    provider: AnchorProvider,
    dapCoolProgram: Program<DapCool>,
    fromElm: CollectionFromElm
): Promise<ToElm[]> {
    // get program
    const dapProtocolProgram: Program<DapSdk.DapProtocol> = await DapSdk.getProgram(
        provider
    );
    // derive & get handle pda
    const handlePda = await deriveHandlePda(
        dapCoolProgram,
        fromElm.meta.handle
    );
    const handle = await getHandlePda(
        dapCoolProgram,
        handlePda.address
    );
    // derive & get increment pda
    const incrementPda = await DapSdk.deriveIncrementPda(
        dapProtocolProgram,
        new PublicKey(fromElm.accounts.mint),
        handle.authority
    );
    const increment = await DapSdk.getIncrementPda(
        dapProtocolProgram,
        incrementPda
    );
    // get many datum
    let toElmArray: ToElm[];
    if (increment) {
        const datum = await DapSdk.getManyDatumPda(
            dapProtocolProgram,
            [increment]
        );
        toElmArray = await Promise.all(
            datum.map(async (d) => {
                    const metadata = await DapSdk.getMetaData(
                        d.shadow.url
                    );
                    const toElm = d as ToElm;
                    toElm.metadata = {
                        title: metadata.title,
                        zip: {
                            count: metadata.zip.count,
                            types: metadata.zip.types,
                            files: []
                        },
                    }
                    return toElm
                }
            )
        );
    } else {
        toElmArray = [];
    }
    return toElmArray
}

export async function upload(
    app: any,
    provider: AnchorProvider,
    collection: CollectionFromElm,
    formFromElm: FormFromElm,
    files: FileList
): Promise<void> {
    let form = {
        step: formFromElm.step,
        retries: formFromElm.retries,
        title: formFromElm.title,
        shadow: null,
        litArgs: formFromElm.litArgs,
        encrypted: null,
    } as Form;
    if (form.step === 1) {
        try {
            // build encryption args
            const litArgs = DapSdk.defaultLitArgs(
                collection.accounts.mint
            );
            // encrypt
            form.encrypted = await DapSdk.encrypt(
                files,
                litArgs
            );
            // provision storage on shadow drive
            form.shadow = await DapSdk.provision(
                provider.connection,
                provider.wallet,
                form.encrypted.file
            );
            // bump shadow
            formFromElm.shadow = form.shadow.account.toString();
            // bump lit args
            formFromElm.litArgs = form.litArgs = litArgs;
            // bump retries
            formFromElm.retries = form.retries = 0;
            // bump step
            formFromElm.step = form.step = 2;
            // send update to elm
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-still-uploading",
                        more: JSON.stringify(
                            {
                                collection: collection,
                                form: formFromElm,
                                recursive: false
                            }
                        )
                    }
                )
            );
        } catch (error) {
            console.log(error);
            // send retry to elm
            formFromElm.retries += 1;
            console.log(formFromElm);
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-still-uploading",
                        more: JSON.stringify(
                            {
                                collection: collection,
                                form: formFromElm,
                                recursive: true
                            }
                        )
                    }
                )
            );
        }
    }
    if (form.step === 2) {
        try {
            console.log(form);
            console.log(formFromElm);
            // check for shadow
            if (!form.shadow) {
                form.shadow = {
                    account: new PublicKey(formFromElm.shadow),
                    drive: await DapSdk.buildClient(provider.connection, provider.wallet)
                }
                // if shadow is undefined so is encrypted
                form.encrypted = await DapSdk.encrypt(
                    files,
                    form.litArgs
                );
            }
            console.log(form);
            // build metadata
            const metadata = {
                key: form.encrypted.key,
                lit: form.litArgs,
                title: form.title,
                zip: {
                    count: files.length,
                    types: Array.from(files).map(file => file.type)
                },
                timestamp: Date.now()
            };
            const encodedMetadata = DapSdk.encodeMetadata(
                metadata
            );
            // upload encrypted file & metadata
            await DapSdk.uploadMultipleFiles(
                [form.encrypted.file, encodedMetadata],
                form.shadow.drive,
                form.shadow.account
            );
            // bump retries
            formFromElm.retries = form.retries = 0;
            // bump step
            formFromElm.step = form.step = 3;
            // send update to elm
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-still-uploading",
                        more: JSON.stringify(
                            {
                                collection: collection,
                                form: formFromElm,
                                recursive: false
                            }
                        )
                    }
                )
            );
        } catch (error) {
            console.log(error);
            // send retry to elm
            formFromElm.retries += 1;
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-still-uploading",
                        more: JSON.stringify(
                            {
                                collection: collection,
                                form: formFromElm,
                                recursive: true
                            }
                        )
                    }
                )
            );
        }
    }
    if (form.step === 3) {
        try {
            // check for shadow
            let shadowAccount: PublicKey;
            if (form.shadow) {
                shadowAccount = form.shadow.account;
            } else {
                shadowAccount = new PublicKey(formFromElm.shadow);
            }
            // publish url on-chain
            const dapProtocolProgram = DapSdk.getProgram(
                provider
            );
            await DapSdk.increment(
                dapProtocolProgram,
                provider,
                new PublicKey(collection.accounts.mint),
                shadowAccount
            );
            // send success to elm
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-upload-success",
                        more: JSON.stringify(
                            collection
                        )
                    }
                )
            );
        } catch (error) {
            console.log(error);
            // send retry to elm
            formFromElm.retries += 1;
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-still-uploading",
                        more: JSON.stringify(
                            {
                                collection: collection,
                                form: formFromElm,
                                recursive: true
                            }
                        )
                    }
                )
            );
        }
    }
}
