module Model.CreatorMetadata exposing (CreatorMetadata(..), Metadata, decoder)

import Json.Decode as Decode


type CreatorMetadata
    = Initialized Metadata
    | UnInitialized


type alias Metadata =
    { bio : Maybe String
    , logo : Maybe Url
    , banner : Maybe Url
    }


type alias Url =
    String


decoder : Decode.Decoder CreatorMetadata
decoder =
    Decode.oneOf
        [ Decode.map (\m -> Initialized m) decoder_
        , Decode.succeed UnInitialized
        ]


decoder_ : Decode.Decoder Metadata
decoder_ =
    Decode.map3 Metadata
        (Decode.nullable (Decode.field "bio" Decode.string))
        (Decode.nullable (Decode.field "logo" Decode.string))
        (Decode.nullable (Decode.field "banner" Decode.string))
