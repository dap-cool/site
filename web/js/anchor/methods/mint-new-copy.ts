import {AnchorProvider, BN, Program, SplToken, web3} from "@project-serum/anchor";
import {Keypair, PublicKey} from "@solana/web3.js";
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
import {MplTokenMetadata} from "../idl/mpl";
import {deriveCollectionPda, deriveCollectorPda, getAllCollectionPda, getCollectorPda} from "../pda/collector-pda";
import {deriveCreatorPda, getCreatorPda} from "../pda/creator-pda";

export async function mintNewCopy(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        mpl: Program<MplTokenMetadata>,
        token: Program<SplToken>
    },
    handle: string,
    index: number
) {
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
    [metadata, _] = await web3.PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            authority.accounts.mint.toBuffer(),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    )
    // derive master-edition
    let masterEdition: PublicKey;
    [masterEdition, _] = await web3.PublicKey.findProgramAddress(
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
    [masterEditionAta, _] = await web3.PublicKey.findProgramAddress(
        [
            authority.accounts.pda.toBuffer(),
            SPL_TOKEN_PROGRAM_ID.toBuffer(),
            authority.accounts.mint.toBuffer()
        ],
        SPL_ASSOCIATED_TOKEN_PROGRAM_ID
    )
    // derive key-pair for new-edition-mint
    const newMint: Keypair = web3.Keypair.generate();
    // derive new-metadata
    let newMetadata: PublicKey;
    [newMetadata, _] = await web3.PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            newMint.publicKey.toBuffer(),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    )
    // derive new-edition
    let newEdition: PublicKey;
    [newEdition, _] = await web3.PublicKey.findProgramAddress(
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
    [newEditionMark, _] = await web3.PublicKey.findProgramAddress(
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
    [newEditionAta, _] = await web3.PublicKey.findProgramAddress(
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
                systemProgram: web3.SystemProgram.programId,
                rent: web3.SYSVAR_RENT_PUBKEY,
            }
        ).signers([newMint])
        .rpc();
    // derive collection metadata
    let collectionMetadata: PublicKey;
    [collectionMetadata, _] = await web3.PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            authority.accounts.collection.toBuffer(),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    )
    // derive collection master-edition
    let collectionMasterEdition: PublicKey;
    [collectionMasterEdition, _] = await web3.PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            authority.accounts.collection.toBuffer(),
            Buffer.from(MPL_EDITION),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    )
    // invoke rpc
    console.log("adding new copy to collection");
    // TODO; separate calls ?
    await addNewCopyToCollection(
        provider,
        programs.dap,
        index,
        handlePda,
        authority.accounts.pda,
        authority.accounts.mint,
        authority.accounts.collection,
        collectionMetadata,
        collectionMasterEdition,
        newMint.publicKey,
        newMetadata
    );
    // replace master-mint with copied-mint
    authority.accounts.mint = newMint.publicKey;
    // add associated-token-account balance
    authority.accounts.ata = {
        balance: 1
    };
    // fetch collected
    if (collectorNextCollectionIndex === 1) {
        collected = [authority];
    } else {
        collected = collected.concat([authority]);
    }
    // fetch collections & set global
    let global;
    try {
        const creatorPda = await deriveCreatorPda(provider, programs.dap);
        const creator = await getCreatorPda(programs.dap, creatorPda);
        const fetchedHandle = await getHandlePda(programs.dap, creator.handle);
        const collections = await getManyAuthorityPdaForCreator(programs.dap, fetchedHandle);
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
                listener: "collector-collection-purchased",
                more: JSON.stringify(
                    {
                        collection: authority,
                        global: global
                    }
                )
            }
        )
    );
}

async function addNewCopyToCollection(
    provider: AnchorProvider,
    program: Program<DapCool>,
    index: number,
    handle: PublicKey,
    authority: PublicKey,
    mint: PublicKey,
    collection: PublicKey,
    collectionMetadata: PublicKey,
    collectionMasterEdition: PublicKey,
    newMint: PublicKey,
    newMetadata: PublicKey
): Promise<void> {
    // invoke rpc
    await program.methods
        .addNewCopyToCollection(index as any)
        .accounts(
            {
                handle: handle,
                authority: authority,
                mint: mint,
                collection: collection,
                collectionMetadata: collectionMetadata,
                collectionMasterEdition: collectionMasterEdition,
                newMint: newMint,
                newMetadata: newMetadata,
                payer: provider.wallet.publicKey,
                tokenProgram: SPL_TOKEN_PROGRAM_ID,
                metadataProgram: MPL_TOKEN_METADATA_PROGRAM_ID,
                systemProgram: web3.SystemProgram.programId,
                rent: web3.SYSVAR_RENT_PUBKEY,
            }
        ).rpc()
}
