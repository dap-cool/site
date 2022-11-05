import {clusterApiUrl, PublicKey} from "@solana/web3.js";


export const COMMITMENT = "processed";
export const PROGRAM_ID = new PublicKey("DB2EAH9DoDcFtsC8AWCcjtLc2E8Hz1Y9t9X4gsDzbYh2");

// const localnet = "http://127.0.0.1:8899";
// const devnet = clusterApiUrl("devnet");
const mainnet = clusterApiUrl("mainnet-beta");
export const NETWORK = mainnet;
