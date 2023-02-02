import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
import {DapCool} from "../../idl/dap";
import {deriveCreatorPda, getCreatorPda} from "../../pda/creator-pda";
import {getHandlePda} from "../../pda/handle-pda";
import * as DapSdk from "@dap-cool/sdk";
import {encode} from "./metadata";
import {getGlobal} from "../../pda/get-global";

interface Bio {
    bio: string
}

export async function uploadBio(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        token: Program<SplToken>
    },
    bio: Bio
): Promise<void> {
    const creatorPda = await deriveCreatorPda(
        provider,
        programs.dap
    );
    const creator = await getCreatorPda(
        programs.dap,
        creatorPda
    );
    let handle = await getHandlePda(
        programs.dap,
        creator.handle
    );
    const client = await DapSdk.buildClient(
        provider.connection,
        provider.wallet
    );
    const metadata = encode(
        {
            url: handle.metadata.url,
            bio: bio.bio,
            logo: handle.metadata.logo,
            banner: handle.metadata.banner
        }
    )
    await DapSdk.uploadFile(
        metadata,
        client,
        handle.metadata.url
    );
    await getGlobal(
        app,
        provider,
        programs
    );
}
