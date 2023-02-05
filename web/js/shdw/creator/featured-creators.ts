import {CreatorMetadata} from "./creator-metadata";
import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
import {DapCool} from "../../anchor/idl/dap";
import {deriveHandlePda, getHandlePda} from "../../anchor/pda/handle-pda";
import {FEATURED_CREATORS} from "../../anchor/config";

export interface FeaturedCreator {
    handle: string
    metadata: CreatorMetadata
}

export async function init(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>;
        token: Program<SplToken>
    }
): Promise<void> {
    const fetched = await fetch(
        provider,
        programs
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

export async function fetch(
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>;
        token: Program<SplToken>
    }
): Promise<FeaturedCreator[]> {
    return await Promise.all(
        FEATURED_CREATORS.map(async (handle) =>
            await _fetch(
                provider,
                programs,
                handle
            )
        )
    );
}

async function _fetch(
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>;
        token: Program<SplToken>
    },
    handle: string
): Promise<FeaturedCreator> {
    const handlePda = await deriveHandlePda(
        programs.dap,
        handle
    );
    const handleObj = await getHandlePda(
        provider,
        programs,
        handlePda.address
    );
    return {
        handle: handle,
        metadata: handleObj.metadata as CreatorMetadata
    }
}
