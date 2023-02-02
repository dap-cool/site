module Model.Creator.Existing.BioForm exposing (BioForm(..), encode)

import Json.Encode as Encode


type BioForm
    = Empty
    | Valid String
    | Invalid String


encode : ValidBio -> Json
encode valid =
    Encode.encode 0 <|
        Encode.object
            [ ( "bio", Encode.string valid )
            ]


type alias ValidBio =
    String


type alias Json =
    String
