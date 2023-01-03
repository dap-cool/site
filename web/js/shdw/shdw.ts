export interface CollectionMetadata {
    name: string
    symbol: string
    description: string
    image: string // url
    external_url: string
}

export function encodeFileType(fileType: string): number {
    let encoded: number;
    switch (fileType) {
        case "jpg": {
            encoded = 1;
            break
        }
        case "jpeg": {
            encoded = 2;
            break
        }
        case "png": {
            encoded = 3;
            break
        }
    }
    return encoded
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

export async function getMetaData(url: string): Promise<CollectionMetadata> {
    const fetched = await fetch(url)
        .then(response => response.json());
    return {
        name: fetched.name,
        symbol: fetched.symbol,
        description: fetched.description,
        image: fetched.image,
        external_url: fetched.external_url
    }
}
