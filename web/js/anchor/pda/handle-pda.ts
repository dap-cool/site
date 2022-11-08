import {PublicKey} from "@solana/web3.js";
import {Program} from "@project-serum/anchor";
import {DapCool} from "../idl";

export interface Handle {
    handle: string
    authority: PublicKey
    numCollections: number
    pinned: Pinned
}

export interface Pinned {
    collections: number[]
}

export async function deriveHandlePda(program: Program<DapCool>, handle: string): Promise<PublicKey> {
    // derive pda
    let pda, _;
    [pda, _] = await PublicKey.findProgramAddress(
        [
            Buffer.from(handle)
        ],
        program.programId
    );
    return pda
}

export async function getHandlePda(program: Program<DapCool>, pda: PublicKey): Promise<Handle> {
    const fetched = await program.account.handle.fetch(pda);
    return {
        handle: fetched.handle,
        authority: fetched.authority,
        numCollections: fetched.numCollections,
        pinned: fetched.pinned
    } as Handle
}

export async function assertHandlePdaDoesNotExistAlready(
    app,
    program: Program<DapCool>,
    handle: string
): Promise<PublicKey | null> {
    // derive pda
    const pda = await deriveHandlePda(program, handle);
    // fetch pda
    let handlePda: PublicKey | null;
    try {
        await getHandlePda(program, pda);
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
        handlePda = pda;
    }
    return handlePda
}

export async function assertHandlePdaDoesExistAlreadyForCreator(
    app,
    global,
    program: Program<DapCool>,
    handle: string
): Promise<Handle | null> {
    return await assertHandlePdaDoesExistAlready(app, global, program, handle, "creator-handle-dne")
}

export async function assertHandlePdaDoesExistAlreadyForCollector(
    app,
    global,
    program: Program<DapCool>,
    handle: string
): Promise<Handle | null> {
    return await assertHandlePdaDoesExistAlready(app, global, program, handle, "collector-handle-dne")
}

async function assertHandlePdaDoesExistAlready(
    app,
    global,
    program: Program<DapCool>,
    handle: string,
    listener: string
): Promise<Handle | null> {
    // derive pda
    const pda = await deriveHandlePda(program, handle);
    // fetch pda
    let handlePda: Handle | null;
    try {
        handlePda = await getHandlePda(program, pda);
        const msg = "found handle: " + handle;
        console.log(msg);
    } catch (error) {
        const msg = "handle does not exist yet: " + handle;
        console.log(msg);
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: listener,
                    global: global,
                    more: JSON.stringify(handle)
                }
            )
        );
        handlePda = null;
    }
    return handlePda
}

export function validateNewHandle(app, global, handle: string): string | null {
    return validateHandle(app, global, handle, "new-creator-handle-invalid")
}

export function validateExistingHandle(app, global, handle: string): string | null {
    return validateHandle(app, global, handle, "existing-creator-handle-invalid")
}

export function validateHandleForCollector(app, global, handle: string): string | null {
    return validateHandle(app, global, handle, "collector-handle-invalid")
}

function validateHandle(app, global, handle: string, listener: string): string | null {
    if (isValidHandle(handle)) {
        return handle
    } else {
        const msg = "invalid handle: " + handle;
        console.log(msg);
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: listener,
                    global: global,
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
