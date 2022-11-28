import {Connection, Keypair} from "@solana/web3.js";
import {AnchorProvider, Program, Spl, SplToken} from "@project-serum/anchor";
import {COMMITMENT, NETWORK, PROGRAM_ID} from "../config";
import {EphemeralWallet, PhantomWallet} from "../wallet";
import {DapCool, IDL} from "../idl";

// get provider & program
export function getPP(_phantom: any): {
    provider: AnchorProvider;
    programs: {
        dap: Program<DapCool>;
        token: Program<SplToken>
    }
} {
    // build wallet
    const wallet = new PhantomWallet(_phantom);
    // set provider
    const connection = new Connection(NETWORK, COMMITMENT);
    const provider = new AnchorProvider(connection, wallet, AnchorProvider.defaultOptions());
    // dap-cool program
    const dapCoolProgram = new Program<DapCool>(IDL, PROGRAM_ID, provider);
    // spl-token program
    const tokenProgram: Program<SplToken> = Spl.token(provider);
    return {
        provider: provider,
        programs: {
            dap: dapCoolProgram,
            token: tokenProgram
        }
    }
}

// get ephemeral provider & program
export function getEphemeralPP(): {
    provider: AnchorProvider;
    programs: {
        dap: Program<DapCool>;
        token: Program<SplToken>
    }
} {
    const keypair = Keypair.generate();
    // build wallet
    const wallet = new EphemeralWallet(keypair);
    // set provider
    const connection = new Connection(NETWORK, COMMITMENT);
    const provider = new AnchorProvider(connection, wallet, AnchorProvider.defaultOptions());
    // dap-cool program
    const dapCoolProgram = new Program<DapCool>(IDL, PROGRAM_ID, provider);
    // spl-token program
    const tokenProgram: Program<SplToken> = Spl.token(provider);
    return {
        provider: provider,
        programs: {
            dap: dapCoolProgram,
            token: tokenProgram
        }
    }
}
