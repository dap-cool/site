module Model.AlmostNewCollection exposing (AlmostNewCollection, encode)

import Json.Encode as Encode


type alias AlmostNewCollection =
    { name : String
    , symbol : String
    }


encode : AlmostNewCollection -> String
encode almostCollection =
    let
        encoder =
            Encode.object
                [ ( "name", Encode.string almostCollection.name )
                , ( "symbol", Encode.string almostCollection.symbol )
                ]
    in
    Encode.encode 0 encoder
