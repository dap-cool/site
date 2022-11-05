use anchor_lang::{Key, ToAccountInfo};
use anchor_lang::prelude::{Context, CpiContext, Result};
use anchor_spl::token::{mint_to, MintTo};
use mpl_token_metadata::instruction::{
    create_master_edition_v3, create_metadata_accounts_v3, sign_metadata,
};
use mpl_token_metadata::state::CollectionDetails;
use crate::{CreateCollection, pda};

pub fn ix(ctx: Context<CreateCollection>) -> Result<()> {
    // unwrap authority bump
    let authority_bump = *ctx.bumps.get(pda::authority::BUMP).unwrap();
    // build signer seeds
    let seeds = &[
        ctx.accounts.creator.handle.as_bytes(), &[ctx.accounts.creator.num_collections],
        &[authority_bump]
    ];
    let signer_seeds = &[&seeds[..]];
    // build collection metadata instruction for collection
    let ix_collection_metadata = create_metadata_accounts_v3(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.collection_metadata.key(),
        ctx.accounts.collection.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.payer.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.authority.name.clone(),
        ctx.accounts.authority.symbol.clone(),
        ctx.accounts.authority.uri.clone(),
        Some(vec![
            mpl_token_metadata::state::Creator {
                address: ctx.accounts.payer.key(),
                verified: false,
                share: 100,
            }
        ]),
        0,
        false,
        false,
        None,
        None,
        Some(CollectionDetails::V1 { size: ctx.accounts.authority.total_supply }),
    );
    // build sign collection metadata instruction
    let ix_sign_collection_metadata = sign_metadata(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.collection_metadata.key(),
        ctx.accounts.payer.key(),
    );
    // build ata collection master-edition instruction
    let collection_ata_cpi_accounts = MintTo {
        mint: ctx.accounts.collection.to_account_info(),
        to: ctx.accounts.collection_master_edition_ata.to_account_info(),
        authority: ctx.accounts.authority.to_account_info(),
    };
    let collection_ata_cpi_context = CpiContext::new(
        ctx.accounts.token_program.to_account_info(),
        collection_ata_cpi_accounts,
    );
    // build create collection master-edition instruction
    let ix_create_collection_master_edition = create_master_edition_v3(
        ctx.accounts.metadata_program.key(),
        ctx.accounts.collection_master_edition.key(),
        ctx.accounts.collection.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.authority.key(),
        ctx.accounts.collection_metadata.key(),
        ctx.accounts.payer.key(),
        Some(0),
    );
    // invoke create collection metadata
    anchor_lang::solana_program::program::invoke_signed(
        &ix_collection_metadata,
        &[
            ctx.accounts.collection_metadata.to_account_info(),
            ctx.accounts.collection.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.payer.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.system_program.to_account_info(),
            ctx.accounts.rent.to_account_info()
        ],
        signer_seeds,
    )?;
    // invoke sign collection metadata
    anchor_lang::solana_program::program::invoke(
        &ix_sign_collection_metadata,
        &[
            ctx.accounts.collection_metadata.to_account_info(),
            ctx.accounts.payer.to_account_info()
        ],
    )?;
    // invoke ata collection master-edition
    mint_to(
        collection_ata_cpi_context.with_signer(
            signer_seeds
        ),
        1,
    )?;
    // invoke create collection master edition
    anchor_lang::solana_program::program::invoke_signed(
        &ix_create_collection_master_edition,
        &[
            ctx.accounts.collection_master_edition.to_account_info(),
            ctx.accounts.collection.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.authority.to_account_info(),
            ctx.accounts.collection_metadata.to_account_info(),
            ctx.accounts.payer.to_account_info(),
            ctx.accounts.system_program.to_account_info(),
            ctx.accounts.rent.to_account_info()
        ],
        signer_seeds,
    )?;
    // init authority data
    let authority = &mut ctx.accounts.authority;
    authority.collection = ctx.accounts.collection.key();
    Ok(())
}
