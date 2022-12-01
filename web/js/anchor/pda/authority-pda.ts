import {PublicKey} from "@solana/web3.js";
import {Program, BN, SplToken, AnchorProvider} from "@project-serum/anchor";
import {DapCool} from "../idl/dap";
import {MplTokenMetadata} from "../idl/mpl";
import {Collection} from "./collector-pda";
import {
    MPL_PREFIX,
    MPL_TOKEN_METADATA_PROGRAM_ID,
    SPL_ASSOCIATED_TOKEN_PROGRAM_ID,
    SPL_TOKEN_PROGRAM_ID
} from "../util/constants";
import {Handle} from "./handle-pda";

export interface CollectionAuthority {
    // meta
    meta: {
        handle: string
        name: string
        symbol: string
        index: number
        uri: string
        numMinted: number // decoded as BN
    }
    // accounts
    accounts: {
        pda: PublicKey
        mint: PublicKey
        collection: PublicKey | null
        // associated-token-account
        ata: {
            balance: number
        } | null
    }
}

interface RawCollectionAuthority {
    handle: string
    name: string
    symbol: string
    index: number
    uri: string
    mint: PublicKey
    collection: PublicKey
    numMinted: BN.BN
}

interface RawMplTokenMetadata {
    collection: {
        verified: boolean
        key: PublicKey
    } | null
}

interface RawSplToken {
    mint: PublicKey
    amount: BN.BN
}

interface FromElm {
    meta: {
        handle: string
        name: string
        symbol: string
        index: number
        uri: string
        numMinted: number
    }
    accounts: {
        pda: string
        mint: string
        collection: string
        ata: {
            balance: number
        } | null
    }
}

export function decodeAuthorityPda(fromElm: FromElm): CollectionAuthority {
    let maybeCollection;
    if (fromElm.accounts.collection) {
        maybeCollection = new PublicKey(fromElm.accounts.collection);
    } else {
        maybeCollection = null;
    }
    return {
        meta: fromElm.meta,
        accounts: {
            pda: new PublicKey(fromElm.accounts.pda),
            mint: new PublicKey(fromElm.accounts.mint),
            collection: maybeCollection,
            ata: fromElm.accounts.ata
        }
    }
}

export async function getManyAuthorityPdaForCollector(
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        mpl: Program<MplTokenMetadata>,
        token: Program<SplToken>
    },
    collections: Collection[]
): Promise<CollectionAuthority[]> {
    // derive all authority pda
    const authorityPdaArray: { authorityPda: PublicKey; collection: Collection }[] = await Promise.all(
        collections.map(async (collection) => {
                const authorityPda = await deriveAuthorityPda(programs.dap, collection.handle, collection.index);
                return {
                    authorityPda,
                    collection
                }
            }
        )
    );
    const derived0: PublicKey[] = authorityPdaArray.map(obj =>
        obj.authorityPda
    );
    // derive associated-token-account array
    const ataPdaArray: PublicKey[] = await Promise.all(
        collections.map(async (collection) =>
            await deriveAtaPda(provider, collection.mint)
        )
    );
    // derive mpl token-metadata array
    const mplTokenMetadataPdaArray: PublicKey[] = await Promise.all(
        collections.map(async (collection) =>
            await deriveMplTokenMetadataPda(provider, collection.mint)
        )
    );
    // fetch authority array
    const authorityArray: CollectionAuthority[] = await getManyAuthorityPda(
        programs.dap,
        derived0
    );
    // fetch mpl token-metadata array
    const mplTokenMetadataArray = (await programs.mpl.account.Metadata.fetchMultiple(mplTokenMetadataPdaArray)).map(obj =>
        obj as RawMplTokenMetadata
    );
    console.log(mplTokenMetadataArray);
    // fetch associated-token-account array
    const ataArray: RawSplToken[] = (await programs.token.account.token.fetchMultiple(ataPdaArray)).map(obj =>
        obj as RawSplToken
    );
    // replace master-mint with copied-mint
    // replace master-collection with copied-collection
    // set ata to derivation
    return authorityPdaArray.map(obj => {
            // find collection-authority matching copied-mint
            const foundAuthority = authorityArray.find(ca =>
                ca.accounts.pda.equals(obj.authorityPda)
            )
            // find collection-authority matching copied-collection
            const maybeFoundCollection = mplTokenMetadataArray.find(mpl =>
                mpl.collection.verified && mpl.collection.key.equals(foundAuthority.accounts.collection)
            )
            // find associated-token-account matching copied-mint
            const foundAta = ataArray.find(ata =>
                ata.mint.equals(obj.collection.mint)
            )
            console.log(foundAta);
            foundAuthority.accounts.mint = obj.collection.mint // replace master-mint with copied-mint
            if (maybeFoundCollection) {
                // don't change anything because master-collection == copied-collection
            } else {
                foundAuthority.accounts.collection = null; // nullify master-collection to represent empty copied-collection
            }
            foundAuthority.accounts.ata = {
                balance: foundAta.amount.toNumber() // replace ata
            }
            return foundAuthority
        }
    )
}

async function deriveMplTokenMetadataPda(provider: AnchorProvider, mint: PublicKey): Promise<PublicKey> {
    let pda, _;
    [pda, _] = await PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            mint.toBuffer(),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    );
    return pda
}

async function deriveAtaPda(provider: AnchorProvider, mint: PublicKey): Promise<PublicKey> {
    let ataPda: PublicKey, _;
    [ataPda, _] = await PublicKey.findProgramAddress(
        [
            provider.publicKey.toBuffer(),
            SPL_TOKEN_PROGRAM_ID.toBuffer(),
            mint.toBuffer()
        ],
        SPL_ASSOCIATED_TOKEN_PROGRAM_ID
    )
    return ataPda
}

export async function getManyAuthorityPdaForCreator(
    program: Program<DapCool>,
    handle: Handle
): Promise<CollectionAuthority[]> {
    // derive pda array
    const pdaArray: PublicKey[] = await Promise.all(
        Array.from(new Array(handle.numCollections), async (_, ix) => {
                // derive authority for each collection
                const index = ix + 1;
                return await deriveAuthorityPda(program, handle.handle, index)
            }
        )
    );
    return await getManyAuthorityPda(
        program,
        pdaArray
    )
}

async function getManyAuthorityPda(
    program: Program<DapCool>,
    authorityPdaArray: PublicKey[]
): Promise<CollectionAuthority[]> {
    // fetch many collection authorities
    const authorityArray = await program.account.authority.fetchMultiple(authorityPdaArray);
    return await Promise.all(
        authorityArray.map(async (obj) => {
                const raw = obj as RawCollectionAuthority;
                const pda = await deriveAuthorityPda(program, raw.handle, raw.index);
                return {
                    meta: {
                        handle: raw.handle,
                        name: raw.name,
                        symbol: raw.symbol,
                        index: raw.index,
                        uri: raw.uri,
                        numMinted: raw.numMinted.toNumber(),
                    },
                    accounts: {
                        pda: pda,
                        mint: raw.mint,
                        collection: raw.collection,
                        ata: null // replaced later with on-chain token-balance fetched in bulk
                    }
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
    const authority = await program.account.authority.fetch(pda) as RawCollectionAuthority;
    console.log(authority);
    return {
        meta: {
            handle: authority.handle,
            name: authority.name,
            symbol: authority.symbol,
            index: authority.index,
            uri: authority.uri,
            numMinted: authority.numMinted.toNumber(),
        },
        accounts: {
            pda: pda,
            mint: authority.mint,
            collection: authority.collection,
            ata: null // no ata because this is the master-edition
        }
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
