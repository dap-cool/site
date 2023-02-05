import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
import * as DapSdk from "@dap-cool/sdk";
import {DapCool} from "../../idl/dap";
import {Logo, editMetadata, CreatorMetadata} from "../../../shdw/creator/creator-metadata";
import {deriveCreatorPda, getCreatorPda} from "../../pda/creator-pda";
import {getHandlePda} from "../../pda/handle-pda";
import {compressImage, dataUrlToBlob} from "../../../util/blob-util";
import {getGlobal} from "../../pda/get-global";
import {version} from "../../../shdw/config";

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
        provider,
        programs,
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
    const oldMetadata = handle.metadata as CreatorMetadata;
    const newMetadata = {
        url: oldMetadata.url,
        bio: oldMetadata.bio,
        logo: file.name,
        banner: oldMetadata.banner,
        shadowAta: oldMetadata.shadowAta
    };
    await DapSdk.uploadFile(
        file,
        client,
        oldMetadata.url
    );
    await client.deleteFile(
        oldMetadata.url,
        oldMetadata.logo,
        version
    );
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
