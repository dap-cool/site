use anchor_lang::prelude::*;
use anchor_spl::token::{mint_to, transfer, MintTo, Transfer};
use crate::{MintNewCopy, pda};
use crate::error::CustomErrors;

pub fn ix(ctx: Context<MintNewCopy>, bumps: MintNewCopyBumps, n: u8) -> Result<()> {
    // assert supply remaining
    let authority = &mut ctx.accounts.authority;
    let authority_increment = authority.num_minted + 1;
    assert_supply_remaining(
        &authority.total_supply,
        &authority_increment,
    )?;
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
    // build transfer-to-handle instruction
    let transfer_to_handle_accounts = Transfer {
        from: ctx.accounts.usdc_ata_src.to_account_info(),
        to: ctx.accounts.usdc_ata_dst_handle.to_account_info(),
        authority: ctx.accounts.payer.to_account_info(),
    };
    let transfer_to_handle_cpi_context = CpiContext::new(
        ctx.accounts.token_program.to_account_info(),
        transfer_to_handle_accounts,
    );
    // invoke mint-to associated-token-account
    mint_to(
        mint_ata_cpi_context.with_signer(
            signer_seeds
        ),
        1,
    )?;
    // invoke transfer-to-handle
    transfer(
        transfer_to_handle_cpi_context,
        15,
    )?;
    // authority
    authority.num_minted = authority_increment;
    // has this keypair collected this mint already?
    let collected = &mut ctx.accounts.collected;
    if !collected.collected {
        // collector
        let collector = &mut ctx.accounts.collector;
        collector.num_collected += 1;
        msg!("{}", &collector.num_collected);
        // collection
        let collection = &mut ctx.accounts.collection_pda;
        collection.mint = ctx.accounts.mint.key();
        collection.handle = ctx.accounts.handle.handle.clone();
        collection.index = n;
        // collected
        collected.collected = true;
    }
    Ok(())
}

#[derive(AnchorSerialize, AnchorDeserialize)]
pub struct MintNewCopyBumps {
    pub boss: u8,
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
