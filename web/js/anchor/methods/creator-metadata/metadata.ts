import {PublicKey} from "@solana/web3.js";
import * as DapSdk from "@dap-cool/sdk";

export interface Metadata {
    bio: string | null
    logo: string | null
    banner: string | null
}

export function encode(metadata: Metadata): File {
    const json = JSON.stringify(metadata);
    const textEncoder = new TextEncoder();
    const bytes = textEncoder.encode(json);
    const blob: Blob = new Blob([bytes], {
        type: "application/json;charset=utf-8"
    });
    return new File([blob], "meta.json");
}

export async function getMetadata(url: PublicKey): Promise<Metadata> {
    console.log("fetching creator meta-data");
    return await fetch(DapSdk.buildUrl(url) + "meta.json")
        .then(response => response.json()) as Metadata;
}
