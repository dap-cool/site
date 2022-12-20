module View.Generic.Datum.Datum exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (controls, src)
import Model.Datum as Datum exposing (File, Src(..))
import Msg.Msg exposing (Msg)


view : File -> Html Msg
view file =
    case Datum.toSrc file of
        Img dataUri ->
            Html.img
                [ src dataUri
                ]
                []

        Audio dataUri ->
            Html.audio
                [ controls True
                ]
                [ Html.source
                    [ src dataUri
                    ]
                    []
                ]

        Video dataUri ->
            Html.video
                [ controls True
                ]
                [ Html.source
                    [ src dataUri
                    ]
                    []
                ]

        NotSupported ->
            Html.div
                []
                [ Html.div
                    []
                    [ Html.text <|
                        String.concat
                            [ file.type_
                            , "file type not supported for rendering in the browser"
                            ]
                    ]
                , Html.div
                    []
                    [ Html.text
                        """but you can download these files at any time
                        """
                    ]
                ]
