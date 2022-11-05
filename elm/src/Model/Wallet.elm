module Model.Wallet exposing (Wallet, decode, encode, slice)

import Json.Decode as Decode
import Json.Encode as Encode
import Util.Decode as Util


type alias Wallet =
    String


slice : Wallet -> String
slice publicKey =
    String.join
        "..."
        [ String.slice 0 4 publicKey
        , String.slice -5 -1 publicKey
        ]


encode : Wallet -> String
encode wallet =
    let
        encoder =
            Encode.object
                [ ( "wallet", Encode.string wallet )
                ]
    in
    Encode.encode 0 encoder


type alias WalletObject =
    { wallet : String }


decode : String -> Result String Wallet
decode string =
    let
        decoder : Decode.Decoder WalletObject
        decoder =
            Decode.map WalletObject
                (Decode.field "wallet" Decode.string)
    in
    Util.decode string decoder (\a -> a.wallet)
