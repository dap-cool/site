use anchor_lang::prelude::{error_code};

#[error_code]
pub enum CustomErrors {
    #[msg("Max handle length is 16 bytes.")]
    HandleTooLong,
    #[msg("Your previous collection must be marked before purchasing another.")]
    EveryCollectionMustBeMarked,
    #[msg("Could not deserialize metadata that should have been initialized already.")]
    CouldNotDeserializeMetadata,
}
