module Model.Creator.Existing.NewCollection exposing (Form, NewCollection(..), default)

import Model.AlmostNewCollection exposing (AlmostNewCollection)
import Model.Collection exposing (Collection)


type NewCollection
    = Input Form
    | WaitingForCreateNft AlmostNewCollection
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
