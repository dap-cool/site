export interface CollectionMetadata {
    name: string
    symbol: string
    description: string
    image: string // url
    external_url: string
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
