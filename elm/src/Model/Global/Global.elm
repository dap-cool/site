module Model.Global.Global exposing (Global(..), default)

import Model.Global.HasWallet exposing (HasWallet)
import Model.Handle as Handle exposing (Handle)


type Global
    = NoWalletYet
    | WalletMissing -- no browser extension found
    | Connecting -- or disconnecting
    | HasWallet HasWallet
    | HasWalletAndHandle Handle.WithWallet


default : Global
default =
    NoWalletYet
