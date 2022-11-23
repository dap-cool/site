import {getHandlePda, Handle} from "../pda/handle-pda";
import {CollectionAuthority, deriveAuthorityPda, getManyAuthorityPdaForCollector} from "../pda/authority-pda";
import {
    MPL_PREFIX,
    MPL_EDITION,
    MPL_TOKEN_METADATA_PROGRAM_ID,
    SPL_TOKEN_PROGRAM_ID,
    SPL_ASSOCIATED_TOKEN_PROGRAM_ID
} from "../util/constants";
import {buildMetaData, provision, readLogo, uploadFile} from "../../shdw/shdw";
import {AnchorProvider, BN, Program} from "@project-serum/anchor";
import {Connection, Keypair, PublicKey, SystemProgram, SYSVAR_RENT_PUBKEY} from "@solana/web3.js";
import {ShdwDrive} from "@shadow-drive/sdk";
import {DapCool} from "../idl";
import {getAllCollectionsFromHandle} from "../pda/get-all-collections-from-handle";
import {deriveCollectorPda, getAllCollectionPda, getCollectorPda} from "../pda/collector-pda";
import {Creator} from "../pda/creator-pda";

export async function creatNft(
    app,
    provider: AnchorProvider,
    program: Program<DapCool>,
    handlePda: PublicKey,
    handle: Handle,
    name: string,
    symbol: string
) {
    // fetch all collections from handle
    let collections = await getAllCollectionsFromHandle(program, handle);
    // fetch all collected from creator pda
    let collected;
    try {
        const collectorPda = await deriveCollectorPda(provider, program);
        const collector = await getCollectorPda(program, collectorPda);
        const collectedPda = await getAllCollectionPda(provider, program, collector);
        collected = await getManyAuthorityPdaForCollector(program, collectedPda);
    } catch (error) {
        console.log("could not find collector on-chain");
        collected = [];
    }
    // derive authority pda
    const authorityIndex: number = handle.numCollections + 1;
    const authorityPda: PublicKey = await deriveAuthorityPda(program, handle.handle, authorityIndex);
    // derive key-pair for mint
    const mint = Keypair.generate();
    // derive metadata
    let metadata, _;
    [metadata, _] = await PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            mint.publicKey.toBuffer(),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    )
    // derive master-edition
    let masterEdition;
    [masterEdition, _] = await PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            mint.publicKey.toBuffer(),
            Buffer.from(MPL_EDITION),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    )
    // derive master-edition-ata
    let masterEditionAta;
    [masterEditionAta, _] = await PublicKey.findProgramAddress(
        [
            authorityPda.toBuffer(),
            SPL_TOKEN_PROGRAM_ID.toBuffer(),
            mint.publicKey.toBuffer()
        ],
        SPL_ASSOCIATED_TOKEN_PROGRAM_ID
    )
    // upload metadata
    const metadataUrl: string = await uploadMetadata(
        provider.connection,
        provider.wallet,
        handle.handle,
        authorityIndex,
        name,
        symbol
    );
    // invoke rpc
    await program.methods
        .createNft(
            name as any,
            symbol as any,
            metadataUrl as any,
            new BN(2) // TODO; supply
        )
        .accounts(
            {
                handle: handlePda,
                authority: authorityPda,
                mint: mint.publicKey,
                metadata: metadata,
                masterEdition: masterEdition,
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
        handle: handle.handle,
        index: authorityIndex,
        name: name,
        symbol: symbol,
        mint: mint.publicKey,
        collection: null,
        numMinted: 0,
        pda: authorityPda
    } as CollectionAuthority;
    // concat
    collections = collections.concat([justCreated]);
    // send to elm
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
                        collection: justCreated
                    }
                )
            }
        )
    );
}

export async function createCollection(
    app,
    provider: AnchorProvider,
    program: Program<DapCool>,
    creator: Creator,
    authority: CollectionAuthority,
    index: number
) {
    // fetch handle obj
    const handleObj = await getHandlePda(program, creator.handle);
    // fetch all collections from handle
    let collections = await getAllCollectionsFromHandle(program, handleObj);
    // fetch all collected from creator pda
    let collected;
    try {
        const collectorPda = await deriveCollectorPda(provider, program);
        const collector = await getCollectorPda(program, collectorPda);
        const collectedPda = await getAllCollectionPda(provider, program, collector);
        collected = await getManyAuthorityPdaForCollector(program, collectedPda);
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
            authority.pda.toBuffer(),
            SPL_TOKEN_PROGRAM_ID.toBuffer(),
            collection.publicKey.toBuffer()
        ],
        SPL_ASSOCIATED_TOKEN_PROGRAM_ID
    )
    // invoke rpc
    await program.methods
        .createCollection(index as any)
        .accounts(
            {
                handle: creator.handle,
                authority: authority.pda,
                mint: authority.mint,
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
        handle: handleObj.handle,
        name: authority.name,
        symbol: authority.symbol,
        index: authority.index,
        mint: authority.mint,
        collection: collection.publicKey,
        numMinted: 0,
        pda: authority.pda
    } as CollectionAuthority;
    // concat
    collections = collections.concat([justMarked]);
    // send success to elm
    app.ports.success.send(
        JSON.stringify(
            {
                listener: "creator-marked-new-collection",
                more: JSON.stringify(
                    {
                        global: {
                            handle: handleObj.handle,
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
}

async function uploadMetadata(
    connection: Connection,
    uploader: any,
    handle: string,
    index: number,
    name: string,
    symbol: string
): Promise<string> {
    // read logo from input
    const logo: File = readLogo();
    // provision space
    const provisioned: { drive: ShdwDrive; account: PublicKey } = await provision(connection, uploader, logo.size);
    // upload logo
    const shdwUrl: string = await uploadFile(logo, provisioned.drive, provisioned.account);
    const logoUrl: string = shdwUrl + logo.name;
    // build metadata
    const metadata: File = buildMetaData(handle, index, name, symbol, "description", logoUrl);
    // upload metadata
    await uploadFile(metadata, provisioned.drive, provisioned.account);
    return (shdwUrl + "meta.json")
}
