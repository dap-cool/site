import {AnchorProvider, Program, web3} from "@project-serum/anchor";
import {getPhantom} from "./phantom";
import {PhantomWallet} from "./wallet";
import {RPC_URL} from "./rpc";
import {IDL} from "./dap";

// get phantom
const phantom = await getPhantom();
// build wallet
const wallet = new PhantomWallet(phantom);
// build connection
const connection = new web3.Connection(
    RPC_URL,
    AnchorProvider.defaultOptions()
);
// build provider & program
const provider = new AnchorProvider(
    connection,
    wallet,
    AnchorProvider.defaultOptions()
);
const program = new Program(
    IDL,
    new web3.PublicKey("54eGWoBhZePCHVUWScjFznKx7ZUaLwa8qCenauN5ncLK"),
    provider
);
// set usdc address
const usdc = new web3.PublicKey("EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v");

app.ports.init.subscribe(async function () {
    // derive pda
    let pda, _;
    [pda, _] = web3.PublicKey.findProgramAddressSync(
        [
            Buffer.from("boss")
        ],
        program.programId
    )
    // invoke init tariff
    await program.methods
        .initBoss()
        .accounts({
            boss: pda,
            usdc: usdc,
            payer: provider.wallet.publicKey
        }).rpc();
    // fetch account
    let boss = await program.account.boss.fetch(
        pda
    );
    console.log(boss);
})
