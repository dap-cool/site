module Model.Creator.Existing.NewCollection exposing (NewCollection, default)


type alias NewCollection =
    { name : String
    , symbol : String
    }


default : NewCollection
default =
    { name = ""
    , symbol = ""
    }
