module Model.State.Global.HasWallet exposing (HasWallet, decode, decoder)

import Json.Decode as Decode
import Model.Collection as Collection exposing (Collection)
import Model.Wallet exposing (Wallet)
import Util.Decode as Util


type alias HasWallet =
    { wallet : Wallet
    , collected : List Collection
    }


decode : String -> Result String HasWallet
decode string =
    Util.decode string decoder identity


decoder : Decode.Decoder HasWallet
decoder =
    Decode.map2 HasWallet
        (Decode.field "wallet" Decode.string)
        (Decode.field "collected" <| Decode.list Collection.decoder)
