use anchor_lang::prelude::{error_code};

#[error_code]
pub enum CustomErrors {
    #[msg("Max handle length is 16 bytes.")]
    HandleTooLong,
    #[msg("Your previous collection must be marked before purchasing another.")]
    EveryCollectionMustBeMarked,
    #[msg("Only verified editions can be marked as such.")]
    CopiedMintMustBeVerified,
}
