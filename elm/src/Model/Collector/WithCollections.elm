module Model.Collector.WithCollections exposing (WithCollections, decode, decoder)

import Json.Decode as Decode
import Model.Collection as Collection exposing (Collection)
import Model.CreatorMetadata as CreatorMetadata exposing (CreatorMetadata)
import Model.Handle exposing (Handle)
import Util.Decode as Util


type alias WithCollections =
    { handle : Handle
    , collections : List Collection
    , metadata : CreatorMetadata
    }


decode : String -> Result String WithCollections
decode string =
    Util.decode string decoder identity


decoder : Decode.Decoder WithCollections
decoder =
    Decode.map3 WithCollections
        (Decode.field "handle" Decode.string)
        (Decode.field "collections" <| Decode.list Collection.decoder)
        CreatorMetadata.decoder
