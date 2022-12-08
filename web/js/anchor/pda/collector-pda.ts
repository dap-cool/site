import {PublicKey} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import {DapCool} from "../idl/dap";

export interface CollectorPda {
    address: PublicKey
    bump: number
}

export interface CollectionPda {
    address: PublicKey
    bump: number
}

export interface CollectedPda {
    address: PublicKey
    bump: number
}

export interface Collector {
    numCollected: number,
}

export interface Collection {
    mint: PublicKey,
    handle: string,
    index: number,
}

export interface Collected {
    collected: boolean
}

export async function getCollectorPda(program: Program<DapCool>, pda: CollectorPda): Promise<Collector> {
    const fetched = await program.account.collector.fetch(pda.address);
    return {
        numCollected: fetched.numCollected
    }
}

export async function getCollectedPda(program: Program<DapCool>, pda: CollectedPda): Promise<Collected> {
    return (await program.account.collected.fetch(pda.address)) as Collected
}

export async function getAllCollectionPda(
    provider: AnchorProvider,
    program: Program<DapCool>,
    collector: Collector
): Promise<Collection[]> {
    const derived: CollectionPda[] = await Promise.all(
        Array.from(new Array(collector.numCollected), async (_, i) =>
            await deriveCollectionPda(provider, program, i + 1)
        )
    );
    return await getManyCollectionPda(program, derived)
}

async function getManyCollectionPda(
    program: Program<DapCool>,
    derived: CollectionPda[]
): Promise<Collection[]> {
    const fetched = await program.account.collection.fetchMultiple(
        derived.map(pda => pda.address)
    );
    console.log("fetched -->", fetched);
    return fetched.map(obj => {
            return obj as Collection;
        }
    )
}

export async function deriveCollectorPda(provider: AnchorProvider, program: Program<DapCool>): Promise<CollectorPda> {
    let pda, bump
    [pda, bump] = await PublicKey.findProgramAddress(
        [
            Buffer.from(SEED),
            provider.wallet.publicKey.toBuffer()
        ],
        program.programId
    );
    return {
        address: pda,
        bump
    }
}

export async function deriveCollectionPda(
    provider: AnchorProvider,
    program: Program<DapCool>,
    index: number
): Promise<CollectionPda> {
    let pda, bump;
    [pda, bump] = await PublicKey.findProgramAddress(
        [
            Buffer.from(SEED),
            provider.wallet.publicKey.toBuffer(),
            Buffer.from([index])
        ],
        program.programId
    );
    return {
        address: pda,
        bump
    }
}

export function deriveCollectedPda(
    provider: AnchorProvider,
    program: Program<DapCool>,
    mint: PublicKey
): CollectedPda {
    let pda, bump;
    [pda, bump] = PublicKey.findProgramAddressSync(
        [
            Buffer.from(SEED),
            provider.wallet.publicKey.toBuffer(),
            mint.toBuffer()
        ],
        program.programId
    );
    return {
        address: pda,
        bump
    }
}

const SEED = "collector";
