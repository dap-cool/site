import {PublicKey} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import {DapCool} from "../idl/dap";

export interface Collector {
    numCollected: number,
}

export interface Collection {
    mint: PublicKey,
    marked: boolean,
    handle: string,
    index: number,
}

export async function getCollectorPda(program: Program<DapCool>, pda: PublicKey): Promise<Collector> {
    const fetched = await program.account.collector.fetch(pda);
    return {
        numCollected: fetched.numCollected
    }
}

export async function getCollectionPda(program: Program<DapCool>, pda: PublicKey): Promise<Collection> {
    return (await program.account.collection.fetch(pda)) as Collection
}

export async function getAllCollectionPda(
    provider: AnchorProvider,
    program: Program<DapCool>,
    collector: Collector
): Promise<Collection[]> {
    const derived: PublicKey[] = await Promise.all(
        Array.from(new Array(collector.numCollected), async (_, i) =>
            await deriveCollectionPda(provider, program, i + 1)
        )
    );
    return await getManyCollectionPda(program, derived)
}

export async function getAllButLastCollectionPda(
    provider: AnchorProvider,
    program: Program<DapCool>,
    collector: Collector
): Promise<Collection[]> {
    const derived: PublicKey[] = (await Promise.all(
        Array.from(new Array(collector.numCollected), async (_, i) => {
                const index = i + 1;
                if (index === collector.numCollected) {
                    return null
                } else {
                    return await deriveCollectionPda(provider, program, index)
                }
            }
        )
    )).filter(Boolean);
    return await getManyCollectionPda(program, derived)
}

async function getManyCollectionPda(
    program: Program<DapCool>,
    derived: PublicKey[]
): Promise<Collection[]> {
    const fetched = await program.account.collection.fetchMultiple(
        derived
    );
    console.log("fetched -->", fetched);
    return fetched.map(obj => {
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
