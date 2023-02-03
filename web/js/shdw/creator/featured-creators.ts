import {CreatorMetadata} from "./creator-metadata";
import {Program} from "@project-serum/anchor";
import {DapCool} from "../../anchor/idl/dap";
import {deriveHandlePda, getHandlePda} from "../../anchor/pda/handle-pda";
import {FEATURED_CREATORS} from "../../anchor/config";

export interface FeaturedCreator {
    handle: string
    metadata: CreatorMetadata
}

export async function fetch(app, program: Program<DapCool>): Promise<void> {
    const fetched = await Promise.all(
        FEATURED_CREATORS.map( async (handle) =>
            await _fetch(
                program,
                handle
            )
        )
    );
    app.ports.success.send(
        JSON.stringify(
            {
                listener: "global-fetched-featured-creators",
                more: JSON.stringify(
                    fetched
                )
            }
        )
    );
}

export async function _fetch(program: Program<DapCool>, handle: string): Promise<FeaturedCreator> {
    const handlePda = await deriveHandlePda(
        program,
        handle
    );
    const handleObj = await getHandlePda(
        program,
        handlePda.address
    );
    return {
        handle: handle,
        metadata: handleObj.metadata as CreatorMetadata
    }
}
