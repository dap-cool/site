use anchor_lang::{Key, ToAccountInfo};
use anchor_lang::prelude::{Context, CpiContext, Result};
use anchor_spl::token::{mint_to, MintTo};
use mpl_token_metadata::instruction::{
    create_master_edition_v3, create_metadata_accounts_v3, sign_metadata,
};
use crate::{CreateNFT, pda};

pub fn ix(
    ctx: Context<CreateNFT>,
    name: String,
    symbol: String,
    uri: String,
    size: u64,
) -> Result<()> {
    // unwrap authority bump
    let authority_bump = *ctx.bumps.get(pda::authority::BUMP).unwrap();
    // increment collection
    let increment = ctx.accounts.creator.num_collections + 1;
    // build signer seeds
    let seeds = &[
        ctx.accounts.creator.handle.as_bytes(), &[increment],
        &[authority_bump]
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
        false,
        None,
        None,
        None,
    );
    // build sign metadata instruction
    let ix_sign_metadata = sign_metadata(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.metadata.key(),
        ctx.accounts.payer.key(),
    );
    // build ata master-edition instruction
    let ata_cpi_accounts = MintTo {
        mint: ctx.accounts.mint.to_account_info(),
        to: ctx.accounts.master_edition_ata.to_account_info(),
        authority: ctx.accounts.authority.to_account_info(),
    };
    let ata_cpi_context = CpiContext::new(
        ctx.accounts.token_program.to_account_info(),
        ata_cpi_accounts,
    );
    // build create master-edition instruction
    let ix_create_master_edition = create_master_edition_v3(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.master_edition.key(),
        ctx.accounts.mint.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.metadata.key(),
        ctx.accounts.payer.key(),
        Some(size),
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
    // invoke sign metadata
    anchor_lang::solana_program::program::invoke(
        &ix_sign_metadata,
        &[
            ctx.accounts.metadata.to_account_info(),
            ctx.accounts.payer.to_account_info()
        ],
    )?;
    // invoke ata master-edition
    mint_to(
        ata_cpi_context.with_signer(
            signer_seeds
        ),
        1,
    )?;
    // invoke create master-edition
    anchor_lang::solana_program::program::invoke_signed(
        &ix_create_master_edition,
        &[
            ctx.accounts.master_edition.to_account_info(),
            ctx.accounts.mint.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.metadata.to_account_info(),
            ctx.accounts.payer.to_account_info(),
            ctx.accounts.system_program.to_account_info(),
            ctx.accounts.rent.to_account_info()
        ],
        signer_seeds,
    )?;
    // init authority data
    let authority = &mut ctx.accounts.authority;
    authority.mint = ctx.accounts.mint.key();
    authority.total_supply = size;
    authority.num_minted = 0;
    authority.name = name; // already validated by metaplex
    authority.symbol = symbol; // already validated by metaplex
    authority.uri = uri; // already validated by metaplex
    // increment collection
    let creator = &mut ctx.accounts.creator;
    creator.num_collections = increment;
    Ok(())
}
