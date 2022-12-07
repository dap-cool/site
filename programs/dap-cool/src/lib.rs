use anchor_lang::prelude::*;
use anchor_spl::associated_token::AssociatedToken;
use anchor_spl::token::{Mint, Token, TokenAccount};
use mpl_token_metadata::state::{PREFIX, EDITION, Metadata};
use crate::error::CustomErrors;
use crate::pda::{authority::Authority, handle::Handle};
use crate::ix::{
    init_new_creator, create_nft, mint_new_copy,
    create_nft::CreateNftBumps, mint_new_copy::MintNewCopyBumps,
};
use crate::pda::collector::{Collection, Collector};
use crate::pda::creator::Creator;

pub mod pda;
pub mod ix;
pub mod error;

declare_id!("FyCpUM8qyDY57fzeJf3MdwgrCKg2N9fQfTEXo9bFqZPp");

#[program]
pub mod dap_cool {
    use super::*;

    pub fn init_new_creator(
        ctx: Context<InitNewCreator>,
        handle: String,
    ) -> Result<()> {
        init_new_creator::ix(ctx, handle)
    }

    pub fn create_nft(
        ctx: Context<CreateNFT>,
        bumps: CreateNftBumps,
        name: String,
        symbol: String,
        uri: String,
        size: u64,
    ) -> Result<()> {
        create_nft::ix(ctx, bumps, name, symbol, uri, size)
    }

    pub fn mint_new_copy(ctx: Context<MintNewCopy>, bumps: MintNewCopyBumps, n: u8) -> Result<()> {
        mint_new_copy::ix(ctx, bumps, n)
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
#[instruction(bumps: CreateNftBumps)]
pub struct CreateNFT<'info> {
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
    #[account(init,
    mint::authority = authority,
    mint::freeze_authority = authority,
    mint::decimals = 0,
    payer = payer
    )]
    pub collection: Account<'info, Mint>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    collection.key().as_ref()
    ],
    bump = bumps.collection_metadata,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: uninitialized metadata
    pub collection_metadata: UncheckedAccount<'info>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    collection.key().as_ref(),
    EDITION.as_bytes()
    ],
    bump = bumps.collection_master_edition,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: uninitialized collection master-edition
    pub collection_master_edition: UncheckedAccount<'info>,
    #[account(init,
    associated_token::mint = collection,
    associated_token::authority = authority,
    payer = payer
    )]
    pub collection_master_edition_ata: Box<Account<'info, TokenAccount>>,
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
    #[account(init_if_needed,
    seeds = [
    pda::collector::SEED.as_bytes(),
    payer.key().as_ref()
    ], bump,
    space = pda::collector::COLLECTOR_SIZE,
    payer = payer,
    )]
    pub collector: Box<Account<'info, Collector>>,
    #[account(init,
    seeds = [
    pda::collector::SEED.as_bytes(),
    payer.key().as_ref(), & [collector.num_collected + 1]
    ], bump,
    space = pda::collector::COLLECTION_SIZE,
    payer = payer,
    )]
    pub collection_pda: Box<Account<'info, Collection>>,
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
    #[account(
    address = authority.mint,
    owner = token_program.key()
    )]
    pub mint: Account<'info, Mint>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    mint.key().as_ref()
    ],
    bump = bumps.metadata,
    seeds::program = metadata_program.key()
    )]
    pub metadata: Box<Account<'info, AnchorMetadata>>,
    #[account(
    address = authority.collection,
    owner = token_program.key()
    )]
    pub collection: Account<'info, Mint>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    collection.key().as_ref()
    ],
    bump = bumps.collection_metadata,
    seeds::program = metadata_program.key()
    )]
    pub collection_metadata: Box<Account<'info, AnchorMetadata>>,
    #[account(
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    collection.key().as_ref(),
    EDITION.as_bytes()
    ],
    bump = bumps.collection_master_edition,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: collection master-edition
    pub collection_master_edition: UncheckedAccount<'info>,
    #[account(init,
    mint::authority = authority,
    mint::freeze_authority = authority,
    mint::decimals = 0,
    payer = payer
    )]
    pub new_mint: Box<Account<'info, Mint>>,
    #[account(init,
    associated_token::mint = new_mint,
    associated_token::authority = payer,
    payer = payer
    )]
    pub new_mint_ata: Box<Account<'info, TokenAccount>>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    new_mint.key().as_ref()
    ],
    bump = bumps.new_metadata,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: uninitialized new-metadata
    pub new_metadata: UncheckedAccount<'info>,
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

#[derive(Clone)]
pub struct MetadataProgram;

impl anchor_lang::Id for MetadataProgram {
    fn id() -> Pubkey {
        mpl_token_metadata::ID
    }
}

#[derive(Clone, Debug, Default, PartialEq)]
pub struct AnchorMetadata(Metadata);

impl anchor_lang::AccountDeserialize for AnchorMetadata {
    fn try_deserialize_unchecked(buf: &mut &[u8]) -> Result<Self> {
        match Metadata::deserialize(buf) {
            Ok(metadata) => {
                Ok(AnchorMetadata(metadata))
            }
            Err(_) => {
                Err(CustomErrors::CouldNotDeserializeMetadata.into())
            }
        }
    }
}

impl anchor_lang::AccountSerialize for AnchorMetadata {}

impl anchor_lang::Owner for AnchorMetadata {
    fn owner() -> Pubkey {
        mpl_token_metadata::ID
    }
}
