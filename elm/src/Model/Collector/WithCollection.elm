module Model.Collector.WithCollection exposing (WithCollection, decode)

import Json.Decode as Decode
import Model.Collection as Collection exposing (Collection)
import Model.Handle exposing (Handle)
import Util.Decode as Util


type alias WithCollection =
    { handle : Handle
    , collection : Collection
    }


decode : String -> Result String WithCollection
decode string =
    Util.decode string decoder (\a -> a)


decoder : Decode.Decoder WithCollection
decoder =
    Decode.map2 WithCollection
        (Decode.field "handle" Decode.string)
        (Decode.field "collection" Collection.decoder)
