import {PublicKey} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import * as DapSdk from "@dap-cool/sdk";
import {deriveHandlePda, getHandlePda} from "./handle-pda";
import {DapCool} from "../idl/dap";

interface CollectionFromElm {
    meta: {
        handle: string
    }
    accounts: {
        mint: string
    }
}

interface FormFromElm {
    title: string
}

interface ToElm extends DapSdk.Datum {
    metadata: {
        title: string
        zip: {
            count: number
            types: string[]
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
                        zip: metadata.zip
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
    provider: AnchorProvider,
    collection: CollectionFromElm,
    form: FormFromElm,
    files: FileList
): Promise<void> {
    // build encryption args
    const litArgs = DapSdk.defaultLitArgs(
        collection.accounts.mint
    );
    // encrypt
    const encrypted = await DapSdk.encrypt(
        files,
        litArgs
    );
    // provision storage on shdw drive
    const provisioned = await DapSdk.provision(
        provider.connection,
        provider.wallet,
        encrypted.file
    );
    // build metadata
    const metadata = {
        key: encrypted.key,
        lit: litArgs,
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
        [encrypted.file, encodedMetadata],
        provisioned.drive,
        provisioned.account
    );
    // publish url on-chain
    const dapProtocolProgram = DapSdk.getProgram(
        provider
    );
    await DapSdk.increment(
        dapProtocolProgram,
        provider,
        new PublicKey(collection.accounts.mint),
        provisioned.account
    );
}
