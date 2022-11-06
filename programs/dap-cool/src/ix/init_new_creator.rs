use anchor_lang::Key;
use anchor_lang::prelude::{Context, Result};
use crate::{InitNewCreator, pda};
use crate::error::CustomErrors;
use crate::pda::handle::Pinned;

pub fn ix(
    ctx: Context<InitNewCreator>,
    handle: String,
) -> Result<()> {
    let handle_pda = &mut ctx.accounts.handle_pda;
    // authority
    handle_pda.authority = ctx.accounts.payer.key();
    // handle
    validate_handle(&handle)?;
    handle_pda.handle = handle;
    // collections
    handle_pda.num_collections = 0;
    handle_pda.pinned = Pinned { collections: [0; 10] };
    Ok(())
}

fn validate_handle(handle: &String) -> Result<()> {
    match handle.len() > pda::handle::MAX_HANDLE_LENGTH {
        true => {
            Err(CustomErrors::HandleTooLong.into())
        }
        false => {
            Ok(())
        }
    }
}
