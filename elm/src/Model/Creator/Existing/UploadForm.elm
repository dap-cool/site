module Model.Creator.Existing.UploadForm exposing (UploadForm, encode)

import Json.Encode as Encode
import Model.Collection as Collection exposing (Collection)


type alias UploadForm =
    { title : String
    }


encode : Collection -> UploadForm -> String
encode collection form =
    Encode.encode 0 <|
        Encode.object
            [ ( "collection", Collection.encoder collection )
            , ( "form"
              , Encode.object
                    [ ( "title", Encode.string form.title )
                    ]
              )
            ]
