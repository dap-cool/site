module Model.AlmostNewCollection exposing (AlmostNewCollection, encode)

import Json.Encode as Encode
import Model.Handle exposing (Handle)


type alias AlmostNewCollection =
    { handle : Handle
    , name : String
    , symbol : String
    }


encode : AlmostNewCollection -> String
encode almostCollection =
    let
        encoder =
            Encode.object
                [ ( "handle", Encode.string almostCollection.handle )
                , ( "name", Encode.string almostCollection.name )
                , ( "symbol", Encode.string almostCollection.symbol )
                ]
    in
    Encode.encode 0 encoder
