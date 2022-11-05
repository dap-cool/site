import {getAuthorityPda} from "./authority-pda";

export async function getCreatorCollections(program, creator) {
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
