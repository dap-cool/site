module Model.Collection exposing (Collection, decode, decodeList, decoder)

import Json.Decode as Decode
import Util.Decode as Util


type alias Collection =
    { name : String
    , symbol : String
    , index : Int
    }


decode : String -> Result String Collection
decode string =
    Util.decode string decoder identity


decodeList : String -> Result String (List Collection)
decodeList string =
    Util.decode string (Decode.list decoder) identity


decoder : Decode.Decoder Collection
decoder =
    Decode.map3 Collection
        (Decode.field "name" Decode.string)
        (Decode.field "symbol" Decode.string)
        (Decode.field "index" Decode.int)
