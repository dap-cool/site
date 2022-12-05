use anchor_lang::prelude::*;

pub const SEED: &str = "verified";

pub const VERIFIED_SIZE: usize = 8 // discriminator
    + 1; // verified

#[account]
pub struct Verified {
    pub verified: bool,
}
