module Model.Global.Global exposing (Global(..), decode, default)

import Json.Decode as Decode
import Model.Global.HasWallet as HasWallet exposing (HasWallet)
import Model.Handle as Handle exposing (Handle)
import Util.Decode as Util


type Global
    = NoWalletYet
    | WalletMissing -- no browser extension found
    | Connecting -- or disconnecting
    | HasWallet HasWallet
    | HasWalletAndHandle Handle.WithWallet


default : Global
default =
    NoWalletYet


decode : String -> Result String Global
decode string =
    Util.decode string decoder0 identity


decoder0 : Decode.Decoder Global
decoder0 =
    Decode.field "global" <|
        Decode.oneOf
            [ Decode.string
                |> Decode.andThen
                    (\string ->
                        case string of
                            "no-wallet-yet" ->
                                Decode.succeed NoWalletYet

                            "wallet-missing" ->
                                Decode.succeed WalletMissing

                            _ ->
                                Decode.fail "Must be wallet present"
                    )
            , Decode.map
                (\withWallet -> HasWalletAndHandle withWallet)
                Handle.witWalletDecoder
            , Decode.map
                (\hasWallet -> HasWallet hasWallet)
                HasWallet.decoder
            ]
