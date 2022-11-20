module Model.State.Global.HasWallet exposing (HasWallet, decode, decoder, encoder)

import Json.Decode as Decode
import Json.Encode as Encode
import Model.Collection as Collection exposing (Collection)
import Model.Wallet exposing (Wallet)
import Util.Decode as Util


type alias HasWallet =
    { wallet : Wallet
    , collections : List Collection
    }


decode : String -> Result String HasWallet
decode string =
    Util.decode string decoder identity


decoder : Decode.Decoder HasWallet
decoder =
    Decode.map2 HasWallet
        (Decode.field "wallet" Decode.string)
        (Decode.field "collections" <| Decode.list Collection.decoder)


encoder : HasWallet -> Encode.Value
encoder hasWallet =
    Encode.object
        [ ( "wallet", Encode.string hasWallet.wallet )
        , ( "collections", Encode.list Collection.encoder hasWallet.collections )
        ]
