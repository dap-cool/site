import {AnchorProvider, BN, Program, SplToken} from "@project-serum/anchor";
import {Keypair, PublicKey, SystemProgram, SYSVAR_RENT_PUBKEY} from "@solana/web3.js";
import {buildClient, buildUrl, provision, uploadMultipleFiles} from "@dap-cool/sdk";
import {ShdwDrive} from "@shadow-drive/sdk";
import {deriveHandlePda, Handle} from "../pda/handle-pda";
import {
    CollectionAuthority,
    deriveAuthorityPda, getImageUrl,
    getManyAuthorityPdaForCollector,
    getManyAuthorityPdaForCreator
} from "../pda/authority-pda";
import {deriveCollectorPda, getAllCollectionPda, getCollectorPda} from "../pda/collector-pda";
import {deriveBossPda, getBossPda} from "../pda/boss-pda";
import {
    MPL_PREFIX,
    MPL_TOKEN_METADATA_PROGRAM_ID, SPL_ASSOCIATED_TOKEN_PROGRAM_ID,
    SPL_TOKEN_PROGRAM_ID
} from "../util/constants";
import {buildMetaData, readLogo} from "../../shdw/shdw";
import {DapCool} from "../idl/dap";

export interface Form {
    step: number
    retries: number
    meta: {
        name: string
        symbol: string
    }
    shdw: {
        account: PublicKey
        drive: ShdwDrive | null
    } | null
}

export async function creatNft(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        token: Program<SplToken>
    },
    handle: Handle,
    form: Form
) {
    // fetch all collections from handle
    let collections = await getManyAuthorityPdaForCreator(
        provider,
        programs,
        handle
    );
    // fetch all collected from creator pda
    let collected;
    try {
        const collectorPda = await deriveCollectorPda(
            provider,
            programs.dap
        );
        const collector = await getCollectorPda(
            programs.dap,
            collectorPda
        );
        const collectedPda = await getAllCollectionPda(
            provider,
            programs.dap,
            collector
        );
        collected = await getManyAuthorityPdaForCollector(
            provider,
            programs,
            collectedPda
        );
    } catch (error) {
        console.log("could not find collector on-chain");
        collected = [];
    }
    // increment authority index
    const authorityIndex: number = handle.numCollections + 1;
    // kick off upload steps
    if (form.step === 1) {
        try {
            // read logo from input
            const logo = await readLogo();
            // provision space
            form.shdw = await provision(
                provider.connection,
                provider.wallet,
                logo.file
            );
            // bump form
            form.step = 2;
            form.retries = 0;
            form.shdw.drive = null;
            // send to elm
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-creating-new-nft",
                        more: JSON.stringify(
                            {
                                global: {
                                    handle: handle.handle,
                                    wallet: provider.wallet.publicKey.toString(),
                                    collections: collections,
                                    collected: collected,
                                },
                                form: form
                            }
                        )
                    }
                )
            );
        } catch (error) {
            console.log(error);
            console.log("caught exception at step 1");
            // send to elm
            form.retries += 1;
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-creating-new-nft",
                        more: JSON.stringify(
                            {
                                global: {
                                    handle: handle.handle,
                                    wallet: provider.wallet.publicKey.toString(),
                                    collections: collections,
                                    collected: collected,
                                },
                                form: form
                            }
                        )
                    }
                )
            );
        }
    } else if (form.step === 2) {
        try {
            // read logo from input
            const logo = await readLogo();
            // build url
            const url = buildUrl(
                form.shdw.account
            );
            // build new client
            form.shdw.drive = await buildClient(
                provider.connection,
                provider.wallet
            );
            // build metadata
            const logoUrl = url + logo.file.name;
            const metadata: File = buildMetaData(
                handle.handle,
                authorityIndex,
                form.meta.name,
                form.meta.symbol,
                "description",
                logoUrl
            );
            // upload logo + metadata
            await uploadMultipleFiles(
                [logo.file, metadata],
                form.shdw.drive,
                form.shdw.account
            );
            // bump form
            form.step = 3;
            form.retries = 0;
            form.shdw.drive = null;
            // send to elm
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-creating-new-nft",
                        more: JSON.stringify(
                            {
                                global: {
                                    handle: handle.handle,
                                    wallet: provider.wallet.publicKey.toString(),
                                    collections: collections,
                                    collected: collected,
                                },
                                form: form
                            }
                        )
                    }
                )
            );
        } catch (error) {
            console.log(error);
            console.log("caught exception at step 2");
            // send to elm
            form.retries += 1;
            form.shdw.drive = null;
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-creating-new-nft",
                        more: JSON.stringify(
                            {
                                global: {
                                    handle: handle.handle,
                                    wallet: provider.wallet.publicKey.toString(),
                                    collections: collections,
                                    collected: collected,
                                },
                                form: form
                            }
                        )
                    }
                )
            );
        }
    } else if (form.step === 3) {
        try {
            // read logo from input
            const logo = await readLogo();
            // build url
            const url = buildUrl(
                form.shdw.account
            );
            const metadataUrl = url + "meta.json";
            // derive & fetch boss pda
            const bossPda = deriveBossPda(
                programs.dap
            );
            const boss = await getBossPda(
                programs.dap,
                bossPda
            );
            // derive handle pda with bump
            let handlePda = await deriveHandlePda(
                programs.dap,
                handle.handle
            );
            // derive authority pda
            const authorityPda = await deriveAuthorityPda(
                programs.dap,
                handle.handle,
                authorityIndex
            );
            // derive key-pair for mint
            const mint = Keypair.generate();
            // derive associated-token-address
            let mintAta: PublicKey, _;
            [mintAta, _] = PublicKey.findProgramAddressSync(
                [
                    provider.wallet.publicKey.toBuffer(),
                    SPL_TOKEN_PROGRAM_ID.toBuffer(),
                    mint.publicKey.toBuffer()
                ],
                SPL_ASSOCIATED_TOKEN_PROGRAM_ID
            );
            // derive metadata
            let metadataPda, metadataBump;
            [metadataPda, metadataBump] = PublicKey.findProgramAddressSync(
                [
                    Buffer.from(MPL_PREFIX),
                    MPL_TOKEN_METADATA_PROGRAM_ID.toBuffer(),
                    mint.publicKey.toBuffer(),
                ],
                MPL_TOKEN_METADATA_PROGRAM_ID
            );
            // derive usdc ata
            let usdcAta;
            [usdcAta, _] = PublicKey.findProgramAddressSync(
                [
                    provider.wallet.publicKey.toBuffer(),
                    SPL_TOKEN_PROGRAM_ID.toBuffer(),
                    boss.usdc.toBuffer()
                ],
                SPL_ASSOCIATED_TOKEN_PROGRAM_ID
            );
            // bump bumps
            const bumps = {
                boss: bossPda.bump,
                handle: handlePda.bump,
                authority: authorityPda.bump,
                metadata: metadataBump,
            }
            // invoke rpc
            await programs.dap.methods
                .createNft(
                    bumps as any,
                    form.meta.name as any,
                    form.meta.symbol as any,
                    metadataUrl as any,
                    logo.type as any,
                    new BN(10), // TODO; supply
                    new BN(2), // TODO; creator distribution
                    new BN(25000), // TODO; price
                    500 as any // TODO; fee
                )
                .accounts(
                    {
                        boss: bossPda.address,
                        handle: handlePda.address,
                        authority: authorityPda.address,
                        mint: mint.publicKey,
                        mintAta: mintAta,
                        metadata: metadataPda,
                        usdc: boss.usdc,
                        usdcAta: usdcAta,
                        payer: provider.wallet.publicKey,
                        tokenProgram: SPL_TOKEN_PROGRAM_ID,
                        associatedTokenProgram: SPL_ASSOCIATED_TOKEN_PROGRAM_ID,
                        metadataProgram: MPL_TOKEN_METADATA_PROGRAM_ID,
                        systemProgram: SystemProgram.programId,
                        rent: SYSVAR_RENT_PUBKEY,
                    }
                )
                .signers([mint])
                .rpc()
            // fetch pda
            console.log("mint", mint.publicKey.toString());
            // build response for elm
            const justCreated = {
                meta: {
                    // core
                    handle: handle.handle,
                    index: authorityIndex,
                    // meta
                    name: form.meta.name,
                    symbol: form.meta.symbol,
                    uri: metadataUrl,
                    image: getImageUrl(metadataUrl, logo.type),
                    // math
                    numMinted: 1, // TODO; creator-distribution?
                    totalSupply: 10, // TODO; supply
                },
                accounts: {
                    pda: authorityPda.address,
                    mint: mint.publicKey,
                    ata: {
                        balance: 1 // TODO; creator-distribution?
                    }
                }
            } as CollectionAuthority;
            // concat
            collections = collections.concat([justCreated]);
            // send to elm
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-created-new-nft",
                        more: JSON.stringify(
                            {
                                global: {
                                    handle: handle.handle,
                                    wallet: provider.wallet.publicKey.toString(),
                                    collections: collections,
                                    collected: collected,
                                },
                                collection: justCreated
                            }
                        )
                    }
                )
            );
        } catch (error) {
            console.log(error);
            console.log("caught exception at step 3");
            // send to elm
            form.retries += 1;
            app.ports.success.send(
                JSON.stringify(
                    {
                        listener: "creator-creating-new-nft",
                        more: JSON.stringify(
                            {
                                global: {
                                    handle: handle.handle,
                                    wallet: provider.wallet.publicKey.toString(),
                                    collections: collections,
                                    collected: collected,
                                },
                                form: form
                            }
                        )
                    }
                )
            );
        }
    }
}
