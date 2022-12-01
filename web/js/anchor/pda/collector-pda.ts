import {PublicKey} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import {DapCool} from "../idl/dap";

export interface Collector {
    numCollected: number,
}

export interface Collection {
    mint: PublicKey,
    handle: string,
    index: number,
}

export async function getCollectorPda(program: Program<DapCool>, pda: PublicKey): Promise<Collector> {
    const fetched = await program.account.collector.fetch(pda);
    return {
        numCollected: fetched.numCollected
    }
}

export async function getAllCollectionPda(
    provider: AnchorProvider,
    program: Program<DapCool>,
    collector: Collector
): Promise<Collection[]> {
    // derive all collections
    const derived: PublicKey[] = await Promise.all(
        Array.from(new Array(collector.numCollected), async (_, i) =>
            await deriveCollectionPda(provider, program, i + 1)
        )
    )
    // fetch all collections
    const fetched = await program.account.collection.fetchMultiple(
        derived
    );
    console.log("fetched -->", fetched);
    return fetched.filter(Boolean).map(obj => {
            return obj as Collection;
        }
    )
}

export async function deriveCollectorPda(provider: AnchorProvider, program: Program<DapCool>): Promise<PublicKey> {
    // derive collector pda
    let collectorPda: PublicKey, _;
    [collectorPda, _] = await PublicKey.findProgramAddress(
        [
            Buffer.from(SEED),
            provider.wallet.publicKey.toBuffer()
        ],
        program.programId
    );
    return collectorPda
}

export async function deriveCollectionPda(
    provider: AnchorProvider,
    program: Program<DapCool>,
    index: number
): Promise<PublicKey> {
    // derive collection pda
    let collectionPda: PublicKey, _;
    [collectionPda, _] = await PublicKey.findProgramAddress(
        [
            Buffer.from(SEED),
            provider.wallet.publicKey.toBuffer(),
            Buffer.from([index])
        ],
        program.programId
    );
    return collectionPda
}

const SEED = "collector";
