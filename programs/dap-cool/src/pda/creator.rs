use anchor_lang::prelude::*;

pub const SIZE: usize = 8 // discriminator
    + HANDLE_SIZE;

const HANDLE_SIZE: usize = 32 * 3;

#[account]
pub struct Creator {
    authority: Pubkey,
    handle: Pubkey
}
