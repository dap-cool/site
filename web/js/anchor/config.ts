import {clusterApiUrl, PublicKey} from "@solana/web3.js";


export const COMMITMENT = "processed";
export const PROGRAM_ID = new PublicKey("Gqe2dtQYS3GBzyrDaMmHE4JcJAW7cFhiBsNQpaSGtzFV");

// const localnet = "http://127.0.0.1:8899";
// const devnet = clusterApiUrl("devnet");
// const mainnet = clusterApiUrl("mainnet-beta");
const mainnet = "https://solana-api.projectserum.com"
export const NETWORK = mainnet;
