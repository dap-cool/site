use anchor_lang::prelude::*;
use anchor_spl::token::{mint_to, MintTo};
use mpl_token_metadata::instruction::{
    create_metadata_accounts_v3, sign_metadata, update_primary_sale_happened_via_token,
};
use mpl_token_metadata::state::CollectionDetails;
use crate::{CreateNFT, pda};
use crate::error::CustomErrors;

pub fn ix(
    ctx: Context<CreateNFT>,
    bumps: CreateNftBumps,
    name: String,
    symbol: String,
    uri: String,
    image: u8,
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
        Some(CollectionDetails::V1 { size }),
    );
    // build sign metadata instruction
    let ix_sign_metadata = sign_metadata(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.metadata.key(),
        ctx.accounts.payer.key(),
    );
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
    // build primary-sale-happened instruction
    let ix_primary_sale = update_primary_sale_happened_via_token(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.metadata.key(),
        ctx.accounts.payer.key(),
        ctx.accounts.mint_ata.key(),
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
    // invoke mint-to associated-token-account
    let creator_distribution: u64 = 1; // TODO; expose as arg
    assert_valid_distribution(
        size,
        creator_distribution,
    )?;
    mint_to(
        mint_ata_cpi_context.with_signer(
            signer_seeds
        ),
        creator_distribution,
    )?;
    // invoke primary-sale-happened
    anchor_lang::solana_program::program::invoke(
        &ix_primary_sale,
        &[
            ctx.accounts.metadata.to_account_info(),
            ctx.accounts.payer.to_account_info(),
            ctx.accounts.mint_ata.to_account_info()
        ],
    )?;
    // init authority data
    let authority = &mut ctx.accounts.authority;
    // core
    authority.handle = ctx.accounts.handle.handle.clone();
    authority.index = increment;
    authority.mint = ctx.accounts.mint.key();
    // meta
    authority.name = name; // already validated by metaplex
    authority.symbol = symbol; // already validated by metaplex
    authority.uri = uri; // already validated by metaplex
    authority.image = image;
    // math
    authority.total_supply = size;
    authority.num_minted = creator_distribution;
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
}

fn assert_valid_distribution(total_supply: u64, creator_distribution: u64) -> Result<()> {
    if creator_distribution < total_supply {
        Ok(())
    } else {
        Err(CustomErrors::CreatorDistributionTooLarge.into())
    }
}
