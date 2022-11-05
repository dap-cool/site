import {PublicKey} from "@solana/web3.js";
import {AnchorProvider, BN, Program} from "@project-serum/anchor";
import {SomosCrowd} from "../idl";

export interface Authority {
    // meta
    name: string
    symbol: string
    index: string
    // for other pda derivations
    mint: PublicKey
    collection: PublicKey
    numMinted: BN
    // pda for program invocation
    pda: PublicKey
}

export async function getAuthorityPda(program: Program<SomosCrowd>, handle: string, index: number): Promise<Authority> {
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
    } as Authority
}

export async function deriveAuthorityPda(
    program: Program<SomosCrowd>,
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
