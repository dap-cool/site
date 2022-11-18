module Model.Collection exposing (Collection, decode, decodeList, decoder, encode, encoder, isEmpty)

import Json.Decode as Decode
import Json.Encode as Encode
import Model.Mint exposing (Mint)
import Util.Decode as Util


type alias Collection =
    { handle : String
    , index : Int
    , name : String
    , symbol : String
    , mint : Mint
    , collection : Maybe Mint
    , numMinted : Int -- encoded as big-int
    , pda : String
    }


encode : Collection -> String
encode collection =
    Encode.encode 0 <|
        encoder collection


encoder : Collection -> Encode.Value
encoder collection =
    let
        collectionEncoder =
            case collection.collection of
                Just mint ->
                    Encode.string mint

                Nothing ->
                    Encode.null
    in
    Encode.object
        [ ( "name", Encode.string collection.name )
        , ( "symbol", Encode.string collection.symbol )
        , ( "index", Encode.int collection.index )
        , ( "mint", Encode.string collection.mint )
        , ( "collection", collectionEncoder )
        , ( "numMinted", Encode.int collection.numMinted )
        , ( "pda", Encode.string collection.pda )
        ]


decode : String -> Result String Collection
decode string =
    Util.decode string decoder identity


decodeList : String -> Result String (List Collection)
decodeList string =
    Util.decode string (Decode.list decoder) identity


decoder : Decode.Decoder Collection
decoder =
    Decode.map8 Collection
        (Decode.field "handle" Decode.string)
        (Decode.field "index" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "symbol" Decode.string)
        (Decode.field "mint" Decode.string)
        (Decode.maybe <| Decode.field "collection" Decode.string)
        (Decode.field "numMinted" Decode.int)
        (Decode.field "pda" Decode.string)


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
