use anchor_lang::{Key, ToAccountInfo};
use anchor_lang::prelude::{Context, Result};
use mpl_token_metadata::instruction::set_and_verify_sized_collection_item;
use crate::{AddNewCopyToCollection, pda};

pub fn ix(ctx: Context<AddNewCopyToCollection>, n: u8) -> Result<()> {
    // unwrap authority bump
    let authority_bump = *ctx.bumps.get(pda::authority::BUMP).unwrap();
    // build signer seeds
    let seeds = &[
        ctx.accounts.creator.handle.as_bytes(), &[n],
        &[authority_bump]
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
    ).map_err(Into::into)
}
