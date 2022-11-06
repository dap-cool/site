import {PublicKey} from "@solana/web3.js";
import {BN, Program} from "@project-serum/anchor";
import {DapCool} from "../idl";

export interface CollectionAuthority {
    // meta
    name: string
    symbol: string
    index: number
    // for other pda derivations
    mint: PublicKey
    collection: PublicKey
    numMinted: BN
    // pda for program invocation
    pda: PublicKey
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
        numMinted: authority.numMinted,
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
