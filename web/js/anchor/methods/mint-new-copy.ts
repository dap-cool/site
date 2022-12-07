import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
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
    getAllCollectionPda,
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
                newMint.publicKey.toBuffer(),
            ],
            MPL_TOKEN_METADATA_PROGRAM_ID
        );
        // build bumps
        const bumps = {
            handle: handlePda.bump,
            authority: authorityPda.bump,
            metadata: metadataBump,
            collectionMetadata: collectionMetadataBump,
            collectionMasterEdition: collectionMasterEditionBump,
            newMetadata: newMetadataBump,
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
                    handle: handlePda.address,
                    authority: authorityPda.address,
                    mint: authority.accounts.mint,
                    metadata: metadata,
                    collection: authority.accounts.collection,
                    collectionMetadata: collectionMetadata,
                    collectionMasterEdition: collectionMasterEdition,
                    newMint: newMint.publicKey,
                    newMetadata: newMetadata,
                    payer: provider.wallet.publicKey,
                    tokenProgram: SPL_TOKEN_PROGRAM_ID,
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
        lastCollectedAuthority.meta.numMinted = authority.meta.numMinted + 1;
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
