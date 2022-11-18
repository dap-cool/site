import {PublicKey} from "@solana/web3.js";
import {Program} from "@project-serum/anchor";
import {DapCool} from "../idl";

export interface CollectionAuthority {
    // meta
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

interface FromElm {
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
        name: more.name,
        symbol: more.symbol,
        index: more.index,
        mint: new PublicKey(more.mint),
        collection: maybeCollection,
        numMinted: more.numMinted,
        pda: new PublicKey(more.pda),
    }
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
        name: authority.name,
        symbol: authority.symbol,
        index: index,
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
