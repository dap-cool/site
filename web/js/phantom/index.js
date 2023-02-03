/*! https://docs.phantom.app/ */
import * as FeaturedCreators from "./../shdw/creator/featured-creators";
import {getEphemeralPP} from "../anchor/util/context";

export async function getPhantom(app) {
    let phantom;
    const provider = getPhantomProvider();
    if (provider) {
        try {
            // connect
            const connection = await window.phantom.solana.connect();
            console.log("phantom wallet connected");
            // return state to js
            phantom = {windowSolana: window.phantom.solana, connection: connection}
        } catch (error) {
            console.log(error.message);
            app.ports.exception.send(
                JSON.stringify(
                    {
                        message: error.message
                    }
                )
            );
        }
    } else {
        // get featured creators
        const pp = getEphemeralPP();
        const featuredCreators = await FeaturedCreators.fetch(
            pp.programs.dap
        );
        // send global to elm
        app.ports.success.send(
            JSON.stringify(
                {
                    listener: "global-found-missing-wallet-plugin",
                    featuredCreators
                }
            )
        );
    }
    return phantom
}

export function getPhantomProvider() {
    let provider;
    try {
        const maybeProvider = window.phantom.solana;
        if (maybeProvider && maybeProvider.isPhantom) {
            provider = maybeProvider
        }
    } catch (error) {
    }
    return provider
}
