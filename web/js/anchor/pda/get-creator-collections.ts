import {Program} from "@project-serum/anchor";
import {CollectionAuthority, getAuthorityPda} from "./authority-pda";
import {DapCool} from "../idl";
import {Creator} from "./creator-pda";

export async function getCreatorCollections(
    program: Program<DapCool>,
    creator: Creator
): Promise<CollectionAuthority[]> {
    // build array of collections
    return await Promise.all(
        Array.from(new Array(creator.numCollections), async (_, index) => {
                // fetch authority for each collection
                const increment = index + 1;
                return await getAuthorityPda(program, creator.handle, increment);
            }
        )
    )
}
