import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
import * as DapSdk from "@dap-cool/sdk";
import * as CreatorMetadata from "../../../shdw/creator/creator-metadata";
import {DapCool} from "../../idl/dap";
import {deriveAtaPda, RawSplTokenAccount} from "../../pda/get-token-account";
import {SHDW, SHDW_DECIMALS} from "../../util/constants";
import {deriveCreatorPda, getCreatorPda} from "../../pda/creator-pda";
import {getGlobal} from "../../pda/get-global";

export async function initCreatorMetadata(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>;
        token: Program<SplToken>
    }
): Promise<void> {
    const shdwAtaPda = deriveAtaPda(
        provider,
        SHDW
    );
    try {
        const shdwTokenAccount = await programs.token.account.token.fetch(
            shdwAtaPda
        ) as RawSplTokenAccount;
        if ((shdwTokenAccount.amount * SHDW_DECIMALS) >= 0.25) {
            try {
                const provisioned = await DapSdk.provision(
                    provider.connection,
                    provider.wallet,
                    3 * 1_000_000 // 3 + 2
                );
                const metadata = CreatorMetadata.encode(
                    {
                        url: provisioned.account,
                        logo: null,
                        bio: null,
                        banner: null,
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
        } else {
            console.log("shdw-token-account insufficient balance");
            const message =
                "It looks like this wallet has an insufficient balance of $SHDW token!"
                + " " + "So go get you some more! We require at least 0.25 of the token"
                + " " + "to ensure your transaction is funded for the max upload size of 1GB 😄"
                + " " + "follow the link below to Jupiter Exchange to swap for some in seconds"
                + " " + "or use your favorite exchange ⬇️";
            const href = "https://jup.ag/swap/SOL-SHDW";
            app.ports.exception.send(
                JSON.stringify(
                    {
                        message: message,
                        href: {
                            url: href,
                            internal: false
                        }
                    }
                )
            );
        }
    } catch (error) {
        console.log(error);
        console.log("shdw-token-account dne");
        const message =
            "It looks like this wallet has never held $SHDW token!"
            + " " + "So go get you some! You'll want at least 0.25 of the token"
            + " " + "which is equivalent to 1GB of permanent storage 😄"
            + " " + "follow the link below to Jupiter Exchange to swap for some in seconds"
            + " " + "or use your favorite exchange ⬇️";
        const href = "https://jup.ag/swap/SOL-SHDW";
        app.ports.exception.send(
            JSON.stringify(
                {
                    message: message,
                    href: {
                        url: href,
                        internal: false
                    }
                }
            )
        );
    }
}
