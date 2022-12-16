module View.Hero exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model.State.Exception.Exception as Exception exposing (Exception)
import Model.State.Global.Global exposing (Global)
import Msg.Msg exposing (Msg(..))
import View.Footer
import View.Header


view : Exception -> Global -> Html Msg -> Html Msg
view exception global body =
    let
        modal html =
            Html.div
                [ class "modal is-active"
                ]
                [ Html.div
                    [ class "modal-background"
                    ]
                    []
                , Html.div
                    [ class "modal-content"
                    ]
                    [ html
                    ]
                , Html.button
                    [ class "modal-close is-large"
                    , onClick CloseExceptionModal
                    ]
                    []
                ]

        exceptionModal =
            case exception of
                Exception.Open string ->
                    modal <|
                        Html.text string

                Exception.Waiting ->
                    modal <|
                        Html.div
                            [ class "is-loading"
                            ]
                            []

                Exception.Closed ->
                    Html.div
                        []
                        []
    in
    Html.section
        [ class "hero is-fullheight has-black is-family-primary"
        ]
        [ Html.div
            [ class "hero-head"
            ]
            [ View.Header.view global
            ]
        , Html.div
            [ class "container mx-6 my-6"
            ]
            [ body
            , exceptionModal
            ]
        , Html.div
            [ class "hero-foot"
            ]
            [ View.Footer.view
            ]
        ]
