module Model.Global exposing (Global(..), decode, default, encode)

import Json.Decode as Decode
import Json.Encode as Encode
import Model.Handle as Handle exposing (Handle)
import Model.Wallet as Wallet exposing (Wallet)
import Util.Decode as Util


type Global
    = NoWalletYet
    | WalletMissing -- no browser extension found
    | HasWallet Wallet
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
                (\wallet -> HasWallet wallet.wallet)
                Wallet.decoder
            , Decode.map
                (\withWallet -> HasWalletAndHandle withWallet)
                Handle.witWalletDecoder
            ]


encode : Global -> String
encode global =
    let
        more =
            case global of
                NoWalletYet ->
                    "no-wallet-yet"

                WalletMissing ->
                    "wallet-missing"

                HasWallet wallet ->
                    Wallet.encode wallet

                HasWalletAndHandle withWallet ->
                    Handle.encodeWithWallet withWallet
    in
    Encode.encode 0 <|
        Encode.object
            [ ( "global", Encode.string more )
            ]
