use anchor_lang::prelude::{error_code};

#[error_code]
pub enum CustomErrors {
    #[msg("Max handle length is 16 bytes.")]
    HandleTooLong,
    #[msg("Creator metadata has already been provisioned. Edit, instead.")]
    CreatorMetadataAlreadyProvisioned,
    #[msg("Creator distribution must be smaller than total supply.")]
    CreatorDistributionTooLarge,
    #[msg("Primary sale is sold out. Check secondary markets.")]
    SoldOut,
}
