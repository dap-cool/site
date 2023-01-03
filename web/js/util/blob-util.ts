/* https://developer.mozilla.org/en-US/docs/Web/API/FileReader/readAsDataURL */
import {compressAccurately} from "image-conversion";

export const blobToDataUrl = (blob: Blob) => new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsDataURL(blob);
    reader.onload = () => resolve(reader.result);
    reader.onerror = error => reject(error);
});

export async function dataUrlToBlob(url: string): Promise<Blob> {
    return fetch(url).then(response => response.blob())
}

export async function compressImage(blob: Blob): Promise<Blob> {
    if (blob.size > MAX_IMG_SIZE_IN_BYTES) {
        blob = await compressAccurately(
            blob,
            {
                size: MAX_IMG_SIZE_IN_KB
            }
        )
    }
    return blob
}

export function getFileTypeFromName(name: string): string {
    return getFileTypeFromString(name, ".")
}

export function getFileTypeFromBlob(blob: Blob): string {
    return getFileTypeFromString(blob.type, "/")
}

function getFileTypeFromString(string: string, splitOn: string): string {
    let fileType = string.slice(
        (Math.max(0, string.lastIndexOf(splitOn)) || Infinity) + 1
    );
    fileType = fileType.toLowerCase()
    return fileType
}

const MAX_IMG_SIZE_IN_BYTES: number = 200_000;

const MAX_IMG_SIZE_IN_KB: number = 200;
