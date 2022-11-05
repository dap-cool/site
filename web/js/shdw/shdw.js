import {web3} from "@project-serum/anchor";
import {ShdwDrive} from "@shadow-drive/sdk";
import {version} from "./config";

export async function provision(connection, uploader, sizeInBytes) {
    // build drive client
    console.log("build shdw client with finalized commitment");
    // build connection with finalized commitment for initial account creation
    const finalizedConnection = new web3.Connection(connection.rpcEndpoint, "finalized");
    const drive = await new ShdwDrive(finalizedConnection, uploader).init();
    // create storage account
    console.log("create shdw storage account");
    const size = (((sizeInBytes / 1000000) + 2).toString()).split(".")[0] + "MB";
    console.log(size);
    const createStorageResponse = await drive.createStorageAccount("dap-cool", size, version)
    const account = new web3.PublicKey(createStorageResponse.shdw_bucket);
    return {drive, account}
}

export async function markAsImmutable(drive, account) {
    console.log("mark account as immutable");
    // time out for 1 second to give RPC time to resolve account
    await new Promise(r => setTimeout(r, 1000));
    await drive.makeStorageImmutable(account, version);
}

export async function uploadFile(file, drive, account) {
    console.log("upload file to shdw drive");
    const url = (await drive.uploadFile(account, file, version)).finalized_locations[0];
    return url.replace(file.name, "");
}

export async function readLogo() {
    const imgSelector = document.getElementById(
        "dap-cool-collection-logo-selector"
    );
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
    return file
}

export function buildMetaData(handle, index, name, symbol, description, imageUrl) {
    const url = "https://dap.cool/#/" + handle + "/" + index;
    const meta = {
        name: name,
        symbol: symbol,
        description: description,
        image: imageUrl,
        external_url: url
    };
    const json = JSON.stringify(meta);
    const textEncoder = new TextEncoder();
    const bytes = textEncoder.encode(json);
    const blob = new Blob([bytes], {
        type: "application/json;charset=utf-8"
    });
    return new File([blob], "meta.json");
}
