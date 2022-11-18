module Model.Creator.Existing.NewCollection exposing (Form, NewCollection(..), default, encode)

import Json.Encode as Encode
import Model.Collection exposing (Collection)


type NewCollection
    = Input Form Bool
    | HasCreateNft Collection
    | WaitingForMarkNft Collection
    | Done Collection


type alias Form =
    { name : String
    , symbol : String
    }


default : Form
default =
    { name = ""
    , symbol = ""
    }


encode : Form -> String
encode form =
    let
        encoder =
            Encode.object
                [ ( "name", Encode.string form.name )
                , ( "symbol", Encode.string form.symbol )
                ]
    in
    Encode.encode 0 encoder
