use anchor_lang::prelude::*;
use anchor_spl::token::{mint_to, MintTo};
use crate::{MintNewCopy, pda};
use crate::error::CustomErrors;

pub fn ix(ctx: Context<MintNewCopy>, bumps: MintNewCopyBumps, n: u8) -> Result<()> {
    // increment
    let authority = &mut ctx.accounts.authority;
    let authority_increment = authority.num_minted + 1;
    assert_supply_remaining(
        &authority.total_supply,
        &authority_increment,
    )?;
    let collector = &mut ctx.accounts.collector;
    let collector_increment = collector.num_collected + 1;
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
        authority: authority.to_account_info(),
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
    // authority
    msg!("{}", &authority_increment);
    authority.num_minted = authority_increment;
    msg!("{}", &authority.num_minted);
    // collector
    msg!("{}", &collector_increment);
    collector.num_collected = collector_increment;
    msg!("{}", &collector.num_collected);
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

fn assert_supply_remaining(total_supply: &u64, num_minted: &u64) -> Result<()> {
    if num_minted <= total_supply {
        Ok(())
    } else {
        Err(CustomErrors::SoldOut.into())
    }
}
