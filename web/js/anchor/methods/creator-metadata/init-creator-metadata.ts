import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
import * as DapSdk from "@dap-cool/sdk";
import * as CreatorMetadata from "../../../shdw/creator/creator-metadata";
import {DapCool} from "../../idl/dap";
import {deriveCreatorPda, getCreatorPda} from "../../pda/creator-pda";
import {getGlobal} from "../../pda/get-global";
import {getShadowAta} from "../../../shdw/creator/creator-metadata";

export async function initCreatorMetadata(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>;
        token: Program<SplToken>
    }
): Promise<void> {
    try {
        const provisioned = await DapSdk.provision(
            provider.connection,
            provider.wallet,
            3 * 1_000_000 // 3 + 2
        );
        const shadowAta = await getShadowAta(
            provider,
            programs.token
        );
        const metadata = CreatorMetadata.encode(
            {
                url: provisioned.account,
                logo: null,
                bio: null,
                banner: null,
                shadowAta
            }
        );
        await DapSdk.uploadFile(
            metadata,
            provisioned.drive,
            provisioned.account
        );
        const creatorPda = await deriveCreatorPda(
            provider,
            programs.dap
        );
        const creator = await getCreatorPda(
            programs.dap,
            creatorPda
        );
        await programs
            .dap
            .methods
            .initCreatorMetadata(
                provisioned.account as any
            ).accounts(
                {
                    handle: creator.handle,
                    payer: provider.wallet.publicKey
                }
            ).rpc();
        await getGlobal(
            app,
            provider,
            programs
        );
    } catch (error) {
        console.log(error);
        app.ports.exception.send(
            JSON.stringify(
                {
                    message: "caught exception provisioning storage for your metadata 👀"
                }
            )
        );
    }
}
