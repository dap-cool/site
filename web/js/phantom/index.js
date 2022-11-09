/*! https://docs.phantom.app/ */

export async function getPhantom(app) {
    let phantom;
    try {
        // connect
        const connection = await window.solana.connect();
        console.log("phantom wallet connected");
        // return state to js
        phantom = {windowSolana: window.solana, connection: connection}
    } catch (err) {
        console.log(err.message)
        // validate phantom install
        const isPhantomInstalled = window.solana && window.solana.isPhantom;
        if (!isPhantomInstalled) {
            // send global to elm
            app.ports.success.send(
                JSON.stringify(
                    {
                        global: "wallet-missing"
                    }
                )
            );
        } else {
            // send err to elm
            app.ports.error.send(err.message)
        }
    }
    return phantom
}
