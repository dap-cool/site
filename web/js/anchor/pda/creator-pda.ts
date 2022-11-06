import {PublicKey} from "@solana/web3.js";
import {Program} from "@project-serum/anchor";
import {DapCool} from "../idl";

export interface Creator {
    handle: string
    authority: PublicKey
    numCollections: number
    pinned: Pinned
}

export interface Pinned {
    collections: number[]
}

export async function deriveCreatorPda(program: Program<DapCool>, handle: string): Promise<PublicKey> {
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

export async function getCreatorPda(program: Program<DapCool>, pda: PublicKey): Promise<Creator> {
    const fetched = await program.account.creator.fetch(pda);
    return {
        handle: fetched.handle,
        authority: fetched.authority,
        numCollections: fetched.numCollections,
        pinned: fetched.pinned
    } as Creator
}

export async function assertCreatorPdaDoesNotExistAlready(
    app,
    program: Program<DapCool>,
    handle: string
): Promise<PublicKey | null> {
    // derive pda
    const pda = await deriveCreatorPda(program, handle);
    // fetch pda
    let creator: PublicKey | null;
    try {
        await getCreatorPda(program, pda);
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
        creator = null;
    } catch (error) {
        const msg = "handle is still available: " + handle;
        console.log(msg);
        creator = pda;
    }
    return creator
}

export async function assertCreatorPdaDoesExistAlreadyForCreator(
    app,
    program: Program<DapCool>,
    handle: string
): Promise<Creator | null> {
    return await assertCreatorPdaDoesExistAlready(app, program, handle, "creator-handle-dne")
}

export async function assertCreatorPdaDoesExistAlreadyForCollector(
    app,
    program: Program<DapCool>,
    handle: string
): Promise<Creator | null> {
    return await assertCreatorPdaDoesExistAlready(app, program, handle, "collector-handle-dne")
}

async function assertCreatorPdaDoesExistAlready(
    app,
    program: Program<DapCool>,
    handle: string,
    listener: string
): Promise<Creator | null> {
    // derive pda
    const pda = await deriveCreatorPda(program, handle);
    // fetch pda
    let creator: Creator | null;
    try {
        creator = await getCreatorPda(program, pda);
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
        creator = null;
    }
    return creator
}

export function validateHandleForNewCreator(app, handle: string): string | null {
    return validateHandle(app, handle, "new-creator-handle-invalid")
}

export function validateHandleForExistingCreator(app, handle: string): string | null {
    return validateHandle(app, handle, "existing-creator-handle-invalid")
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
