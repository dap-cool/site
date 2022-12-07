use anchor_lang::prelude::*;
use anchor_spl::token::{mint_to, MintTo};
use mpl_token_metadata::instruction::{
    create_master_edition_v3, create_metadata_accounts_v3,
};
use mpl_token_metadata::state::CollectionDetails;
use crate::{CreateNFT, pda};

pub fn ix(
    ctx: Context<CreateNFT>,
    bumps: CreateNftBumps,
    name: String,
    symbol: String,
    uri: String,
    size: u64,
) -> Result<()> {
    // increment collection
    let increment = ctx.accounts.handle.num_collections + 1;
    // build signer seeds
    let seeds = &[
        pda::authority::SEED.as_bytes(),
        ctx.accounts.handle.handle.as_bytes(), &[increment],
        &[bumps.authority]
    ];
    let signer_seeds = &[&seeds[..]];
    // build metadata instruction
    let ix_metadata = create_metadata_accounts_v3(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.metadata.key(),
        ctx.accounts.mint.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.payer.key(),
        ctx.accounts.authority.key(),
        name.clone(),
        symbol.clone(),
        uri.clone(),
        Some(vec![
            mpl_token_metadata::state::Creator {
                address: ctx.accounts.payer.key(),
                verified: false,
                share: 100,
            }
        ]),
        500,
        false,
        true,
        None,
        None,
        None,
    );
    // build collection metadata instruction for collection
    let ix_collection_metadata = create_metadata_accounts_v3(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.collection_metadata.key(),
        ctx.accounts.collection.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.payer.key(),
        ctx.accounts.authority.key(),
        name.clone(),
        symbol.clone(),
        uri.clone(),
        Some(vec![
            mpl_token_metadata::state::Creator {
                address: ctx.accounts.payer.key(),
                verified: false,
                share: 100,
            }
        ]),
        0,
        false,
        false,
        None,
        None,
        Some(CollectionDetails::V1 { size }),
    );
    // build ata collection master-edition instruction
    let collection_ata_cpi_accounts = MintTo {
        mint: ctx.accounts.collection.to_account_info(),
        to: ctx.accounts.collection_master_edition_ata.to_account_info(),
        authority: ctx.accounts.authority.to_account_info(),
    };
    let collection_ata_cpi_context = CpiContext::new(
        ctx.accounts.token_program.to_account_info(),
        collection_ata_cpi_accounts,
    );
    // build create collection master-edition instruction
    let ix_create_collection_master_edition = create_master_edition_v3(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.collection_master_edition.key(),
        ctx.accounts.collection.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.collection_metadata.key(),
        ctx.accounts.payer.key(),
        Some(0),
    );
    // invoke create metadata
    anchor_lang::solana_program::program::invoke_signed(
        &ix_metadata,
        &[
            ctx.accounts.metadata.to_account_info(),
            ctx.accounts.mint.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.payer.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.system_program.to_account_info(),
            ctx.accounts.rent.to_account_info()
        ],
        signer_seeds,
    )?;
    // invoke create collection metadata
    anchor_lang::solana_program::program::invoke_signed(
        &ix_collection_metadata,
        &[
            ctx.accounts.collection_metadata.to_account_info(),
            ctx.accounts.collection.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.payer.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.system_program.to_account_info(),
            ctx.accounts.rent.to_account_info()
        ],
        signer_seeds,
    )?;
    // invoke ata collection master-edition
    mint_to(
        collection_ata_cpi_context.with_signer(
            signer_seeds
        ),
        1,
    )?;
    // invoke create collection master edition
    anchor_lang::solana_program::program::invoke_signed(
        &ix_create_collection_master_edition,
        &[
            ctx.accounts.collection_master_edition.to_account_info(),
            ctx.accounts.collection.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.collection_metadata.to_account_info(),
            ctx.accounts.payer.to_account_info(),
            ctx.accounts.system_program.to_account_info(),
            ctx.accounts.rent.to_account_info()
        ],
        signer_seeds,
    )?;
    // init authority data
    let authority = &mut ctx.accounts.authority;
    authority.handle = ctx.accounts.handle.handle.clone();
    authority.index = increment;
    authority.mint = ctx.accounts.mint.key();
    authority.collection = ctx.accounts.collection.key();
    authority.total_supply = size;
    authority.num_minted = 0;
    authority.name = name; // already validated by metaplex
    authority.symbol = symbol; // already validated by metaplex
    authority.uri = uri; // already validated by metaplex
    // increment collection
    let handle = &mut ctx.accounts.handle;
    handle.num_collections = increment;
    Ok(())
}

#[derive(AnchorSerialize, AnchorDeserialize)]
pub struct CreateNftBumps {
    pub handle: u8,
    pub authority: u8,
    pub metadata: u8,
    pub collection_metadata: u8,
    pub collection_master_edition: u8,
}
