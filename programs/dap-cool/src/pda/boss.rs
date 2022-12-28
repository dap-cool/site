use anchor_lang::prelude::*;

pub const SEED: &str = "boss";

pub const SIZE: usize = 8 // discriminator
    + AUTHORITY_SIZE
    + FEE_SIZE
    + USDC_SIZE;

const AUTHORITY_SIZE: usize = 32;

const USDC_SIZE: usize = 32;

const FEE_SIZE: usize = 8;

#[account]
pub struct Boss {
    pub authority: Pubkey,
    pub usdc: Pubkey,
    pub fee: u64,
}
