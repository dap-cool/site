import {AnchorProvider, BN, Program, SplToken} from "@project-serum/anchor";
import {Keypair, PublicKey, SystemProgram, SYSVAR_RENT_PUBKEY} from "@solana/web3.js";
import {
    CollectionAuthority,
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
        const collectorPda: PublicKey = await deriveCollectorPda(
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
        const collectionPda: PublicKey = await deriveCollectionPda(
            provider,
            programs.dap,
            collectorNextCollectionIndex
        );
        // derive handle pda
        const handlePda: PublicKey = await deriveHandlePda(
            programs.dap,
            handle
        );
        // get authority pda
        const authority: CollectionAuthority = await getAuthorityPda(
            programs.dap,
            handle,
            index
        );
        // derive metadata
        let metadata: PublicKey, _;
        [metadata, _] = await PublicKey.findProgramAddress(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                authority.accounts.mint.toBuffer(),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        )
        // derive master-edition
        let masterEdition: PublicKey;
        [masterEdition, _] = await PublicKey.findProgramAddress(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                authority.accounts.mint.toBuffer(),
                Buffer.from(MPL_EDITION),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        )
        // derive master-edition-ata
        let masterEditionAta: PublicKey;
        [masterEditionAta, _] = await PublicKey.findProgramAddress(
            [
                authority.accounts.pda.toBuffer(),
                SPL_TOKEN_PROGRAM_ID.toBuffer(),
                authority.accounts.mint.toBuffer()
            ],
            SPL_ASSOCIATED_TOKEN_PROGRAM_ID
        )
        // derive key-pair for new-edition-mint
        const newMint: Keypair = Keypair.generate();
        // derive new-metadata
        let newMetadata: PublicKey;
        [newMetadata, _] = await PublicKey.findProgramAddress(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                newMint.publicKey.toBuffer(),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        )
        // derive new-edition
        let newEdition: PublicKey;
        [newEdition, _] = await PublicKey.findProgramAddress(
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
        let newEditionMark: PublicKey;
        [newEditionMark, _] = await PublicKey.findProgramAddress(
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
        )
        // invoke rpc
        console.log("minting new copy");
        await programs.dap.methods
            .mintNewCopy(index as any)
            .accounts(
                {
                    collector: collectorPda,
                    collectionPda: collectionPda,
                    handle: handlePda,
                    authority: authority.accounts.pda,
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
        const collectorPda: PublicKey = await deriveCollectorPda(
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
        const lastCollectionPda: PublicKey = await deriveCollectionPda(
            provider,
            programs.dap,
            collector.numCollected
        );
        // fetch last collected
        const lastCollected = await getCollectionPda(
            programs.dap,
            lastCollectionPda
        );
        // derive handle pda
        const handlePda: PublicKey = await deriveHandlePda(
            programs.dap,
            handle
        );
        // get authority pda
        const authority: CollectionAuthority = await getAuthorityPda(
            programs.dap,
            handle,
            index
        );
        // derive collection metadata
        let collectionMetadata: PublicKey, _;
        [collectionMetadata, _] = await PublicKey.findProgramAddress(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                authority.accounts.collection.toBuffer(),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        );
        // derive collection master-edition
        let collectionMasterEdition: PublicKey;
        [collectionMasterEdition, _] = await PublicKey.findProgramAddress(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                authority.accounts.collection.toBuffer(),
                Buffer.from(MPL_EDITION),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        );
        // derive new-metadata
        let newMetadata: PublicKey;
        [newMetadata, _] = await PublicKey.findProgramAddress(
            [
                Buffer.from(MPL_PREFIX),
                MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                lastCollected.mint.toBuffer(),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        )
        // invoke rpc
        await programs.dap.methods
            .addNewCopyToCollection(index as any)
            .accounts(
                {
                    collector: collectorPda,
                    collectionPda: lastCollectionPda,
                    handle: handlePda,
                    authority: authority.accounts.pda,
                    mint: authority.accounts.mint,
                    collection: authority.accounts.collection,
                    collectionMetadata: collectionMetadata,
                    collectionMasterEdition: collectionMasterEdition,
                    newMint: lastCollected.mint,
                    newMetadata: newMetadata,
                    payer: provider.wallet.publicKey,
                    tokenProgram: SPL_TOKEN_PROGRAM_ID,
                    metadataProgram: MPL_TOKEN_METADATA_PROGRAM_ID,
                    systemProgram: SystemProgram.programId,
                    rent: SYSVAR_RENT_PUBKEY,
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
