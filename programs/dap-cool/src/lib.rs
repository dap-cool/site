use anchor_lang::prelude::*;
use anchor_spl::associated_token::AssociatedToken;
use anchor_spl::token::{Mint, Token, TokenAccount};
use mpl_token_metadata::state::{PREFIX, EDITION, EDITION_MARKER_BIT_SIZE};
use crate::pda::{authority::Authority, creator::Creator};
use crate::ix::{
    init_new_creator, create_nft, create_collection, mint_new_copy, add_new_copy_to_collection,
};

pub mod pda;
pub mod ix;
pub mod error;

declare_id!("DB2EAH9DoDcFtsC8AWCcjtLc2E8Hz1Y9t9X4gsDzbYh2");

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
        name: String,
        symbol: String,
        uri: String,
        size: u64,
    ) -> Result<()> {
        create_nft::ix(ctx, name, symbol, uri, size)
    }

    pub fn create_collection(ctx: Context<CreateCollection>) -> Result<()> {
        create_collection::ix(ctx)
    }

    pub fn mint_new_copy(ctx: Context<MintNewCopy>, n: u8) -> Result<()> {
        mint_new_copy::ix(ctx, n)
    }

    pub fn add_new_copy_to_collection(ctx: Context<AddNewCopyToCollection>, n: u8) -> Result<()> {
        add_new_copy_to_collection::ix(ctx, n)
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Impl ////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#[derive(Accounts)]
#[instruction(handle: String)]
pub struct InitNewCreator<'info> {
    #[account(init,
    seeds = [handle.as_bytes()], bump,
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
pub struct CreateNFT<'info> {
    #[account(mut,
    seeds = [creator.handle.as_bytes()], bump,
    constraint = creator.authority == payer.key()
    )]
    pub creator: Box<Account<'info, Creator>>,
    #[account(init,
    seeds = [creator.handle.as_bytes(), & [creator.num_collections + 1]], bump,
    payer = payer,
    space = pda::authority::SIZE
    )]
    pub authority: Box<Account<'info, Authority>>,
    #[account(init,
    mint::authority = authority,
    mint::decimals = 0,
    payer = payer
    )]
    pub mint: Account<'info, Mint>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    mint.key().as_ref()
    ], bump,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: uninitialized metadata
    pub metadata: UncheckedAccount<'info>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    mint.key().as_ref(),
    EDITION.as_bytes()
    ], bump,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: uninitialized master-edition
    pub master_edition: UncheckedAccount<'info>,
    #[account(init,
    associated_token::mint = mint,
    associated_token::authority = authority,
    payer = payer
    )]
    pub master_edition_ata: Box<Account<'info, TokenAccount>>,
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
pub struct CreateCollection<'info> {
    #[account(seeds = [creator.handle.as_bytes()], bump,
    constraint = creator.authority == payer.key()
    )]
    pub creator: Box<Account<'info, Creator>>,
    #[account(mut,
    seeds = [creator.handle.as_bytes(), & [creator.num_collections]], bump
    )]
    pub authority: Box<Account<'info, Authority>>,
    #[account(mut,
    address = authority.mint,
    owner = token_program.key()
    )]
    pub mint: Account<'info, Mint>,
    #[account(init,
    mint::authority = authority,
    mint::decimals = 0,
    payer = payer
    )]
    pub collection: Account<'info, Mint>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    collection.key().as_ref()
    ], bump,
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
    ], bump,
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
#[instruction(n: u8)]
pub struct MintNewCopy<'info> {
    #[account(seeds = [creator.handle.as_bytes()], bump)]
    pub creator: Box<Account<'info, Creator>>,
    #[account(mut,
    seeds = [creator.handle.as_bytes(), & [n]], bump,
    )]
    pub authority: Box<Account<'info, Authority>>,
    #[account(mut,
    address = authority.mint,
    owner = token_program.key()
    )]
    pub mint: Account<'info, Mint>,
    // TODO: check if mut needed
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    mint.key().as_ref()
    ], bump,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: initialized metadata
    pub metadata: UncheckedAccount<'info>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    mint.key().as_ref(),
    EDITION.as_bytes()
    ], bump,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: master-edition
    pub master_edition: UncheckedAccount<'info>,
    // TODO: check if mut needed
    #[account(mut,
    associated_token::mint = mint,
    associated_token::authority = authority
    )]
    pub master_edition_ata: Box<Account<'info, TokenAccount>>,
    // TODO: check if mut needed
    #[account(init,
    mint::authority = authority,
    mint::decimals = 0,
    payer = payer
    )]
    pub new_mint: Box<Account<'info, Mint>>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    new_mint.key().as_ref()
    ], bump,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: uninitialized new-metadata
    pub new_metadata: UncheckedAccount<'info>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    new_mint.key().as_ref(),
    EDITION.as_bytes()
    ], bump,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: uninitialized new-edition
    pub new_edition: UncheckedAccount<'info>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    mint.key().as_ref(),
    EDITION.as_bytes(),
    (authority.num_minted + 1).checked_div(EDITION_MARKER_BIT_SIZE).unwrap().to_string().as_bytes()
    ], bump,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: uninitialized new-edition-mark
    pub new_edition_mark: UncheckedAccount<'info>,
    #[account(init,
    associated_token::mint = new_mint,
    associated_token::authority = payer,
    payer = payer
    )]
    pub new_edition_ata: Box<Account<'info, TokenAccount>>,
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
#[instruction(n: u8)]
pub struct AddNewCopyToCollection<'info> {
    #[account(seeds = [creator.handle.as_bytes()], bump)]
    pub creator: Box<Account<'info, Creator>>,
    #[account(mut, seeds = [creator.handle.as_bytes(), & [n]], bump)]
    pub authority: Box<Account<'info, Authority>>,
    #[account(mut,
    address = authority.mint,
    owner = token_program.key()
    )]
    pub mint: Account<'info, Mint>,
    #[account(mut,
    address = authority.collection,
    owner = token_program.key()
    )]
    pub collection: Account<'info, Mint>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    collection.key().as_ref()
    ], bump,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: initialized metadata
    pub collection_metadata: UncheckedAccount<'info>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    collection.key().as_ref(),
    EDITION.as_bytes()
    ], bump,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: collection master-edition
    pub collection_master_edition: UncheckedAccount<'info>,
    #[account(mut,
    owner = token_program.key()
    )]
    pub new_mint: Account<'info, Mint>,
    #[account(mut,
    seeds = [
    PREFIX.as_bytes(),
    metadata_program.key().as_ref(),
    new_mint.key().as_ref()
    ], bump,
    seeds::program = metadata_program.key()
    )]
    /// CHECK: initialized new-metadata
    pub new_metadata: UncheckedAccount<'info>,
    #[account(mut)]
    pub payer: Signer<'info>,
    // token program
    pub token_program: Program<'info, Token>,
    // TODO; need ?
    // metadata program
    pub metadata_program: Program<'info, MetadataProgram>,
    // system program
    pub system_program: Program<'info, System>,
    // rent program
    pub rent: Sysvar<'info, Rent>, // TODO; need ?
}

#[derive(Clone)]
pub struct MetadataProgram;

impl anchor_lang::Id for MetadataProgram {
    fn id() -> Pubkey {
        mpl_token_metadata::ID
    }
}
