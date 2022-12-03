use anchor_lang::prelude::*;

pub const SEED: &str = "creator";

pub const SIZE: usize = 8 // discriminator
    + AUTHORITY_SIZE
    + HANDLE_SIZE;

const AUTHORITY_SIZE: usize = 32;

const HANDLE_SIZE: usize = 32;

#[account]
pub struct Creator {
    pub authority: Pubkey,
    pub handle: Pubkey,
}
