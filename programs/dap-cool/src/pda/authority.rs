use anchor_lang::prelude::*;
use mpl_token_metadata::state::{MAX_NAME_LENGTH, MAX_SYMBOL_LENGTH, MAX_URI_LENGTH};

pub const BUMP: &str = "authority";

pub const SIZE: usize = 8 // discriminator
    + MINT_SIZE
    + COLLECTION_SIZE
    + NUM_MINTED
    + TOTAL_SUPPLY
    + MAX_NAME_LENGTH
    + MAX_SYMBOL_LENGTH
    + MAX_URI_LENGTH;

const MINT_SIZE: usize = 32;

const COLLECTION_SIZE: usize = 32;

const NUM_MINTED: usize = 8;

const TOTAL_SUPPLY: usize = 8;

#[account]
pub struct Authority {
    pub mint: Pubkey,
    pub collection: Pubkey,
    pub num_minted: u64,
    pub total_supply: u64,
    pub name: String,
    pub symbol: String,
    pub uri: String
}
