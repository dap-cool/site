module Model.Collector.WithCollections exposing (WithCollections, decode)

import Json.Decode as Decode
import Model.Collection as Collection exposing (Collection)
import Model.Handle exposing (Handle)
import Util.Decode as Util


type alias WithCollections =
    { handle : Handle
    , collections : List Collection
    }


decode : String -> Result String WithCollections
decode string =
    let
        decoder : Decode.Decoder WithCollections
        decoder =
            Decode.map2 WithCollections
                (Decode.field "handle" Decode.string)
                (Decode.field "collections" <| Decode.list Collection.decoder)
    in
    Util.decode string decoder identity
