use anchor_lang::prelude::*;
use anchor_spl::associated_token::AssociatedToken;
use anchor_spl::token::{Mint, Token, TokenAccount};
use mpl_token_metadata::state::{PREFIX};
use crate::pda::{authority::Authority, handle::Handle};
use crate::ix::{
    init_boss,
    init_new_creator,
    init_creator_metadata,
    create_nft, create_nft::CreateNftBumps,
    mint_new_copy, mint_new_copy::MintNewCopyBumps,
};
use crate::pda::boss::Boss;
use crate::pda::collector::{Collected, Collection, Collector};
use crate::pda::creator::Creator;

pub mod pda;
pub mod ix;
pub mod error;

declare_id!("4Dtchwq7XRWfQLNfovgkwTC1eMzm6n8vHC1T3UBU4D2h");

#[program]
pub mod dap_cool {
    use super::*;

    pub fn init_new_creator(
        ctx: Context<InitNewCreator>,
        handle: String,
    ) -> Result<()> {
        init_new_creator::ix(ctx, handle)
    }

    pub fn init_creator_metadata(
        ctx: Context<InitCreatorMetadata>,
        metadata: Pubkey,
    ) -> Result<()> {
        init_creator_metadata::ix(ctx, metadata)
    }

    pub fn create_nft(
        ctx: Context<CreateNFT>,
        bumps: CreateNftBumps,
        name: String,
        symbol: String,
        uri: String,
        image: u8,
        size: u64,
        creator_distribution: u64,
        price: u64,
        fee: u16,
    ) -> Result<()> {
        create_nft::ix(ctx, bumps, name, symbol, uri, image, size, creator_distribution, price, fee)
    }

    pub fn mint_new_copy(ctx: Context<MintNewCopy>, bumps: MintNewCopyBumps, n: u8) -> Result<()> {
        mint_new_copy::ix(ctx, bumps, n)
    }

    pub fn init_boss(ctx: Context<InitBoss>) -> Result<()> {
        init_boss::ix(ctx)
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Accounts ////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#[derive(Accounts)]
#[instruction(handle: String)]
pub struct InitNewCreator<'info> {
    #[account(init,
    seeds = [
    pda::handle::SEED.as_bytes(),
    handle.as_bytes()
    ], bump,
    payer = payer,
    space = pda::handle::SIZE
    )]
    pub handle_pda: Account<'info, Handle>,
    #[account(init,
    seeds = [
    pda::creator::SEED.as_bytes(),
    payer.key().as_ref()
    ], bump,
    payer = payer,
    space = pda::creator::SIZE
    )]
    pub creator: Account<'info, Creator>,
    #[account(mut)]
    pub payer: Signer<'info>,
    // system program
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
#[instruction(metadata: Pubkey)]
pub struct InitCreatorMetadata<'info> {
    #[account(mut,
    seeds = [
    pda::handle::SEED.as_bytes(),
    handle.handle.as_bytes()
    ], bump,
    )]
    pub handle: Account<'info, Handle>,
    #[account(
    address = handle.authority
    )]
    pub payer: Signer<'info>,
}

#[derive(Accounts)]
#[instruction(bumps: CreateNftBumps)]
pub struct CreateNFT<'info> {
    #[account(
    seeds = [
    pda::boss::SEED.as_bytes()
    ],
    bump = bumps.boss
    )]
    pub boss: Box<Account<'info, Boss>>,
    #[account(mut,
    seeds = [
    pda::handle::SEED.as_bytes(),
    handle.handle.as_bytes()
    ],
    bump = bumps.handle,
    constraint = handle.authority == payer.key()
    )]
    pub handle: Box<Account<'info, Handle>>,
    #[account(init,
    seeds = [
    pda::authority::SEED.as_bytes(),
    handle.handle.as_bytes(),
    & [handle.num_collections + 1]
    ], bump,
    payer = payer,
    space = pda::authority::SIZE
    )]
    pub authority: Box<Account<'info, Authority>>,
    #[account(init,
    mint::authority = authority,
    mint::freeze_authority = authority,
    mint::decimals = 0,
    payer = payer
    )]
    pub mint: Account<'info, Mint>,
    #[account(init,
    associated_token::mint = mint,
    associated_token::authority = payer,
    payer = payer
    )]
    pub mint_ata: Box<Account<'info, TokenAccount>>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    mint.key().as_ref()
    ],
    bump = bumps.metadata,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: uninitialized metadata
    pub metadata: UncheckedAccount<'info>,
    #[account(
    address = boss.usdc,
    owner = token_program.key()
    )]
    pub usdc: Account<'info, Mint>,
    #[account(init_if_needed,
    associated_token::mint = usdc,
    associated_token::authority = payer,
    payer = payer
    )]
    pub usdc_ata: Box<Account<'info, TokenAccount>>,
    #[account(mut)]
    pub payer: Signer<'info>,
    // token program
    pub token_program: Program<'info, Token>,
    // associated token program
    pub associated_token_program: Program<'info, AssociatedToken>,
    // metadata program
    pub metadata_program: Program<'info, MetadataProgram>,
    // system program
    pub system_program: Program<'info, System>,
    // rent program
    pub rent: Sysvar<'info, Rent>,
}

#[derive(Accounts)]
#[instruction(bumps: MintNewCopyBumps, n: u8)]
pub struct MintNewCopy<'info> {
    #[account(
    seeds = [
    pda::boss::SEED.as_bytes()
    ],
    bump = bumps.boss
    )]
    pub boss: Box<Account<'info, Boss>>,
    #[account(init_if_needed,
    seeds = [
    pda::collector::SEED.as_bytes(),
    payer.key().as_ref()
    ], bump,
    space = pda::collector::COLLECTOR_SIZE,
    payer = payer,
    )]
    pub collector: Box<Account<'info, Collector>>,
    #[account(init_if_needed,
    seeds = [
    pda::collector::SEED.as_bytes(),
    payer.key().as_ref(), & [collector.num_collected + 1]
    ], bump,
    space = pda::collector::COLLECTION_SIZE,
    payer = payer,
    )]
    pub collection_pda: Box<Account<'info, Collection>>,
    #[account(init_if_needed,
    seeds = [
    pda::collector::SEED.as_bytes(),
    payer.key().as_ref(),
    authority.mint.as_ref()
    ], bump,
    space = pda::collector::COLLECTED_SIZE,
    payer = payer,
    )
    ]
    pub collected: Box<Account<'info, Collected>>,
    #[account(seeds = [
    pda::handle::SEED.as_bytes(),
    handle.handle.as_bytes()
    ],
    bump = bumps.handle
    )]
    pub handle: Box<Account<'info, Handle>>,
    #[account(mut,
    seeds = [
    pda::authority::SEED.as_bytes(),
    handle.handle.as_bytes(),
    & [n]
    ],
    bump = bumps.authority,
    )]
    pub authority: Box<Account<'info, Authority>>,
    #[account(mut,
    address = authority.mint,
    owner = token_program.key()
    )]
    pub mint: Account<'info, Mint>,
    #[account(init_if_needed,
    associated_token::mint = mint,
    associated_token::authority = payer,
    payer = payer
    )]
    pub mint_ata: Box<Account<'info, TokenAccount>>,
    #[account(
    address = boss.usdc,
    owner = token_program.key()
    )]
    pub usdc: Account<'info, Mint>,
    #[account(mut,
    associated_token::mint = usdc,
    associated_token::authority = payer
    )]
    pub usdc_ata_src: Box<Account<'info, TokenAccount>>,
    #[account(mut,
    associated_token::mint = usdc,
    associated_token::authority = handle.authority
    )]
    pub usdc_ata_dst_handle: Box<Account<'info, TokenAccount>>,
    #[account(mut)]
    pub payer: Signer<'info>,
    // token program
    pub token_program: Program<'info, Token>,
    // associated token program
    pub associated_token_program: Program<'info, AssociatedToken>,
    // metadata program
    pub metadata_program: Program<'info, MetadataProgram>,
    // system program
    pub system_program: Program<'info, System>,
    // rent program
    pub rent: Sysvar<'info, Rent>,
}

#[derive(Accounts)]
pub struct InitBoss<'info> {
    #[account(init,
    seeds = [
    pda::boss::SEED.as_bytes(),
    ], bump,
    payer = payer,
    space = pda::boss::SIZE
    )]
    pub boss: Account<'info, Boss>,
    #[account()]
    pub usdc: Account<'info, Mint>,
    #[account(mut)]
    pub payer: Signer<'info>,
    // system program
    pub system_program: Program<'info, System>,
}

#[derive(Clone)]
pub struct MetadataProgram;

impl anchor_lang::Id for MetadataProgram {
    fn id() -> Pubkey {
        mpl_token_metadata::ID
    }
}
