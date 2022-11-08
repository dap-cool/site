import {clusterApiUrl, PublicKey} from "@solana/web3.js";


export const COMMITMENT = "processed";
export const PROGRAM_ID = new PublicKey("J5CrETfFZvMZNmuir7tDV7icY4tKrZ9iTSEeS7Tk8Bcp");

// const localnet = "http://127.0.0.1:8899";
// const devnet = clusterApiUrl("devnet");
// const mainnet = clusterApiUrl("mainnet-beta");
const mainnet = "https://solana-api.projectserum.com"
export const NETWORK = mainnet;
