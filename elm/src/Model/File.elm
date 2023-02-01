module Model.File exposing (File, Files, decoder, encoder, manyDecoder, manyEncoder)

import Json.Decode as Decode
import Json.Encode as Encode


type alias Files =
    { count : Int
    , files : List File
    }


type alias File =
    { name : String
    , dataUrl : String
    }


manyEncoder : List File -> Encode.Value
manyEncoder list =
    Encode.list
        encoder
        list


encoder : File -> Encode.Value
encoder file =
    Encode.object
        [ ( "name", Encode.string file.name )
        , ( "dataUrl", Encode.string file.dataUrl )
        ]


manyDecoder : Decode.Decoder Files
manyDecoder =
    Decode.map2 Files
        (Decode.field "count" Decode.int)
        (Decode.field "files" <|
            Decode.list decoder
        )


decoder : Decode.Decoder File
decoder =
    Decode.map2 File
        (Decode.field "name" Decode.string)
        (Decode.field "dataUrl" Decode.string)
