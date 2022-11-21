import {Program} from "@project-serum/anchor";
import {CollectionAuthority, getAuthorityPda} from "./authority-pda";
import {DapCool} from "../idl";
import {Handle} from "./handle-pda";

// TODO; batch
export async function getAllCollectionsFromHandle(
    program: Program<DapCool>,
    handle: Handle
): Promise<CollectionAuthority[]> {
    // build array of collections
    return await Promise.all(
        Array.from(new Array(handle.numCollections), async (_, index) => {
                // fetch authority for each collection
                const increment = index + 1;
                return await getAuthorityPda(program, handle.handle, increment);
            }
        )
    )
}
