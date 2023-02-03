import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
import * as DapSdk from "@dap-cool/sdk";
import {DapCool} from "../../idl/dap";
import {Logo, editMetadata} from "../../../shdw/creator/creator-metadata";
import {deriveCreatorPda, getCreatorPda} from "../../pda/creator-pda";
import {getHandlePda} from "../../pda/handle-pda";
import {compressImage, dataUrlToBlob} from "../../../util/blob-util";
import {getGlobal} from "../../pda/get-global";

export async function uploadLogo(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        token: Program<SplToken>
    },
    logo: Logo
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
    const blob = await dataUrlToBlob(
        logo.dataUrl
    );
    const compressed = await compressImage(
        blob
    );
    const file = new File(
        [compressed],
        logo.name,
        {
            type: blob.type
        }
    );
    const metadata = {
        url: handle.metadata.url,
        bio: handle.metadata.bio,
        logo: file.name,
        banner: handle.metadata.banner
    };
    await DapSdk.uploadFile(
        file,
        client,
        handle.metadata.url
    );
    await editMetadata(
        metadata,
        client
    );
    await getGlobal(
        app,
        provider,
        programs
    );
}
