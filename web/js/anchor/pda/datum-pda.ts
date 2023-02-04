import {PublicKey} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import JSZip from "jszip";
import * as DapSdk from "@dap-cool/sdk";
import {deriveHandlePda, getHandlePda} from "./handle-pda";
import {DapCool} from "../idl/dap";
import {ShdwDrive} from "@shadow-drive/sdk";
import {blobToDataUrl, getFileTypeFromName} from "../../util/blob-util";

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
    files: {
        count: number
        files: {
                name: string
                dataUrl: string
            }[]
            | File []
    }
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
    files: {
        count: number
        files: File[]
    }
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
                base64: string,
                type_: string
            }[]
        }
        timestamp: number
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
                    const base64: string = await file
                        .async("base64");
                    const type = getFileTypeFromName(
                        file.name
                    );
                    return {
                        base64: base64,
                        type_: type
                    }
                } else {
                    return null
                }
            }
        )
    )).filter(Boolean) as { base64: string, type_: string }[];
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
            },
            timestamp: metadata.timestamp
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
                        timestamp: metadata.timestamp
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
    program: Program<DapCool>,
    collection: CollectionFromElm,
    formFromElm: FormFromElm
): Promise<void> {
    // transform elm-form to js-form
    let form = {
        step: formFromElm.step,
        retries: formFromElm.retries,
        files: formFromElm.files,
        title: formFromElm.title,
        shadow: null,
        litArgs: formFromElm.litArgs,
        encrypted: null,
    } as Form;
    // bump elm-form for retries/next-steps
    const dataUrls = await fileArrayToDataUrlArray(
        formFromElm.files.files as File[]
    );
    formFromElm.files = {
        count: formFromElm.files.count,
        files: dataUrls
    };
    // start recursive retries
    if (form.step === 1) {
        try {
            // build encryption args
            const litArgs = DapSdk.defaultLitArgs(
                collection.accounts.mint
            );
            // encrypt
            form.encrypted = await DapSdk.encrypt(
                form.files.files as any,
                litArgs
            );
            // provision storage on shadow drive
            form.shadow = await DapSdk.provision(
                provider.connection,
                provider.wallet,
                form.encrypted.file.size
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
            // check for shadow
            if (!form.shadow) {
                form.shadow = {
                    account: new PublicKey(formFromElm.shadow),
                    drive: await DapSdk.buildClient(provider.connection, provider.wallet)
                }
                // if shadow is undefined so is encrypted
                form.encrypted = await DapSdk.encrypt(
                    form.files.files as any,
                    form.litArgs
                );
            }
            // build metadata
            const metadata = {
                key: form.encrypted.key,
                lit: form.litArgs,
                title: form.title,
                zip: {
                    count: form.files.count,
                    types: form.files.files.map(file => file.type)
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
            // get uploads
            const datum = await getUploads(
                provider,
                program,
                collection
            );
            // send success to elm
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-upload-success",
                        more: JSON.stringify(
                            {
                                collection: collection,
                                datum: datum
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
}

async function fileArrayToDataUrlArray(files: File[]): Promise<{ name: string, dataUrl: string }[]> {
    return await Promise.all(
        files.map(async (file) => {
                const dataUrl = await blobToDataUrl(file);
                return {
                    name: file.name,
                    dataUrl: dataUrl as string
                }
            }
        )
    );
}
