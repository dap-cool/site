import {PublicKey} from "@solana/web3.js";
import * as DapSdk from "@dap-cool/sdk";

export interface Metadata {
    url: PublicKey
    bio: string | null
    logo: string | null
    banner: string | null
}

export interface Logo {
    name: string
    dataUrl: string
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
    const url_ = DapSdk.buildUrl(
        url
    );
    const fetched = await fetch(url_ + "meta.json")
        .then(response => response.json());
    let logo;
    if (fetched.logo) {
        logo = url_ + fetched.logo;
    }
    return {
        url: url,
        bio: fetched.bio,
        logo: logo,
        banner: fetched.banner
    }
}
