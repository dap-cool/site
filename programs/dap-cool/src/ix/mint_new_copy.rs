use anchor_lang::prelude::*;
use anchor_spl::token::{mint_to, MintTo};
use crate::{MintNewCopy, pda};

pub fn ix(ctx: Context<MintNewCopy>, bumps: MintNewCopyBumps, n: u8) -> Result<()> {
    // build signer seeds
    let seeds = &[
        pda::authority::SEED.as_bytes(),
        ctx.accounts.handle.handle.as_bytes(), &[n],
        &[bumps.authority]
    ];
    let signer_seeds = &[&seeds[..]];
    // build mint-to associated-token-account instruction
    let mint_ata_cpi_accounts = MintTo {
        mint: ctx.accounts.mint.to_account_info(),
        to: ctx.accounts.mint_ata.to_account_info(),
        authority: ctx.accounts.authority.to_account_info(),
    };
    let mint_ata_cpi_context = CpiContext::new(
        ctx.accounts.token_program.to_account_info(),
        mint_ata_cpi_accounts,
    );
    // invoke mint-to associated-token-account
    mint_to(
        mint_ata_cpi_context.with_signer(
            signer_seeds
        ),
        1,
    )?;
    // increment
    let authority = &mut ctx.accounts.authority;
    authority.num_minted += 1;
    // collector
    let collector = &mut ctx.accounts.collector;
    collector.num_collected += 1;
    // collection
    let collection = &mut ctx.accounts.collection_pda;
    collection.mint = ctx.accounts.mint.key();
    collection.handle = ctx.accounts.handle.handle.clone();
    collection.index = n;
    Ok(())
}

#[derive(AnchorSerialize, AnchorDeserialize)]
pub struct MintNewCopyBumps {
    pub handle: u8,
    pub authority: u8,
}
