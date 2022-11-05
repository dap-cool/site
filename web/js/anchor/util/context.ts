import {Connection, Keypair} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import {COMMITMENT, NETWORK, PROGRAM_ID} from "../config";
import {EphemeralWallet, PhantomWallet} from "../wallet";
import {SomosCrowd, IDL} from "../idl";

// get provider & program
export function getPP(_phantom: any): { provider: AnchorProvider; program: Program<SomosCrowd> } {
    // build wallet
    const wallet = new PhantomWallet(_phantom);
    // set provider
    const connection = new Connection(NETWORK, COMMITMENT);
    const provider = new AnchorProvider(connection, wallet, AnchorProvider.defaultOptions());
    // program
    const program = new Program<SomosCrowd>(IDL, PROGRAM_ID, provider);
    return {provider: provider, program: program}
}

// get ephemeral provider & program
export function getEphemeralPP(): { provider: AnchorProvider; program: Program<SomosCrowd> } {
    const keypair = Keypair.generate();
    // build wallet
    const wallet = new EphemeralWallet(keypair);
    // set provider
    const connection = new Connection(NETWORK, COMMITMENT);
    const provider = new AnchorProvider(connection, wallet, AnchorProvider.defaultOptions());
    // program
    const program = new Program<SomosCrowd>(IDL, PROGRAM_ID, provider);
    return {provider: provider, program: program}
}
