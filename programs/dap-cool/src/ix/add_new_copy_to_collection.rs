use anchor_lang::prelude::*;
use mpl_token_metadata::instruction::set_and_verify_sized_collection_item;
use crate::{AddNewCopyToCollection, pda};

pub fn ix(
    ctx: Context<AddNewCopyToCollection>,
    bumps: AddNewCopyToCollectionBumps,
    n: u8,
) -> Result<()> {
    // build signer seeds
    let seeds = &[
        pda::authority::SEED.as_bytes(),
        ctx.accounts.handle.handle.as_bytes(), &[n],
        &[bumps.authority]
    ];
    let signer_seeds = &[&seeds[..]];
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
    // mark collector-pda
    let collector = &mut ctx.accounts.collector;
    collector.latest_marked = true;
    // mark collection-pda
    let collection_pda = &mut ctx.accounts.collection_pda;
    collection_pda.marked = true;
    Ok(())
}

#[derive(AnchorSerialize, AnchorDeserialize)]
pub struct AddNewCopyToCollectionBumps {
    pub collector: u8,
    pub collection_pda: u8,
    pub verified: u8,
    pub handle: u8,
    pub authority: u8,
    pub collection_metadata: u8,
    pub collection_master_edition: u8,
    pub new_metadata: u8,
}
