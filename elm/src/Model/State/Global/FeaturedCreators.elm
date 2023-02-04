module Model.State.Global.FeaturedCreators exposing (FeaturedCreator, FeaturedCreators, decode, decoder)

import Json.Decode as Decode
import Model.CreatorMetadata as CreatorMetadata exposing (CreatorMetadata, Metadata)
import Util.Decode as Util


type alias FeaturedCreators =
    List FeaturedCreator


type alias FeaturedCreator =
    { handle : String
    , metadata : Metadata
    }


decode : String -> Result String FeaturedCreators
decode string =
    Util.decode string decoder identity


decoder : Decode.Decoder FeaturedCreators
decoder =
    Decode.list decoder_


decoder_ : Decode.Decoder FeaturedCreator
decoder_ =
    Decode.map2 FeaturedCreator
        (Decode.field "handle" Decode.string)
        (Decode.field "metadata" CreatorMetadata.decoder_)
