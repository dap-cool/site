module Model.Handle exposing (Form(..), Handle, decode, encode, normalize)

import Json.Decode as Decode
import Json.Encode as Encode
import Util.Decode as Util


type alias Handle =
    String


type Form
    = Typing String
    | Confirm String


encode : Handle -> String
encode handle =
    let
        encoder =
            Encode.object
                [ ( "handle", Encode.string handle )
                ]
    in
    Encode.encode 0 encoder


decode : String -> Result String Handle
decode string =
    let
        decoder : Decode.Decoder Handle
        decoder =
            Decode.string
    in
    Util.decode string decoder identity


normalize : String -> String
normalize string =
    String.toLower <|
        String.trim <|
            String.replace " " "" <|
                string
