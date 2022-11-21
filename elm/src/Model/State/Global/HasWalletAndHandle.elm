module Model.State.Global.HasWalletAndHandle exposing (HasWalletAndHandle, decode, decoder)

import Json.Decode as Decode
import Model.Collection as Collection exposing (Collection)
import Model.Handle exposing (Handle)
import Model.Wallet exposing (Wallet)
import Util.Decode as Util


type alias HasWalletAndHandle =
    { wallet : Wallet
    , handle : Handle
    , collections : List Collection
    , collected : List Collection
    }


decode : String -> Result String HasWalletAndHandle
decode string =
    Util.decode string decoder identity


decoder : Decode.Decoder HasWalletAndHandle
decoder =
    Decode.map4 HasWalletAndHandle
        (Decode.field "wallet" Decode.string)
        (Decode.field "handle" Decode.string)
        (Decode.field "collections" <| Decode.list Collection.decoder)
        (Decode.field "collected" <| Decode.list Collection.decoder)
