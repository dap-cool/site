use anchor_lang::{Key, ToAccountInfo};
use anchor_lang::prelude::{Context, Result};
use mpl_token_metadata::instruction::set_and_verify_sized_collection_item;
use crate::{AddNewCopyToCollection, pda, Verified};
use crate::error::CustomErrors;

pub fn ix(ctx: Context<AddNewCopyToCollection>, n: u8) -> Result<()> {
    // assert is-verified
    let verified: &Verified = &ctx.accounts.verified;
    assert_is_verified(verified)?;
    // unwrap authority bump
    let authority_bump = *ctx.bumps.get(pda::authority::SEED).unwrap();
    // build signer seeds
    let seeds = &[
        pda::authority::SEED.as_bytes(),
        ctx.accounts.handle.handle.as_bytes(), &[n],
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
    )?;
    // mark collector-pda
    let collector = &mut ctx.accounts.collector;
    collector.latest_marked = true;
    // mark collection-pda
    let collection_pda = &mut ctx.accounts.collection_pda;
    collection_pda.marked = true;
    Ok(())
}

// TODO; is pda-derivation not already enough ??
fn assert_is_verified(verified: &Verified) -> Result<()> {
    if verified.verified {
        Ok(())
    } else {
        Err(CustomErrors::CopiedMintMustBeVerified.into())
    }
}
