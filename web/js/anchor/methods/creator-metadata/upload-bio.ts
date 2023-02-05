import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
import {DapCool} from "../../idl/dap";
import {deriveCreatorPda, getCreatorPda} from "../../pda/creator-pda";
import {getHandlePda} from "../../pda/handle-pda";
import * as DapSdk from "@dap-cool/sdk";
import {CreatorMetadata, editMetadata} from "../../../shdw/creator/creator-metadata";
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
        provider,
        programs,
        creator.handle
    );
    const client = await DapSdk.buildClient(
        provider.connection,
        provider.wallet
    );
    const oldMetadata = handle.metadata as CreatorMetadata;
    const newMetadata = {
        url: oldMetadata.url,
        bio: bio.bio,
        logo: oldMetadata.logo,
        banner: oldMetadata.banner,
        shadowAta: oldMetadata.shadowAta
    } as CreatorMetadata;
    await editMetadata(
        newMetadata,
        client
    );
    await getGlobal(
        app,
        provider,
        programs
    );
}
