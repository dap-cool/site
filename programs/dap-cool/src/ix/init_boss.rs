use anchor_lang::prelude::*;
use crate::InitBoss;

pub fn ix(ctx: Context<InitBoss>) -> Result<()> {
    // get accounts
    let boss = &mut ctx.accounts.boss;
    let payer = &ctx.accounts.payer;
    let usdc = &ctx.accounts.usdc;
    // write to pda
    boss.authority = payer.key();
    boss.usdc = usdc.key();
    boss.fee = 0;
    Ok(())
}
