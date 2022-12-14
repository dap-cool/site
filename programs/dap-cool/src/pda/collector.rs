use anchor_lang::prelude::*;
use crate::pda::handle::MAX_HANDLE_LENGTH;

pub const SEED: &str = "collector";

pub const COLLECTOR_SIZE: usize = 8 // discriminator
    + 1; // num-collected

pub const COLLECTION_SIZE: usize = 8 // discriminator
    + 32 // mint
    + 4 + MAX_HANDLE_LENGTH // handle
    + 1; // index

pub const COLLECTED_SIZE: usize = 8 // discriminator
    + 1; // collected

#[account]
pub struct Collector {
    pub num_collected: u8,
}

#[account]
pub struct Collection {
    pub mint: Pubkey,
    pub handle: String,
    pub index: u8,
}

#[account]
pub struct Collected {
    pub collected: bool,
}
