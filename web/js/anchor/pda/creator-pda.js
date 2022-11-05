import {web3} from "@project-serum/anchor";

export async function deriveCreatorPda(program, handle) {
    // derive pda
    let pda, _;
    [pda, _] = await web3.PublicKey.findProgramAddress(
        [
            Buffer.from(handle)
        ],
        program.programId
    );
    return pda
}

export async function getCreatorPda(program, pda) {
    return await program.account.creator.fetch(pda);
}

export async function assertCreatorPdaDoesNotExistAlready(app, program, handle) {
    // derive pda
    const pda = await deriveCreatorPda(program, handle);
    // fetch pda
    let creator;
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

export async function assertCreatorPdaDoesExistAlreadyForCreator(app, program, handle) {
    return await assertCreatorPdaDoesExistAlready(app, program, handle, "creator-handle-dne")
}

export async function assertCreatorPdaDoesExistAlreadyForCollector(app, program, handle) {
    return await assertCreatorPdaDoesExistAlready(app, program, handle, "collector-handle-dne")
}

async function assertCreatorPdaDoesExistAlready(app, program, handle, listener) {
    // derive pda
    const pda = await deriveCreatorPda(program, handle);
    // fetch pda
    let creator;
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

export function validateHandleForNewCreator(app, handle) {
    return validateHandle(app, handle, "new-creator-handle-invalid")
}

export function validateHandleForExistingCreator(app, handle) {
    return validateHandle(app, handle, "existing-creator-handle-invalid")
}

export function validateHandleForCollector(app, handle) {
    return validateHandle(app, handle, "collector-handle-invalid")
}

function validateHandle(app, handle, listener) {
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

function isValidHandle(handle) {
    return (handle.length <= 16)
}
