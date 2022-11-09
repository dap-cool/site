import {getPP} from "./context";
import {deriveCreatorPda, getCreatorPda} from "../pda/creator-pda";
import {getHandlePda} from "../pda/handle-pda";

type Global = { wallet: string; handle: string } | { wallet: string } | string;

// todo;
export async function deriveGlobal(phantom): Promise<Global> {
    let global: Global;
    if (phantom) {
        // get provider & program
        const pp = getPP(phantom);
        // derive creator pda
        const creatorPda = await deriveCreatorPda(pp.provider, pp.program);
        try {
            // check for creator on chain
            const creator = await getCreatorPda(pp.program, creatorPda);
            // fetch handle
            const handle = await getHandlePda(pp.program, creator.handle);
            // set global
            global = {
                wallet: pp.provider.wallet.publicKey.toString(),
                handle: handle.handle
            }
        } catch (error) {
            console.log("could not find creator on-chain")
            // set global
            global = {
                wallet: pp.provider.wallet.publicKey.toString()
            }
        }
    } else {
        global = "no-wallet-yet"
    }
    return global
}
