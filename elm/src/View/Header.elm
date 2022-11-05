module View.Header exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Msg.Msg exposing (Msg(..))


view : Html Msg
view =
    Html.nav
        [ class "is-navbar level is-mobile is-size-4"
        ]
        [ Html.div
            [ class "level-left ml-5 my-3"
            ]
            [ Html.div
                [ class "level-item"
                ]
                [ Html.h1
                    [ class "is-text-container-4"
                    ]
                    [ Html.text "DAP.COOL"
                    , Html.text "🆒"
                    ]
                ]
            ]
        , Html.div
            [ class "level-right mr-5 my-3"
            ]
            [ Html.div
                [ class "level-item"
                ]
                [ Html.span
                    [ class "icon-text"
                    ]
                    [ Html.span
                        [ class "is-light-text-container-4 mr-2"
                        ]
                        [ Html.text "Connect Wallet"
                        ]
                    , Html.span
                        [ class "icon"
                        ]
                        [ Html.i
                            [ class "fas fa-user"
                            ]
                            []
                        ]
                    ]
                ]
            ]
        ]
