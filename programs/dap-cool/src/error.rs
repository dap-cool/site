use anchor_lang::prelude::{error_code};

#[error_code]
pub enum CustomErrors {
    #[msg("Max handle length is 16 bytes.")]
    HandleTooLong,
}
