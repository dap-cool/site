/* https://developer.mozilla.org/en-US/docs/Web/API/FileReader/readAsDataURL */
import {compressAccurately} from "image-conversion";

export function readImageFromElementId(elementId: any, file: any): void {
    let img: any = document.getElementById(
        elementId
    );
    img.src = readBlob(file);
}

export function readBlob(blob: Blob): string {
    let base64: string;
    const reader = new FileReader();
    reader.addEventListener("load", (readEvent) => {
        console.log(readEvent);
        console.log(readEvent.target.result as string);
        base64 = readEvent.target.result as string;
    });
    reader.readAsDataURL(blob);
    console.log(base64);
    return base64
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

const MAX_IMG_SIZE_IN_BYTES: number = 200_000;

const MAX_IMG_SIZE_IN_KB: number = 200;
