use anchor_lang::{Key, ToAccountInfo};
use anchor_lang::prelude::{Context, CpiContext, Result};
use anchor_spl::token::{mint_to, MintTo};
use mpl_token_metadata::instruction::mint_new_edition_from_master_edition_via_token;
use crate::{Collector, MintNewCopy, pda};
use crate::error::CustomErrors;

// TODO; freeze until marking as part of collection
// TODO; pass pda-seed explicitly
pub fn ix(ctx: Context<MintNewCopy>, n: u8) -> Result<()> {
    // assert latest copy in collections is marked
    let collector: &mut Collector = &mut ctx.accounts.collector;
    assert_latest_copy_is_marked(collector)?;
    // unwrap authority bump
    let authority_bump = *ctx.bumps.get(pda::authority::SEED).unwrap();
    // build signer seeds
    let seeds = &[
        pda::authority::SEED.as_bytes(),
        ctx.accounts.handle.handle.as_bytes(), &[n],
        &[authority_bump]
    ];
    let signer_seeds = &[&seeds[..]];
    // build ata new-edition instruction
    let ata_cpi_accounts = MintTo {
        mint: ctx.accounts.new_mint.to_account_info(),
        to: ctx.accounts.new_edition_ata.to_account_info(),
        authority: ctx.accounts.authority.to_account_info(),
    };
    let ata_cpi_context = CpiContext::new(
        ctx.accounts.token_program.to_account_info(),
        ata_cpi_accounts,
    );
    // build new-edition instruction
    let increment = ctx.accounts.authority.num_minted + 1;
    let ix_new_edition = mint_new_edition_from_master_edition_via_token(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.new_metadata.key(),
        ctx.accounts.new_edition.key(),
        ctx.accounts.master_edition.key(),
        ctx.accounts.new_mint.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.payer.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.master_edition_ata.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.metadata.key(),
        ctx.accounts.mint.key(),
        increment,
    );
    // invoke mint-to ata new-edition
    mint_to(
        ata_cpi_context.with_signer(
            signer_seeds
        ),
        1,
    )?;
    // invoke new edition
    anchor_lang::solana_program::program::invoke_signed(
        &ix_new_edition,
        &[
            ctx.accounts.new_metadata.to_account_info(),
            ctx.accounts.new_edition.to_account_info(),
            ctx.accounts.master_edition.to_account_info(),
            ctx.accounts.new_mint.to_account_info(),
            ctx.accounts.new_edition_mark.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.payer.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.master_edition_ata.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.metadata.to_account_info(),
            ctx.accounts.system_program.to_account_info(),
            ctx.accounts.rent.to_account_info(),
        ],
        signer_seeds,
    )?;
    // increment
    let authority = &mut ctx.accounts.authority;
    authority.num_minted = increment;
    // collector
    collector.num_collected += 1;
    collector.latest_marked = false;
    // collection
    let collection = &mut ctx.accounts.collection_pda;
    collection.mint = ctx.accounts.new_mint.key();
    collection.marked = false;
    collection.handle = ctx.accounts.handle.handle.clone();
    collection.index = n;
    Ok(())
}

fn assert_latest_copy_is_marked(collector: &Collector) -> Result<()> {
    if collector.latest_marked || collector.num_collected == 0 {
        Ok(())
    } else {
        Err(CustomErrors::EveryCollectionMustBeMarked.into())
    }
}
