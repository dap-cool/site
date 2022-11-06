module View.Hero exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Model.Global exposing (Global)
import Msg.Msg exposing (Msg)
import View.Footer
import View.Header


view : Global -> Html Msg -> Html Msg
view _ body =
    Html.section
        [ class "hero is-fullheight has-black is-family-primary"
        ]
        [ Html.div
            [ class "hero-head"
            ]
            [ View.Header.view
            ]
        , Html.div
            [ class "hero-body"
            ]
            [ body
            ]
        , Html.div
            [ class "hero-foot"
            ]
            [ View.Footer.view
            ]
        ]
