module Model.Collection exposing (Collection, decode, decodeList, decoder, encode, isEmpty)

import Json.Decode as Decode
import Json.Encode as Encode
import Model.Mint exposing (Mint)
import Util.Decode as Util


type alias Collection =
    { name : String
    , symbol : String
    , index : Int
    , mint : Mint
    , collection : Maybe Mint
    }


encode : Collection -> String
encode collection =
    Encode.encode 0 <|
        Encode.object
            [ ( "index", Encode.int collection.index )
            ]


decode : String -> Result String Collection
decode string =
    Util.decode string decoder identity


decodeList : String -> Result String (List Collection)
decodeList string =
    Util.decode string (Decode.list decoder) identity


decoder : Decode.Decoder Collection
decoder =
    Decode.map5 Collection
        (Decode.field "name" Decode.string)
        (Decode.field "symbol" Decode.string)
        (Decode.field "index" Decode.int)
        (Decode.field "mint" Decode.string)
        (Decode.maybe <| Decode.field "collection" Decode.string)


isEmpty : Collection -> Bool
isEmpty collection =
    case collection.collection of
        Just id ->
            id == empty

        Nothing ->
            True



empty : String
empty =
    "11111111111111111111111111111111"
