import {AnchorProvider, BN, Program, SplToken} from "@project-serum/anchor";
import {Keypair, PublicKey, SystemProgram, SYSVAR_RENT_PUBKEY} from "@solana/web3.js";
import {
    CollectionAuthority, deriveAuthorityPda,
    getAuthorityPda,
    getManyAuthorityPdaForCollector,
    getManyAuthorityPdaForCreator
} from "../pda/authority-pda";
import {deriveHandlePda, getHandlePda} from "../pda/handle-pda";
import {
    MPL_EDITION,
    MPL_PREFIX,
    MPL_TOKEN_METADATA_PROGRAM_ID,
    SPL_ASSOCIATED_TOKEN_PROGRAM_ID,
    SPL_TOKEN_PROGRAM_ID
} from "../util/constants";
import {DapCool} from "../idl/dap";
import {
    deriveCollectionPda,
    deriveCollectorPda,
    getAllButLastCollectionPda,
    getAllCollectionPda, getCollectionPda,
    getCollectorPda
} from "../pda/collector-pda";
import {deriveCreatorPda, getCreatorPda} from "../pda/creator-pda";
import {deriveVerifiedPda} from "../pda/verified-pda";

export async function mintNewCopy(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        token: Program<SplToken>
    },
    handle: string,
    index: number
) {
    try {
        // derive collector pda
        const collectorPda = await deriveCollectorPda(
            provider,
            programs.dap
        );
        // try getting collector
        let collected: CollectionAuthority[]
        let collectorNextCollectionIndex: number;
        try {
            // fetch collector
            const collector = await getCollectorPda(
                programs.dap,
                collectorPda
            );
            // fetch all collected
            const collectedPda = await getAllCollectionPda(provider, programs.dap, collector);
            collected = await getManyAuthorityPdaForCollector(provider, programs, collectedPda);
            // increment
            collectorNextCollectionIndex = collector.numCollected + 1;
        } catch (error) {
            console.log("could not find collector on-chain");
            collectorNextCollectionIndex = 1;
        }
        // derive collection pda
        const collectionPda = await deriveCollectionPda(
            provider,
            programs.dap,
            collectorNextCollectionIndex
        );
        // derive key-pair for new-edition-mint
        const newMint: Keypair = Keypair.generate();
        // derive verified pda
        const verifiedPda = deriveVerifiedPda(
            programs.dap,
            handle,
            index,
            newMint.publicKey
        );
        // derive handle pda
        const handlePda = await deriveHandlePda(
            programs.dap,
            handle
        );
        // derive authority pda with bump
        const authorityPda = await deriveAuthorityPda(
            programs.dap,
            handle,
            index
        );
        // get authority pda
        const authority: CollectionAuthority = await getAuthorityPda(
            programs.dap,
            handle,
            index
        );
        // derive metadata
        let metadata, metadataBump;
        [metadata, metadataBump] = PublicKey.findProgramAddressSync(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                authority.accounts.mint.toBuffer(),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        )
        // derive master-edition
        let masterEdition, masterEditionBump
        [masterEdition, masterEditionBump] = PublicKey.findProgramAddressSync(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                authority.accounts.mint.toBuffer(),
                Buffer.from(MPL_EDITION),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        )
        // derive master-edition-ata
        let masterEditionAta: PublicKey, _;
        [masterEditionAta, _] = PublicKey.findProgramAddressSync(
            [
                authority.accounts.pda.toBuffer(),
                SPL_TOKEN_PROGRAM_ID.toBuffer(),
                authority.accounts.mint.toBuffer()
            ],
            SPL_ASSOCIATED_TOKEN_PROGRAM_ID
        )
        // derive new-metadata
        let newMetadata, newMetadataBump;
        [newMetadata, newMetadataBump] = PublicKey.findProgramAddressSync(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                newMint.publicKey.toBuffer(),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        )
        // derive new-edition
        let newEdition, newEditionBump;
        [newEdition, newEditionBump] = PublicKey.findProgramAddressSync(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                newMint.publicKey.toBuffer(),
                Buffer.from(MPL_EDITION),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        )
        // derive new-edition-mark
        const n = authority.meta.numMinted + 1;
        const newEditionMarkLiteral = (new BN(n)).div(new BN(248)).toString();
        let newEditionMark, newEditionMarkBump;
        [newEditionMark, newEditionMarkBump] = PublicKey.findProgramAddressSync(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                authority.accounts.mint.toBuffer(),
                Buffer.from(MPL_EDITION),
                Buffer.from(newEditionMarkLiteral)
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        )
        // derive new-edition-ata
        let newEditionAta: PublicKey;
        [newEditionAta, _] = await PublicKey.findProgramAddress(
            [
                provider.wallet.publicKey.toBuffer(),
                SPL_TOKEN_PROGRAM_ID.toBuffer(),
                newMint.publicKey.toBuffer()
            ],
            SPL_ASSOCIATED_TOKEN_PROGRAM_ID
        );
        // build bumps
        const bumps = {
            handle: handlePda.bump,
            authority: authorityPda.bump,
            metadata: metadataBump,
            masterEdition: masterEditionBump,
            newMetadata: newMetadataBump,
            newEdition: newEditionBump,
            newEditionMark: newEditionMarkBump
        }
        // invoke rpc
        console.log("minting new copy");
        await programs.dap.methods
            .mintNewCopy(
                bumps as any,
                index as any
            )
            .accounts(
                {
                    collector: collectorPda.address,
                    collectionPda: collectionPda.address,
                    verified: verifiedPda.address,
                    handle: handlePda.address,
                    authority: authorityPda.address,
                    mint: authority.accounts.mint,
                    metadata: metadata,
                    masterEdition: masterEdition,
                    masterEditionAta: masterEditionAta,
                    newMint: newMint.publicKey,
                    newMetadata: newMetadata,
                    newEdition: newEdition,
                    newEditionMark: newEditionMark,
                    newEditionAta: newEditionAta,
                    payer: provider.wallet.publicKey,
                    tokenProgram: SPL_TOKEN_PROGRAM_ID,
                    associatedTokenProgram: SPL_ASSOCIATED_TOKEN_PROGRAM_ID,
                    metadataProgram: MPL_TOKEN_METADATA_PROGRAM_ID,
                    systemProgram: SystemProgram.programId,
                    rent: SYSVAR_RENT_PUBKEY,
                }
            ).signers([newMint])
            .rpc();
        // replace master-mint with copied-mint
        const lastCollectedAuthority = authority;
        lastCollectedAuthority.accounts.mint = newMint.publicKey;
        // replace master-copy with null (unmarked)
        lastCollectedAuthority.accounts.collection = null;
        // add associated-token-account balance
        lastCollectedAuthority.accounts.ata = {
            balance: 1
        };
        // increment num-minted
        lastCollectedAuthority.meta.numMinted = n;
        // build collected
        if (collectorNextCollectionIndex === 1) {
            collected = [lastCollectedAuthority];
        } else {
            collected.concat([lastCollectedAuthority]);
        }
        // fetch collections & set global
        let global;
        try {
            const creatorPda = await deriveCreatorPda(
                provider,
                programs.dap
            );
            const creator = await getCreatorPda(
                programs.dap,
                creatorPda
            );
            const fetchedHandle = await getHandlePda(
                programs.dap,
                creator.handle
            );
            const collections = await getManyAuthorityPdaForCreator(
                programs.dap,
                fetchedHandle
            );
            global = {
                handle: fetchedHandle.handle,
                wallet: provider.wallet.publicKey.toString(),
                collections: collections,
                collected: collected
            };
        } catch (error) {
            console.log("could not find creator on-chain");
            global = {
                wallet: provider.wallet.publicKey.toString(),
                collected: collected
            }
        }
        // send success to elm
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: "collector-collection-printed",
                    more: JSON.stringify(
                        {
                            master: authority,
                            copied: lastCollectedAuthority,
                            global: global
                        }
                    )
                }
            )
        );
    } catch (error) {
        console.log(error);
        // send caught exception to elm
        app.ports.exception.send(
            "caught exception printing collection!"
        );
    }
}

export async function addNewCopyToCollection(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>;
        token: Program<SplToken>
    },
    handle: string,
    index: number,
): Promise<void> {
    try {
        // derive collector pda
        const collectorPda = await deriveCollectorPda(
            provider,
            programs.dap
        );
        // fetch collector
        const collector = await getCollectorPda(
            programs.dap,
            collectorPda
        );
        // derive all but last collected
        const collectedPda = await getAllButLastCollectionPda(
            provider,
            programs.dap,
            collector
        );
        // fetch all but last collected
        const collectedButLast = await getManyAuthorityPdaForCollector(
            provider,
            programs,
            collectedPda
        );
        // derive last collected pda
        const lastCollectionPda = await deriveCollectionPda(
            provider,
            programs.dap,
            collector.numCollected
        );
        // fetch last collected
        const lastCollected = await getCollectionPda(
            programs.dap,
            lastCollectionPda
        );
        // derive verified pda
        const verifiedPda = deriveVerifiedPda(
            programs.dap,
            handle,
            index,
            lastCollected.mint
        );
        // derive handle pda
        const handlePda = await deriveHandlePda(
            programs.dap,
            handle
        );
        // derive authority pda with bump
        const authorityPda = await deriveAuthorityPda(
            programs.dap,
            handle,
            index
        );
        // get authority pda
        const authority: CollectionAuthority = await getAuthorityPda(
            programs.dap,
            handle,
            index
        );
        // derive collection metadata
        let collectionMetadata, collectionMetadataBump;
        [collectionMetadata, collectionMetadataBump] = PublicKey.findProgramAddressSync(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                authority.accounts.collection.toBuffer(),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        );
        // derive collection master-edition
        let collectionMasterEdition, collectionMasterEditionBump;
        [collectionMasterEdition, collectionMasterEditionBump] = PublicKey.findProgramAddressSync(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                authority.accounts.collection.toBuffer(),
                Buffer.from(MPL_EDITION),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        );
        // derive new-metadata
        let newMetadata, newMetadataBump;
        [newMetadata, newMetadataBump] = PublicKey.findProgramAddressSync(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                lastCollected.mint.toBuffer(),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        )
        // build bumps
        const bumps = {
            collector: collectorPda.bump,
            collectionPda: lastCollectionPda.bump,
            verified: verifiedPda.bump,
            handle: handlePda.bump,
            authority: authorityPda.bump,
            collectionMetadata: collectionMetadataBump,
            collectionMasterEdition: collectionMasterEditionBump,
            newMetadata: newMetadataBump
        }
        // invoke rpc
        await programs.dap.methods
            .addNewCopyToCollection(
                bumps as any,
                index as any
            )
            .accounts(
                {
                    collector: collectorPda.address,
                    collectionPda: lastCollectionPda.address,
                    verified: verifiedPda.address,
                    handle: handlePda.address,
                    authority: authority.accounts.pda,
                    collection: authority.accounts.collection,
                    collectionMetadata: collectionMetadata,
                    collectionMasterEdition: collectionMasterEdition,
                    newMint: lastCollected.mint,
                    newMetadata: newMetadata,
                    payer: provider.wallet.publicKey,
                    tokenProgram: SPL_TOKEN_PROGRAM_ID,
                    metadataProgram: MPL_TOKEN_METADATA_PROGRAM_ID,
                    systemProgram: SystemProgram.programId,
                }
            ).rpc()
        // build collected
        const lastCollectedAuthority = authority;
        lastCollectedAuthority.accounts.mint = lastCollected.mint;
        lastCollectedAuthority.accounts.ata = {
            balance: 1
        };
        const collected = collectedButLast.concat([lastCollectedAuthority]);
        // fetch collections & set global
        let global;
        try {
            const creatorPda = await deriveCreatorPda(
                provider,
                programs.dap
            );
            const creator = await getCreatorPda(
                programs.dap,
                creatorPda
            );
            const fetchedHandle = await getHandlePda(
                programs.dap,
                creator.handle
            );
            const collections = await getManyAuthorityPdaForCreator(
                programs.dap,
                fetchedHandle
            );
            global = {
                handle: fetchedHandle.handle,
                wallet: provider.wallet.publicKey.toString(),
                collections: collections,
                collected: collected
            };
        } catch (error) {
            console.log("could not find creator on-chain");
            global = {
                wallet: provider.wallet.publicKey.toString(),
                collected: collected
            }
        }
        // send success to elm
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: "collector-collection-marked",
                    more: JSON.stringify(
                        {
                            master: authority,
                            copied: lastCollectedAuthority,
                            global: global
                        }
                    )
                }
            )
        );
    } catch (error) {
        console.log(error);
        // send caught exception to elm
        app.ports.exception.send(
            "caught exception marking collection!"
        );
    }
}
