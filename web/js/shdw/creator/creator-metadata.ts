import {PublicKey} from "@solana/web3.js";
import * as DapSdk from "@dap-cool/sdk";
import {ShdwDrive} from "@shadow-drive/sdk";
import {version} from "../config";
import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
import {deriveAtaPda, getTokenAccount} from "../../anchor/pda/get-token-account";
import {SHDW} from "../../anchor/util/constants";

export interface CreatorMetadata {
    url: PublicKey
    bio: string | null
    logo: string | null
    banner: string | null
    shadowAta: ShadowAta
}

export interface Logo {
    name: string
    dataUrl: string
}

export interface ShadowAta {
    balance: number
    address: PublicKey | null
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

export async function getMetadata(provider: AnchorProvider, program: Program<SplToken>, url: PublicKey): Promise<CreatorMetadata> {
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
    const shadowAta = await getShadowAta(
        provider,
        program
    );
    return {
        url: url,
        bio: fetched.bio,
        logo: logo,
        banner: fetched.banner,
        shadowAta: shadowAta
    }
}

export async function getShadowAta(provider: AnchorProvider, program: Program<SplToken>): Promise<ShadowAta> {
    const ata = await deriveAtaPda(
        provider,
        SHDW
    );
    let shadowAta: ShadowAta;
    try {
        const tokenAccount = await getTokenAccount(
            program,
            ata
        );
        shadowAta = {
            balance: tokenAccount.amount.toNumber(),
            address: ata
        }
    } catch (error) {
        console.log(error);
        shadowAta = {
            balance: 0,
            address: null
        }
    }
    return shadowAta
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
