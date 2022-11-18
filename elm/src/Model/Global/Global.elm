module Model.Global.Global exposing (Global(..), decode, default, encoder)

import Json.Decode as Decode
import Json.Encode as Encode
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


encoder : Global -> Encode.Value
encoder global =
    case global of
        NoWalletYet ->
            Encode.string "no-wallet-yet"

        WalletMissing ->
            Encode.string "wallet-missing"

        Connecting ->
            Encode.string "connecting"

        HasWallet hasWallet ->
            HasWallet.encoder hasWallet

        HasWalletAndHandle withWallet ->
            Handle.withWalletEncoder withWallet
