import {PublicKey} from "@solana/web3.js";
import {Program, SplToken, AnchorProvider} from "@project-serum/anchor";
import {DapCool} from "../idl/dap";
import {Collection} from "./collector-pda";
import {Handle} from "./handle-pda";
import {deriveAtaPda, RawSplTokenAccount} from "./get-token-account";

export interface AuthorityPda {
    address: PublicKey
    bump: number
}

export interface CollectionAuthority {
    meta: {
        handle: string
        index: number
        name: string
        symbol: string
        uri: string
        image: string
    }
    math: {
        numMinted: number // decoded as BN
        totalSupply: number // decoded as BN
        price: number // decoded as BN
        fee: number
    }
    accounts: {
        pda: PublicKey
        mint: PublicKey
        // associated-token-account
        ata: {
            balance: number
            address: PublicKey
        }
    }
}

interface RawCollectionAuthority {
    handle: string
    index: number
    mint: PublicKey
    name: string
    symbol: string
    uri: string
    image: number
    numMinted: any // encoded as BN
    totalSupply: any // encoded as BN
    price: any // encoded as BN
    fee: number
}

export async function getManyAuthorityPdaForCollector(
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        token: Program<SplToken>
    },
    collections: Collection[]
): Promise<CollectionAuthority[]> {
    // derive authority pda array
    const authorityPdaArray: AuthorityPda[] = await Promise.all(
        collections.map(async (collection) =>
            await deriveAuthorityPda(programs.dap, collection.handle, collection.index)
        )
    );
    // derive associated-token-account pda array
    const ataPdaArray: PublicKey[] = collections.map((collection: Collection) =>
        deriveAtaPda(provider, collection.mint)
    );
    // fetch authority array
    const authorityArray: CollectionAuthority[] = await getManyAuthorityPda(
        provider,
        programs.dap,
        authorityPdaArray
    );
    // join
    return await joinAtaWithAuthority(
        programs.token,
        authorityArray,
        ataPdaArray
    )
}

export async function getManyAuthorityPdaForCreator(
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        token: Program<SplToken>
    },
    handle: Handle
): Promise<CollectionAuthority[]> {
    // derive authority pda array
    const authorityPdaArray: AuthorityPda[] = await Promise.all(
        Array.from(new Array(handle.numCollections), async (_, ix) => {
                // derive authority for each collection
                const index = ix + 1;
                return await deriveAuthorityPda(programs.dap, handle.handle, index)
            }
        )
    );
    // fetch collection array
    const authorityArray: CollectionAuthority[] = await getManyAuthorityPda(
        provider,
        programs.dap,
        authorityPdaArray
    );
    // derive associated-token-account pda array
    const ataPdaArray: PublicKey[] = authorityArray.map((authority: CollectionAuthority) =>
        deriveAtaPda(provider, authority.accounts.mint)
    );
    // join
    return await joinAtaWithAuthority(
        programs.token,
        authorityArray,
        ataPdaArray
    )
}

async function getManyAuthorityPda(
    provider: AnchorProvider,
    program: Program<DapCool>,
    authorityPdaArray: AuthorityPda[]
): Promise<CollectionAuthority[]> {
    // fetch many collection authorities
    const authorityArray = await program.account.authority.fetchMultiple(
        authorityPdaArray.map(pda => pda.address)
    );
    return await Promise.all(
        authorityArray.map(async (obj) => {
                const raw = obj as RawCollectionAuthority;
                const pda = await deriveAuthorityPda(
                    program,
                    raw.handle,
                    raw.index
                );
                const ata = deriveAtaPda(
                    provider,
                    raw.mint
                );
                return {
                    meta: {
                        handle: raw.handle,
                        index: raw.index,
                        name: raw.name,
                        symbol: raw.symbol,
                        uri: raw.uri,
                        image: getImageUrl(raw.uri, raw.image)
                    },
                    math: {
                        numMinted: raw.numMinted.toNumber(),
                        totalSupply: raw.totalSupply.toNumber(),
                        price: raw.price.toNumber(),
                        fee: raw.fee
                    },
                    accounts: {
                        pda: pda.address,
                        mint: raw.mint,
                        ata: {
                            balance: 0, // replaced later with on-chain token-balance fetched in bulk
                            address: ata
                        }
                    }
                } as CollectionAuthority
            }
        )
    )
}

async function joinAtaWithAuthority(
    program: Program<SplToken>,
    authorityArray: CollectionAuthority[],
    ataPdaArray: PublicKey[]
): Promise<CollectionAuthority[]> {
    // fetch associated-token-account array
    const ataArray: RawSplTokenAccount[] = (await program.account.token.fetchMultiple(ataPdaArray)).map(obj =>
        obj as RawSplTokenAccount
    ).filter(Boolean);
    // join
    return authorityArray.map((authority: CollectionAuthority) => {
            const maybeFoundAta = ataArray.find(ata => ata.mint.equals(authority.accounts.mint));
            if (maybeFoundAta) {
                authority.accounts.ata = {
                    balance: maybeFoundAta.amount.toNumber(),
                    address: authority.accounts.ata.address
                };
            }
            return authority
        }
    )
}

export async function getAuthorityPda(
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        token: Program<SplToken>
    },
    authorityPda: AuthorityPda,
): Promise<CollectionAuthority> {
    // fetch authority
    const raw: RawCollectionAuthority = await programs.dap.account.authority.fetch(
        authorityPda.address
    ) as RawCollectionAuthority;
    // derive & fetch associated-token-account
    const ataPda = deriveAtaPda(
        provider,
        raw.mint
    );
    let balance: number;
    try {
        const ata = await programs.token.account.token.fetch(
            ataPda
        ) as RawSplTokenAccount;
        balance = ata.amount.toNumber();
    } catch (error) {
        console.log("provider does not have existing token balance.")
        balance = 0;
    }
    // build collection authority
    return {
        meta: {
            handle: raw.handle,
            index: raw.index,
            name: raw.name,
            symbol: raw.symbol,
            uri: raw.uri,
            image: getImageUrl(raw.uri, raw.image),
        },
        math: {
            numMinted: raw.numMinted.toNumber(),
            totalSupply: raw.totalSupply.toNumber(),
            price: raw.price.toNumber(),
            fee: raw.fee
        },
        accounts: {
            pda: authorityPda.address,
            mint: raw.mint,
            ata: {
                balance: balance,
                address: ataPda
            }
        }
    } as CollectionAuthority
}

export function getImageUrl(uri: string, type: number): string {
    const name = "logo." + decodeFileType(type);
    uri = uri.replace("meta.json", name);
    return uri
}

function decodeFileType(encoded: number): string {
    let decoded: string;
    switch (encoded) {
        case 1: {
            decoded = "jpg";
            break
        }
        case 2: {
            decoded = "jpeg";
            break
        }
        case 3: {
            decoded = "png";
            break
        }
    }
    return decoded
}

export async function deriveAuthorityPda(
    program: Program<DapCool>,
    handle: string,
    index: number
): Promise<AuthorityPda> {
    let pda, bump;
    [pda, bump] = await PublicKey.findProgramAddress(
        [
            Buffer.from(SEED),
            Buffer.from(handle),
            Buffer.from([index])
        ],
        program.programId
    );
    return {
        address: pda,
        bump
    }
}

const SEED = "authority";
