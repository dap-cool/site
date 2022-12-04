import {AnchorProvider, BN, Program, SplToken} from "@project-serum/anchor";
import {Keypair, PublicKey, SystemProgram, SYSVAR_RENT_PUBKEY} from "@solana/web3.js";
import {buildClient, buildUrl, provision, uploadMultipleFiles} from "@dap-cool/sdk";
import {ShdwDrive} from "@shadow-drive/sdk";
import {getHandlePda, Handle} from "../pda/handle-pda";
import {
    CollectionAuthority,
    deriveAuthorityPda,
    getManyAuthorityPdaForCollector,
    getManyAuthorityPdaForCreator
} from "../pda/authority-pda";
import {
    MPL_PREFIX,
    MPL_EDITION,
    MPL_TOKEN_METADATA_PROGRAM_ID,
    SPL_TOKEN_PROGRAM_ID,
    SPL_ASSOCIATED_TOKEN_PROGRAM_ID
} from "../util/constants";
import {buildMetaData, readLogo} from "../../shdw/shdw";
import {DapCool} from "../idl/dap";
import {deriveCollectorPda, getAllCollectionPda, getCollectorPda} from "../pda/collector-pda";
import {Creator} from "../pda/creator-pda";

export interface Form {
    step: number
    retries: number
    meta: {
        name: string
        symbol: string
    }
    shdw: {
        account: PublicKey
        drive: ShdwDrive | null
    } | null
}

export async function creatNft(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        token: Program<SplToken>
    },
    handlePda: PublicKey,
    handle: Handle,
    form: Form
) {
    // fetch all collections from handle
    let collections = await getManyAuthorityPdaForCreator(programs.dap, handle);
    // fetch all collected from creator pda
    let collected;
    try {
        const collectorPda = await deriveCollectorPda(provider, programs.dap);
        const collector = await getCollectorPda(programs.dap, collectorPda);
        const collectedPda = await getAllCollectionPda(provider, programs.dap, collector);
        collected = await getManyAuthorityPdaForCollector(provider, programs, collectedPda);
    } catch (error) {
        console.log("could not find collector on-chain");
        collected = [];
    }
    // derive authority pda
    const authorityIndex: number = handle.numCollections + 1;
    const authorityPda: PublicKey = await deriveAuthorityPda(programs.dap, handle.handle, authorityIndex);
    // derive key-pair for mint
    const mint = Keypair.generate();
    // derive metadata
    let metadataPda, _;
    [metadataPda, _] = await PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            mint.publicKey.toBuffer(),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    );
    // derive master-edition
    let masterEditionPda;
    [masterEditionPda, _] = await PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            mint.publicKey.toBuffer(),
            Buffer.from(MPL_EDITION),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    );
    // derive master-edition-ata
    let masterEditionAta;
    [masterEditionAta, _] = await PublicKey.findProgramAddress(
        [
            authorityPda.toBuffer(),
            SPL_TOKEN_PROGRAM_ID.toBuffer(),
            mint.publicKey.toBuffer()
        ],
        SPL_ASSOCIATED_TOKEN_PROGRAM_ID
    );
    // read logo from input
    const logo: File = readLogo();
    // kick off upload steps
    if (form.step === 1) {
        try {
            // provision space
            form.shdw = await provision(
                provider.connection,
                provider.wallet,
                logo
            );
            // bump form
            form.step = 2;
            form.retries = 0;
            form.shdw.drive = null;
            // send to elm
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-creating-new-nft",
                        more: JSON.stringify(
                            {
                                global: {
                                    handle: handle.handle,
                                    wallet: provider.wallet.publicKey.toString(),
                                    collections: collections,
                                    collected: collected,
                                },
                                form: form
                            }
                        )
                    }
                )
            );
        } catch (error) {
            console.log(error);
            console.log("caught exception at step 1");
            // send to elm
            form.retries += 1;
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-creating-new-nft",
                        more: JSON.stringify(
                            {
                                global: {
                                    handle: handle.handle,
                                    wallet: provider.wallet.publicKey.toString(),
                                    collections: collections,
                                    collected: collected,
                                },
                                form: form
                            }
                        )
                    }
                )
            );
        }
    } else if (form.step === 2) {
        try {
            // build url
            const url = buildUrl(
                form.shdw.account
            );
            // build new client
            form.shdw.drive = await buildClient(
                provider.connection,
                provider.wallet
            );
            // build metadata
            const logoUrl = url + logo.name;
            const metadata: File = buildMetaData(
                handle.handle,
                authorityIndex,
                form.meta.name,
                form.meta.symbol,
                "description",
                logoUrl
            );
            // upload logo + metadata
            await uploadMultipleFiles(
                [logo, metadata],
                form.shdw.drive,
                form.shdw.account
            );
            // bump form
            form.step = 3;
            form.retries = 0;
            form.shdw.drive = null;
            // send to elm
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-creating-new-nft",
                        more: JSON.stringify(
                            {
                                global: {
                                    handle: handle.handle,
                                    wallet: provider.wallet.publicKey.toString(),
                                    collections: collections,
                                    collected: collected,
                                },
                                form: form
                            }
                        )
                    }
                )
            );
        } catch (error) {
            console.log(error);
            console.log("caught exception at step 2");
            // send to elm
            form.retries += 1;
            form.shdw.drive = null;
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-creating-new-nft",
                        more: JSON.stringify(
                            {
                                global: {
                                    handle: handle.handle,
                                    wallet: provider.wallet.publicKey.toString(),
                                    collections: collections,
                                    collected: collected,
                                },
                                form: form
                            }
                        )
                    }
                )
            );
        }
    } else if (form.step === 3) {
        try {
            // build url
            const url = buildUrl(
                form.shdw.account
            );
            const metadataUrl = url + "meta.json";
            // invoke rpc
            await programs.dap.methods
                .createNft(
                    form.meta.name as any,
                    form.meta.symbol as any,
                    metadataUrl as any,
                    new BN(2) // TODO; supply
                )
                .accounts(
                    {
                        handle: handlePda,
                        authority: authorityPda,
                        mint: mint.publicKey,
                        metadata: metadataPda,
                        masterEdition: masterEditionPda,
                        masterEditionAta: masterEditionAta,
                        payer: provider.wallet.publicKey,
                        tokenProgram: SPL_TOKEN_PROGRAM_ID,
                        associatedTokenProgram: SPL_ASSOCIATED_TOKEN_PROGRAM_ID,
                        metadataProgram: MPL_TOKEN_METADATA_PROGRAM_ID,
                        systemProgram: SystemProgram.programId,
                        rent: SYSVAR_RENT_PUBKEY,
                    }
                )
                .signers([mint])
                .rpc()
            // fetch pda
            console.log("mint", mint.publicKey.toString());
            // build response for elm
            const justCreated = {
                meta: {
                    handle: handle.handle,
                    name: form.meta.name,
                    symbol: form.meta.symbol,
                    index: authorityIndex,
                    uri: metadataUrl,
                    numMinted: 0,
                },
                accounts: {
                    pda: authorityPda,
                    mint: mint.publicKey,
                    collection: null,
                    ata: null
                }
            } as CollectionAuthority;
            // concat
            collections = collections.concat([justCreated]);
            // send to elm
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-created-new-nft",
                        more: JSON.stringify(
                            {
                                global: {
                                    handle: handle.handle,
                                    wallet: provider.wallet.publicKey.toString(),
                                    collections: collections,
                                    collected: collected,
                                },
                                collection: justCreated
                            }
                        )
                    }
                )
            );
        } catch (error) {
            console.log(error);
            console.log("caught exception at step 3");
            // send to elm
            form.retries += 1;
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-creating-new-nft",
                        more: JSON.stringify(
                            {
                                global: {
                                    handle: handle.handle,
                                    wallet: provider.wallet.publicKey.toString(),
                                    collections: collections,
                                    collected: collected,
                                },
                                form: form
                            }
                        )
                    }
                )
            );
        }
    }
}

export async function createCollection(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        token: Program<SplToken>
    },
    creator: Creator,
    authority: CollectionAuthority
) {
    try {
        // fetch handle obj
        const handle = await getHandlePda(programs.dap, creator.handle);
        // fetch all collections from handle
        let collections = await getManyAuthorityPdaForCreator(programs.dap, handle);
        // fetch all collected from creator pda
        let collected;
        try {
            const collectorPda = await deriveCollectorPda(provider, programs.dap);
            const collector = await getCollectorPda(programs.dap, collectorPda);
            const collectedPda = await getAllCollectionPda(provider, programs.dap, collector);
            collected = await getManyAuthorityPdaForCollector(provider, programs, collectedPda);
        } catch (error) {
            console.log("could not find collector on-chain");
            collected = [];
        }
        // derive key-pair for collection
        const collection = Keypair.generate();
        // derive collection metadata
        let collectionMetadata, _;
        [collectionMetadata, _] = await PublicKey.findProgramAddress(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                collection.publicKey.toBuffer(),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        )
        // derive collection master-edition
        let collectionMasterEdition;
        [collectionMasterEdition, _] = await PublicKey.findProgramAddress(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                collection.publicKey.toBuffer(),
                Buffer.from(MPL_EDITION),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        )
        // derive collection master-edition-ata
        let collectionMasterEditionAta;
        [collectionMasterEditionAta, _] = await PublicKey.findProgramAddress(
            [
                authority.accounts.pda.toBuffer(),
                SPL_TOKEN_PROGRAM_ID.toBuffer(),
                collection.publicKey.toBuffer()
            ],
            SPL_ASSOCIATED_TOKEN_PROGRAM_ID
        )
        // invoke rpc
        await programs.dap.methods
            .createCollection(authority.meta.index as any)
            .accounts(
                {
                    handle: creator.handle,
                    authority: authority.accounts.pda,
                    collection: collection.publicKey,
                    collectionMetadata: collectionMetadata,
                    collectionMasterEdition: collectionMasterEdition,
                    collectionMasterEditionAta: collectionMasterEditionAta,
                    payer: provider.wallet.publicKey,
                    tokenProgram: SPL_TOKEN_PROGRAM_ID,
                    associatedTokenProgram: SPL_ASSOCIATED_TOKEN_PROGRAM_ID,
                    metadataProgram: MPL_TOKEN_METADATA_PROGRAM_ID,
                    systemProgram: SystemProgram.programId,
                    rent: SYSVAR_RENT_PUBKEY,
                }
            )
            .signers([collection])
            .rpc()
        console.log("collection", collection.publicKey.toString());
        // build response for elm
        const justMarked = {
            meta: authority.meta,
            accounts: {
                pda: authority.accounts.pda,
                mint: authority.accounts.mint,
                collection: collection.publicKey,
                ata: null
            }
        } as CollectionAuthority;
        // filter out before-marked
        collections = collections.filter(c => !c.accounts.mint.equals(authority.accounts.mint));
        // concat
        collections = collections.concat([justMarked]);
        // send success to elm
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: "creator-created-new-collection",
                    more: JSON.stringify(
                        {
                            global: {
                                handle: handle.handle,
                                wallet: provider.wallet.publicKey.toString(),
                                collections: collections,
                                collected: collected,
                            },
                            collection: justMarked
                        }
                    )
                }
            )
        );
    } catch (error) {
        console.log(error);
        // send caught exception to elm
        app.ports.exception.send(
            "caught exception creating new collection!"
        );
    }
}
