module Model.WithCollection exposing (WithCollection, decode)

import Json.Decode as Decode
import Model.Collection as Collection exposing (Collection)
import Model.Handle exposing (Handle)
import Model.Wallet exposing (Wallet)
import Util.Decode as Util


type alias WithCollection =
    { wallet : Maybe Wallet
    , handle : Handle
    , collection : Collection
    }


decode : String -> Result String WithCollection
decode string =
    Util.decode string decoder (\a -> a)


decoder : Decode.Decoder WithCollection
decoder =
    Decode.map3 WithCollection
        (Decode.maybe <| Decode.field "wallet" Decode.string)
        (Decode.field "handle" Decode.string)
        (Decode.field "collection" Collection.decoder)
