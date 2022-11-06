import {ShdwDrive} from "@shadow-drive/sdk";
import {Connection, PublicKey} from "@solana/web3.js";
import {version} from "./config";

export interface CollectionMetadata {
    name: string
    symbol: string
    description: string
    image: string // url
    external_url: string
}

export async function provision(
    connection: Connection,
    uploader: any,
    sizeInBytes: number
): Promise<{ drive: ShdwDrive; account: PublicKey }> {
    // build drive client
    console.log("build shdw client with finalized commitment");
    // build connection with finalized commitment for initial account creation
    const finalizedConnection = new Connection(connection.rpcEndpoint, "finalized");
    const drive: ShdwDrive = await new ShdwDrive(finalizedConnection, uploader).init();
    // create storage account
    console.log("create shdw storage account");
    const size = (((sizeInBytes / 1000000) + 2).toString()).split(".")[0] + "MB";
    console.log(size);
    const createStorageResponse = await drive.createStorageAccount("dap-cool", size, version)
    const account: PublicKey = new PublicKey(createStorageResponse.shdw_bucket);
    return {drive, account}
}

export async function markAsImmutable(drive: ShdwDrive, account: PublicKey): Promise<void> {
    console.log("mark account as immutable");
    // time out for 1 second to give RPC time to resolve account
    await new Promise(r => setTimeout(r, 1000));
    await drive.makeStorageImmutable(account, version);
}

export async function uploadFile(file: File, drive: ShdwDrive, account: PublicKey): Promise<string> {
    console.log("upload file to shdw drive");
    const url = (await drive.uploadFile(account, file, version)).finalized_locations[0];
    return url.replace(file.name, "");
}

export function readLogo(): File {
    const imgSelector: HTMLInputElement = document.getElementById(
        "dap-cool-collection-logo-selector"
    ) as HTMLInputElement;
    console.log(imgSelector);
    const fileList = imgSelector.files;
    let file;
    if (fileList && fileList.length === 1) {
        console.log("found selected logo");
        file = fileList[0];
        // parse file-type
        const fileName = file.name;
        const fileType = fileName.slice((Math.max(0, fileName.lastIndexOf(".")) || Infinity) + 1);
        // rename file
        console.log("renaming file")
        const blob = file.slice(0, file.size, file.type); // grab buffer
        file = new File([blob], "logo." + fileType, {type: file.type});
    } else {
        console.log("could not find logo")
    }
    return file as File
}

export function buildMetaData(
    handle: string,
    index: number,
    name: string,
    symbol: string,
    description: string,
    imageUrl: string
): File {
    const url = "https://dap.cool/#/" + handle + "/" + index;
    const meta = {
        name: name,
        symbol: symbol,
        description: description,
        image: imageUrl,
        external_url: url
    } as CollectionMetadata;
    const json = JSON.stringify(meta);
    const textEncoder = new TextEncoder();
    const bytes = textEncoder.encode(json);
    const blob = new Blob([bytes], {
        type: "application/json;charset=utf-8"
    });
    return new File([blob], "meta.json");
}
