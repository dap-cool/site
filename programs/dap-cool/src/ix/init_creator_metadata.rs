use anchor_lang::prelude::*;
use crate::error::CustomErrors;
use crate::InitCreatorMetadata;

pub fn ix(ctx: Context<InitCreatorMetadata>, metadata: Pubkey) -> Result<()> {
    let handle = &mut ctx.accounts.handle;
    match handle.metadata {
        None => {
            handle.metadata = Some(metadata);
            Ok(())
        }
        Some(_) => {
            Err(CustomErrors::CreatorMetadataAlreadyProvisioned.into())
        }
    }
}
