module Model.CreatorMetadata exposing (CreatorMetadata(..), Metadata, decoder, metadataDecoder)

import Json.Decode as Decode
import Model.Mint exposing (Mint)


type CreatorMetadata
    = Initialized Metadata
    | UnInitialized ShadowAta


type alias Metadata =
    { bio : Maybe String
    , logo : Maybe Url
    , banner : Maybe Url
    , shadowAta : ShadowAta
    }


type alias Url =
    String


type alias ShadowAta =
    { balance : Int
    , address : Maybe Mint
    }


decoder : Decode.Decoder CreatorMetadata
decoder =
    Decode.oneOf
        [ Decode.field "metadata" <| Decode.map (\m -> Initialized m) metadataDecoder
        , Decode.field "metadata" <| Decode.map (\s -> UnInitialized s) shadowAtaDecoder
        , Decode.field "metadata" <| Decode.null (UnInitialized { balance = 0, address = Nothing })
        , Decode.succeed (UnInitialized { balance = 0, address = Nothing })
        ]


metadataDecoder : Decode.Decoder Metadata
metadataDecoder =
    Decode.map4 Metadata
        (Decode.maybe (Decode.field "bio" Decode.string))
        (Decode.maybe (Decode.field "logo" Decode.string))
        (Decode.maybe (Decode.field "banner" Decode.string))
        (Decode.field "shadowAta" shadowAtaDecoder)


shadowAtaDecoder : Decode.Decoder ShadowAta
shadowAtaDecoder =
    Decode.map2 ShadowAta
        (Decode.field "balance" Decode.int)
        (Decode.maybe (Decode.field "address" Decode.string))
