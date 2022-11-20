module Sub.Listener.Global.Global exposing (ToGlobal(..), fromString)


type ToGlobal
    = FoundMissingWalletPlugin -- no browser plugin installed
    | FoundWallet
    | FoundWalletAndHandle


fromString : String -> Maybe ToGlobal
fromString string =
    case string of
        "global-found-missing-wallet-plugin" ->
            Just FoundMissingWalletPlugin

        "global-found-wallet" ->
            Just FoundWallet

        "global-found-wallet-and-handle" ->
            Just FoundWalletAndHandle

        _ ->
            Nothing
