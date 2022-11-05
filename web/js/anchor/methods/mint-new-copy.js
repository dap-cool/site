import {BN, web3} from "@project-serum/anchor";
import {getAuthorityPda} from "../pda/authority-pda";
import {deriveCreatorPda} from "../pda/creator-pda";
import {
    MPL_PREFIX,
    MPL_EDITION,
    MPL_TOKEN_METADATA_PROGRAM_ID,
    SPL_TOKEN_PROGRAM_ID,
    SPL_ASSOCIATED_TOKEN_PROGRAM_ID
} from "../util/constants";

export async function mintNewCopy(
    app,
    provider,
    program,
    handle,
    index
) {
    // derive creator pda
    const creator = await deriveCreatorPda(program, handle);
    // derive authority pda
    const authority = await getAuthorityPda(program, handle, index);
    // derive metadata
    let metadata, _;
    [metadata, _] = await web3.PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            authority.mint.toBuffer(),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    )
    // derive master-edition
    let masterEdition;
    [masterEdition, _] = await web3.PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            authority.mint.toBuffer(),
            Buffer.from(MPL_EDITION),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    )
    // derive master-edition-ata
    let masterEditionAta;
    [masterEditionAta, _] = await web3.PublicKey.findProgramAddress(
        [
            authority.pda.toBuffer(),
            SPL_TOKEN_PROGRAM_ID.toBuffer(),
            authority.mint.toBuffer()
        ],
        SPL_ASSOCIATED_TOKEN_PROGRAM_ID
    )
    // derive key-pair for new-edition-mint
    const newMint = web3.Keypair.generate();
    // derive new-metadata
    let newMetadata;
    [newMetadata, _] = await web3.PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            newMint.publicKey.toBuffer(),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    )
    // derive new-edition
    let newEdition;
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
    let n = authority.numMinted + 1;
    const newEditionMarkLiteral = (new BN.BN(n)).div(new BN.BN(248)).toString();
    let newEditionMark;
    [newEditionMark, _] = await web3.PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            authority.mint.toBuffer(),
            Buffer.from(MPL_EDITION),
            Buffer.from(newEditionMarkLiteral)
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    )
    // derive new-edition-ata
    let newEditionAta;
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
    await program.methods
        .mintNewCopy(index)
        .accounts(
            {
                creator: creator,
                authority: authority.pda,
                mint: authority.mint,
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
    let collectionMetadata;
    [collectionMetadata, _] = await web3.PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            authority.collection.toBuffer(),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    )
    // derive collection master-edition
    let collectionMasterEdition;
    [collectionMasterEdition, _] = await web3.PublicKey.findProgramAddress(
        [
            Buffer.from(MPL_PREFIX),
            MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
            authority.collection.toBuffer(),
            Buffer.from(MPL_EDITION),
        ],
        MPL_TOKEN_METADATA_PROGRAM_ID
    )
    // invoke rpc
    console.log("adding new copy to collection");
    await addNewCopyToCollection(
        provider,
        program,
        index,
        creator,
        authority.pda,
        authority.mint,
        authority.collection,
        collectionMetadata,
        collectionMasterEdition,
        newMint.publicKey,
        newMetadata
    );
    // send success to elm
    app.ports.success.send(
        JSON.stringify(
            {
                listener: "collector-collection-purchased",
                more: JSON.stringify(
                    {
                        wallet: provider.wallet.publicKey.toString(),
                        handle: handle,
                        collection: authority
                    }
                )
            }
        )
    );
}

async function addNewCopyToCollection(
    provider,
    program,
    index,
    creator,
    authority,
    mint,
    collection,
    collectionMetadata,
    collectionMasterEdition,
    newMint,
    newMetadata
) {
    // invoke rpc
    await program.methods
        .addNewCopyToCollection(index)
        .accounts(
            {
                creator: creator,
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
