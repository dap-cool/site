import {PublicKey} from "@solana/web3.js";
import {Program, BN} from "@project-serum/anchor";
import {DapCool} from "../idl";
import {Collection} from "./collector-pda";

export interface CollectionAuthority {
    // meta
    handle: string
    name: string
    symbol: string
    index: number
    // for other pda derivations
    mint: PublicKey
    collection: PublicKey
    numMinted: number // decoded as BN
    // pda for program invocation
    pda: PublicKey
}

interface Raw {
    handle: string
    name: string
    symbol: string
    index: number
    mint: PublicKey
    collection: PublicKey
    numMinted: BN.BN
}

interface FromElm {
    handle: string
    name: string
    symbol: string
    index: number
    mint: string
    collection: string
    numMinted: number
    pda: string
}

export function decodeAuthorityPda(more: FromElm): CollectionAuthority {
    let maybeCollection;
    if (more.collection) {
        maybeCollection = new PublicKey(more.collection);
    } else {
        maybeCollection = null;
    }
    return {
        handle: more.handle,
        name: more.name,
        symbol: more.symbol,
        index: more.index,
        mint: new PublicKey(more.mint),
        collection: maybeCollection,
        numMinted: more.numMinted,
        pda: new PublicKey(more.pda),
    }
}

export async function getManyAuthorityPdaForCollector(
    program: Program<DapCool>,
    collections: Collection[]
): Promise<CollectionAuthority[]> {
    // derive all authority pda
    const derived: PublicKey[] = await Promise.all(
        collections.map( async (collection) =>
            await deriveAuthorityPda(program, collection.handle, collection.index)
        )
    )
    // fetch all
    return await getManyAuthorityPda(program, derived)
}

async function getManyAuthorityPda(
    program: Program<DapCool>,
    pdaArray: PublicKey[]
): Promise<CollectionAuthority[]> {
    const fetched = await program.account.authority.fetchMultiple(pdaArray);
    return await Promise.all(
        fetched.filter(Boolean).map(async (obj) => {
                const raw = obj as Raw;
                const pda = await deriveAuthorityPda(program, raw.handle, raw.index);
                return {
                    handle: raw.handle,
                    name: raw.name,
                    symbol: raw.symbol,
                    index: raw.index,
                    mint: raw.mint,
                    collection: raw.collection,
                    numMinted: raw.numMinted.toNumber(),
                    pda: pda,
                } as CollectionAuthority
            }
        )
    )
}

export async function getAuthorityPda(
    program: Program<DapCool>,
    handle: string,
    index: number
): Promise<CollectionAuthority> {
    const pda: PublicKey = await deriveAuthorityPda(program, handle, index);
    const authority = await program.account.authority.fetch(pda);
    console.log(authority);
    return {
        // meta
        handle: authority.handle,
        name: authority.name,
        symbol: authority.symbol,
        index: authority.index,
        // for other pda derivations
        mint: authority.mint,
        collection: authority.collection,
        numMinted: authority.numMinted.toNumber(),
        // pda for program invocation
        pda: pda
    } as CollectionAuthority
}

export async function deriveAuthorityPda(
    program: Program<DapCool>,
    handle: string,
    index: number
): Promise<PublicKey> {
    console.log(index);
    // derive pda
    let pda, _;
    [pda, _] = await PublicKey.findProgramAddress(
        [
            Buffer.from(handle),
            Buffer.from([index])
        ],
        program.programId
    );
    return pda
}
