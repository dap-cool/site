/* https://developer.mozilla.org/en-US/docs/Web/API/FileReader/readAsDataURL */
import {compressAccurately} from "image-conversion";

export function readImageFromElementId(elementId: any, file: any): void {
    const img: any = document.getElementById(
        elementId
    );
    const reader = new FileReader();
    reader.addEventListener("load", (readEvent) => {
        img.src = readEvent.target.result;
    });
    reader.readAsDataURL(file);
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
