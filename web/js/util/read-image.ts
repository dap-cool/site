/* https://developer.mozilla.org/en-US/docs/Web/API/FileReader/readAsDataURL */
export function readImage(elementId: any, file: any): void {
    const img: any = document.getElementById(
        elementId
    );
    const reader = new FileReader();
    reader.addEventListener("load", (readEvent) => {
        img.src = readEvent.target.result;
    });
    reader.readAsDataURL(file);
}
