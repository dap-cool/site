import {PublicKey} from "@solana/web3.js";
import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
import * as CreatorMetadata from "../../shdw/creator/creator-metadata";
import {DapCool} from "../idl/dap";
import {getShadowAta} from "../../shdw/creator/creator-metadata";

export interface HandlePda {
    address: PublicKey
    bump: number
}

export interface Handle {
    handle: string
    authority: PublicKey
    numCollections: number
    metadata: CreatorMetadata.CreatorMetadata | CreatorMetadata.ShadowAta | null
    pinned: Pinned
}

interface RawHandle {
    handle: string
    authority: PublicKey
    numCollections: number
    metadata: PublicKey | null
    pinned: Pinned
}

export interface Pinned {
    collections: number[]
}

export async function deriveHandlePda(program: Program<DapCool>, handle: string): Promise<HandlePda> {
    let pda, bump;
    [pda, bump] = await PublicKey.findProgramAddress(
        [
            Buffer.from(SEED),
            Buffer.from(handle)
        ],
        program.programId
    );
    return {
        address: pda,
        bump
    }
}

const SEED = "handle";

export async function getHandlePda(
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>;
        token: Program<SplToken>
    },
    pda: PublicKey
): Promise<Handle> {
    const fetched = await programs.dap.account.handle.fetch(
        pda
    ) as RawHandle;
    let metadata;
    if (fetched.metadata) {
        metadata = await CreatorMetadata.getMetadata(
            provider,
            programs.token,
            fetched.metadata
        );
    } else {
        metadata = await getShadowAta(
            provider,
            programs.token
        );
    }
    return {
        handle: fetched.handle,
        authority: fetched.authority,
        numCollections: fetched.numCollections,
        metadata: metadata,
        pinned: fetched.pinned
    } as Handle
}

export async function assertHandlePdaDoesNotExistAlready(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>;
        token: Program<SplToken>
    },
    handle: string
): Promise<PublicKey | null> {
    // derive pda
    const pda = await deriveHandlePda(
        programs.dap,
        handle
    );
    // fetch pda
    let handlePda: PublicKey | null;
    try {
        await getHandlePda(
            provider,
            programs,
            pda.address
        );
        const msg = "handle exists already: " + handle;
        console.log(msg);
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: "creator-handle-already-exists",
                    more: JSON.stringify(handle)
                }
            )
        );
        handlePda = null;
    } catch (error) {
        const msg = "handle is still available: " + handle;
        console.log(msg);
        handlePda = pda.address;
    }
    return handlePda
}

export async function assertHandlePdaDoesExistAlreadyForCollector(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>;
        token: Program<SplToken>
    },
    handle: string
): Promise<Handle | null> {
    return await assertHandlePdaDoesExistAlready(app, provider, programs, handle, "collector-handle-dne")
}

async function assertHandlePdaDoesExistAlready(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>;
        token: Program<SplToken>
    },
    handle: string,
    listener: string
): Promise<Handle | null> {
    // derive pda
    const pda = await deriveHandlePda(
        programs.dap,
        handle
    );
    // fetch pda
    let handlePda: Handle | null;
    try {
        handlePda = await getHandlePda(
            provider,
            programs,
            pda.address
        );
        const msg = "found handle: " + handle;
        console.log(msg);
    } catch (error) {
        const msg = "handle does not exist yet: " + handle;
        console.log(msg);
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: listener,
                    more: JSON.stringify(handle)
                }
            )
        );
        handlePda = null;
    }
    return handlePda
}

export function validateNewHandle(app, handle: string): string | null {
    return validateHandle(app, handle, "new-creator-handle-invalid")
}

export function validateHandleForCollector(app, handle: string): string | null {
    return validateHandle(app, handle, "collector-handle-invalid")
}

function validateHandle(app, handle: string, listener: string): string | null {
    if (isValidHandle(handle)) {
        return handle
    } else {
        const msg = "invalid handle: " + handle;
        console.log(msg);
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: listener,
                    more: JSON.stringify(handle)
                }
            )
        );
        return null
    }
}

function isValidHandle(handle: string): boolean {
    return (handle.length <= 16)
}
