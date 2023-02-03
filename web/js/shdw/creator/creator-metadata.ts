import {PublicKey} from "@solana/web3.js";
import * as DapSdk from "@dap-cool/sdk";
import {ShdwDrive} from "@shadow-drive/sdk";
import {version} from "../config";

export interface CreatorMetadata {
    url: PublicKey
    bio: string | null
    logo: string | null
    banner: string | null
}

export interface Logo {
    name: string
    dataUrl: string
}

export function encode(metadata: CreatorMetadata): File {
    const json = JSON.stringify(metadata);
    const textEncoder = new TextEncoder();
    const bytes = textEncoder.encode(json);
    const blob: Blob = new Blob([bytes], {
        type: "application/json;charset=utf-8"
    });
    return new File([blob], "meta.json");
}

export async function getMetadata(url: PublicKey): Promise<CreatorMetadata> {
    console.log("fetching creator meta-data");
    const url_ = DapSdk.buildUrl(
        url
    );
    console.log(url_);
    const fetched = await fetch(
        url_ + "meta.json",
        {cache: "no-cache"}
    ).then(
        response => response.json()
    );
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

export async function editMetadata(metadata: CreatorMetadata, drive: ShdwDrive): Promise<void> {
    const url = DapSdk.buildUrl(
        metadata.url
    ) + "meta.json";
    const encoded = encode(
        metadata
    );
    await drive.editFile(
        metadata.url,
        url,
        encoded,
        version
    );
}
