use anchor_lang::prelude::*;

pub const SEED: &str = "collector";

pub const COLLECTOR_SIZE: usize = 8 // discriminator
    + 1; // num-collected

pub const COLLECTION_SIZE: usize = 8 // discriminator
    + 32 // mint
    + 32; // handle

#[account]
pub struct Collector {
    pub num_collected: u8,
}

#[account]
pub struct Collection {
    pub mint: Pubkey,
    pub handle: Pubkey,
}
