use anchor_lang::prelude::*;
use mpl_token_metadata::state::{MAX_NAME_LENGTH, MAX_SYMBOL_LENGTH, MAX_URI_LENGTH};
use crate::pda::handle::MAX_HANDLE_LENGTH;

pub const SEED: &str = "authority";

pub const SIZE: usize = 8 // discriminator
    + 4 + MAX_HANDLE_LENGTH
    + INDEX_SIZE
    + MINT_SIZE
    + 4 + MAX_NAME_LENGTH
    + 4 + MAX_SYMBOL_LENGTH
    + 4 + MAX_URI_LENGTH
    + IMAGE_SIZE
    + NUM_MINTED_SIZE
    + TOTAL_SUPPLY_SIZE
    + PRICE_SIZE
    + FEE_SIZE;

const INDEX_SIZE: usize = 1;

const MINT_SIZE: usize = 32;

const IMAGE_SIZE: usize = 1;

const NUM_MINTED_SIZE: usize = 8;

const TOTAL_SUPPLY_SIZE: usize = 8;

const PRICE_SIZE: usize = 8;

const FEE_SIZE: usize = 2;

#[account]
pub struct Authority {
    // core
    pub handle: String,
    pub index: u8,
    pub mint: Pubkey,
    // meta
    pub name: String,
    pub symbol: String,
    pub uri: String,
    pub image: u8,
    // math
    pub num_minted: u64,
    pub total_supply: u64,
    pub price: u64,
    pub fee: u16,
}
