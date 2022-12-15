import {PublicKey} from "@solana/web3.js";
import {AnchorProvider, Program} from "@project-serum/anchor";
import * as DapSdk from "@dap-cool/sdk";
import {deriveHandlePda, getHandlePda} from "./handle-pda";
import {DapCool} from "../idl/dap";

interface FromElm {
    meta: {
        handle: string
    }
    accounts: {
        mint: string
    }
}

interface ToElm extends DapSdk.Datum {
    metadata: {
        title: string
        zip: {
            count: number
            types: string[]
        }
    }
}

export async function getUploads(
    provider: AnchorProvider,
    dapCoolProgram: Program<DapCool>,
    fromElm: FromElm
): Promise<ToElm[]> {
    // get program
    const dapProtocolProgram: Program<DapSdk.DapProtocol> = await DapSdk.getProgram(
        provider
    );
    // derive & get handle pda
    const handlePda = await deriveHandlePda(
        dapCoolProgram,
        fromElm.meta.handle
    );
    const handle = await getHandlePda(
        dapCoolProgram,
        handlePda.address
    );
    // derive & get increment pda
    const incrementPda = await DapSdk.deriveIncrementPda(
        dapProtocolProgram,
        new PublicKey(fromElm.accounts.mint),
        handle.authority
    );
    const increment = await DapSdk.getIncrementPda(
        dapProtocolProgram,
        incrementPda
    );
    // get many datum
    let toElmArray: ToElm[];
    if (increment) {
        const datum = await DapSdk.getManyDatumPda(
            dapProtocolProgram,
            [increment]
        );
        toElmArray = await Promise.all(
            datum.map(async (d) => {
                    const metadata = await DapSdk.getMetaData(
                        d.shadow.url
                    );
                    const toElm = d as ToElm;
                    toElm.metadata = {
                        title: metadata.title,
                        zip: metadata.zip
                    }
                    return toElm
                }
            )
        );
    } else {
        toElmArray = [];
    }
    return toElmArray
}
