use anchor_lang::prelude::*;
use mpl_token_metadata::instruction::{
    create_metadata_accounts_v3,
    set_and_verify_sized_collection_item,
};
use mpl_token_metadata::state::{Data};
use crate::{MintNewCopy, pda};

pub fn ix(ctx: Context<MintNewCopy>, bumps: MintNewCopyBumps, n: u8) -> Result<()> {
    // build signer seeds
    let seeds = &[
        pda::authority::SEED.as_bytes(),
        ctx.accounts.handle.handle.as_bytes(), &[n],
        &[bumps.authority]
    ];
    let signer_seeds = &[&seeds[..]];
    // build metadata instruction
    let old_data: &Data = &ctx.accounts.metadata.0.data;
    let ix_metadata = create_metadata_accounts_v3(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.new_metadata.key(),
        ctx.accounts.new_mint.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.payer.key(),
        ctx.accounts.authority.key(),
        old_data.name.clone(),
        old_data.symbol.clone(),
        old_data.uri.clone(),
        old_data.creators.clone(),
        old_data.seller_fee_basis_points,
        false,
        true,
        None,
        None,
        None,
    );
    // build set-collection instruction
    let ix_set_collection = set_and_verify_sized_collection_item(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.new_metadata.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.payer.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.collection.key(),
        ctx.accounts.collection_metadata.key(),
        ctx.accounts.collection_master_edition.key(),
        None,
    );
    // invoke create new metadata
    anchor_lang::solana_program::program::invoke_signed(
        &ix_metadata,
        &[
            ctx.accounts.new_metadata.to_account_info(),
            ctx.accounts.new_mint.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.payer.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.system_program.to_account_info(),
            ctx.accounts.rent.to_account_info()
        ],
        signer_seeds,
    )?;
    // invoke set collection
    anchor_lang::solana_program::program::invoke_signed(
        &ix_set_collection,
        &[
            ctx.accounts.new_metadata.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.payer.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.collection.to_account_info(),
            ctx.accounts.collection_metadata.to_account_info(),
            ctx.accounts.collection_master_edition.to_account_info()
        ],
        signer_seeds,
    )?;

    // increment
    let authority = &mut ctx.accounts.authority;
    authority.num_minted +=1;
    // collector
    let collector = &mut ctx.accounts.collector;
    collector.num_collected += 1;
    // collection
    let collection = &mut ctx.accounts.collection_pda;
    collection.mint = ctx.accounts.new_mint.key();
    collection.handle = ctx.accounts.handle.handle.clone();
    collection.index = n;
    Ok(())
}

#[derive(AnchorSerialize, AnchorDeserialize)]
pub struct MintNewCopyBumps {
    pub handle: u8,
    pub authority: u8,
    pub metadata: u8,
    pub collection_metadata: u8,
    pub collection_master_edition: u8,
    pub new_metadata: u8,
}
