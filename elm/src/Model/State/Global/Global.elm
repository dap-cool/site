module Model.State.Global.Global exposing (Global(..), default)

import Model.State.Global.HasWallet exposing (HasWallet)
import Model.State.Global.HasWalletAndHandle exposing (HasWalletAndHandle)


type Global
    = NoWalletYet
    | WalletMissing -- no browser extension found
    | HasWallet HasWallet
    | HasWalletAndHandle HasWalletAndHandle


default : Global
default =
    NoWalletYet
