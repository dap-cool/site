import {AnchorProvider, Program, SplToken} from "@project-serum/anchor";
import {PublicKey, SystemProgram, SYSVAR_RENT_PUBKEY} from "@solana/web3.js";
import {
    CollectionAuthority, deriveAuthorityPda,
    getAuthorityPda,
    getManyAuthorityPdaForCollector,
    getManyAuthorityPdaForCreator
} from "../pda/authority-pda";
import {deriveHandlePda, getHandlePda} from "../pda/handle-pda";
import {
    MPL_TOKEN_METADATA_PROGRAM_ID,
    SPL_ASSOCIATED_TOKEN_PROGRAM_ID,
    SPL_TOKEN_PROGRAM_ID
} from "../util/constants";
import {DapCool} from "../idl/dap";
import {
    deriveCollectedPda,
    deriveCollectionPda,
    deriveCollectorPda,
    getAllCollectionPda, getCollectedPda,
    getCollectorPda
} from "../pda/collector-pda";
import {deriveCreatorPda, getCreatorPda} from "../pda/creator-pda";
import {getUploads} from "../pda/datum-pda";
import {deriveBossPda, getBossPda} from "../pda/boss-pda";
import * as FeaturedCreators from "../../shdw/creator/featured-creators";

export async function mintNewCopy(
    app,
    provider: AnchorProvider,
    programs: {
        dap: Program<DapCool>,
        token: Program<SplToken>
    },
    handle: string,
    index: number
) {
    try {
        // derive & fetch boss pda
        const bossPda = deriveBossPda(
            programs.dap
        );
        const boss = await getBossPda(
            programs.dap,
            bossPda
        );
        // derive collector pda
        const collectorPda = await deriveCollectorPda(
            provider,
            programs.dap
        );
        // try getting collector
        let collectorArray: CollectionAuthority[]
        let collectorNextCollectionIndex: number;
        try {
            // fetch collector
            const collector = await getCollectorPda(
                programs.dap,
                collectorPda
            );
            // fetch all collected
            const collectedPda = await getAllCollectionPda(
                provider,
                programs.dap,
                collector
            );
            collectorArray = await getManyAuthorityPdaForCollector(
                provider,
                programs,
                collectedPda
            );
            // increment
            collectorNextCollectionIndex = collector.numCollected + 1;
        } catch (error) {
            console.log("could not find collector on-chain");
            collectorNextCollectionIndex = 1;
        }
        // derive collection pda
        const collectionPda = await deriveCollectionPda(
            provider,
            programs.dap,
            collectorNextCollectionIndex
        );
        // derive & fetch handle pda
        const handlePda = await deriveHandlePda(
            programs.dap,
            handle
        );
        const fetchedHandle = await getHandlePda(
            programs.dap,
            handlePda.address
        );
        // derive authority pda with bump
        const authorityPda = await deriveAuthorityPda(
            programs.dap,
            handle,
            index
        );
        // get authority pda
        const authority: CollectionAuthority = await getAuthorityPda(
            provider,
            programs,
            authorityPda
        );
        // derive collected pda
        const collectedPda = deriveCollectedPda(
            provider,
            programs.dap,
            authority.accounts.mint
        );
        // get collected pda
        let collectedBefore;
        try {
            const fetched = await getCollectedPda(
                programs.dap,
                collectedPda
            );
            collectedBefore = fetched.collected;
        } catch (error) {
            console.log("first time collecting this item")
            collectedBefore = false;
        }
        // derive mint ata
        let mintAta, _;
        [mintAta, _] = PublicKey.findProgramAddressSync(
            [
                provider.wallet.publicKey.toBuffer(),
                SPL_TOKEN_PROGRAM_ID.toBuffer(),
                authority.accounts.mint.toBuffer()
            ],
            SPL_ASSOCIATED_TOKEN_PROGRAM_ID
        );
        // derive usdc ata (from src)
        let usdcAtaSrc;
        [usdcAtaSrc, _] = PublicKey.findProgramAddressSync(
            [
                provider.wallet.publicKey.toBuffer(),
                SPL_TOKEN_PROGRAM_ID.toBuffer(),
                boss.usdc.toBuffer()
            ],
            SPL_ASSOCIATED_TOKEN_PROGRAM_ID
        );
        // derive usdc ata (to handle as dst)
        let usdcAtaDstHandle;
        [usdcAtaDstHandle, _] = PublicKey.findProgramAddressSync(
            [
                fetchedHandle.authority.toBuffer(),
                SPL_TOKEN_PROGRAM_ID.toBuffer(),
                boss.usdc.toBuffer()
            ],
            SPL_ASSOCIATED_TOKEN_PROGRAM_ID
        );
        // build bumps
        const bumps = {
            boss: bossPda.bump,
            handle: handlePda.bump,
            authority: authorityPda.bump,
        };
        // invoke rpc
        console.log("minting new copy");
        await programs.dap.methods
            .mintNewCopy(
                bumps as any,
                index as any
            )
            .accounts(
                {
                    boss: bossPda.address,
                    collector: collectorPda.address,
                    collectionPda: collectionPda.address,
                    collected: collectedPda.address,
                    handle: handlePda.address,
                    authority: authorityPda.address,
                    mint: authority.accounts.mint,
                    mintAta: mintAta,
                    usdc: boss.usdc,
                    usdcAtaSrc: usdcAtaSrc,
                    usdcAtaDstHandle: usdcAtaDstHandle,
                    payer: provider.wallet.publicKey,
                    tokenProgram: SPL_TOKEN_PROGRAM_ID,
                    associatedTokenProgram: SPL_ASSOCIATED_TOKEN_PROGRAM_ID,
                    metadataProgram: MPL_TOKEN_METADATA_PROGRAM_ID,
                    systemProgram: SystemProgram.programId,
                    rent: SYSVAR_RENT_PUBKEY,
                }
            )
            .rpc();
        // get uploads
        const uploads = await getUploads(
            provider,
            programs.dap,
            {
                meta: {
                    handle: authority.meta.handle
                },
                accounts: {
                    mint: authority.accounts.mint.toString()
                }
            }
        );
        // build last-collected
        const lastCollectedAuthority = authority;
        // add associated-token-account balance
        lastCollectedAuthority.accounts.ata = {
            balance: authority.accounts.ata.balance + 1,
            address: authority.accounts.ata.address
        };
        // increment num-minted
        lastCollectedAuthority.math.numMinted = authority.math.numMinted + 1;
        // build collected
        if (collectorNextCollectionIndex === 1) {
            collectorArray = [lastCollectedAuthority];
        } else {
            if (collectedBefore) {
                // update existing collection
                collectorArray = collectorArray.map(ca => {
                        if (ca.accounts.mint.equals(lastCollectedAuthority.accounts.mint)) {
                            return lastCollectedAuthority
                        } else {
                            return ca
                        }
                    }
                );
            } else {
                // concat new collection
                collectorArray = collectorArray.concat([lastCollectedAuthority]);
            }
        }
        // fetch featured creators
        const featuredCreators = await FeaturedCreators.fetch(
            programs.dap
        );
        // fetch collections & set global
        let global;
        try {
            const creatorPda = await deriveCreatorPda(
                provider,
                programs.dap
            );
            const creator = await getCreatorPda(
                programs.dap,
                creatorPda
            );
            const fetchedHandle = await getHandlePda(
                programs.dap,
                creator.handle
            );
            const collections = await getManyAuthorityPdaForCreator(
                provider,
                programs,
                fetchedHandle
            );
            global = {
                handle: fetchedHandle.handle,
                wallet: provider.wallet.publicKey.toString(),
                collections: collections,
                collected: collectorArray,
                metadata: fetchedHandle.metadata,
                featuredCreators
            };
        } catch (error) {
            console.log("could not find creator on-chain");
            global = {
                wallet: provider.wallet.publicKey.toString(),
                collected: collectorArray,
                featuredCreators
            }
        }
        // send success to elm
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: "collector-collection-printed",
                    more: JSON.stringify(
                        {
                            master: authority,
                            copied: lastCollectedAuthority,
                            datum: uploads,
                            global: global
                        }
                    )
                }
            )
        );
    } catch (error) {
        console.log(error);
        // send caught exception to elm
        app.ports.exception.send(
            JSON.stringify(
                {
                    message: "caught exception printing collection!"
                }
            )
        );
    }
}
