module Model.AlmostExistingCollection exposing (AlmostExistingCollection, encode)

import Json.Encode as Encode
import Model.Handle exposing (Handle)


type alias AlmostExistingCollection =
    { handle : Handle
    , index : Int
    }


encode : AlmostExistingCollection -> String
encode almostCollection =
    let
        encoder =
            Encode.object
                [ ( "handle", Encode.string almostCollection.handle )
                , ( "index", Encode.int almostCollection.index )
                ]
    in
    Encode.encode 0 encoder
