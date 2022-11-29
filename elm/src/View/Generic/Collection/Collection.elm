module View.Generic.Collection.Collection exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Model.Collection exposing (Collection)
import Msg.Msg exposing (Msg(..))


view : Collection -> Html Msg
view collection =
    let
        nop : Html msg
        nop =
            Html.div
                []
                []
    in
    view_ collection nop


viewMany : List Collection -> (Collection -> Html Msg) -> Html Msg
viewMany collections f =
    Html.div
        []
    <|
        List.map
            (\c -> view_ c <| f c)
            collections


view_ : Collection -> Html Msg -> Html Msg
view_ collection select =
    let
        ataDiv =
            case collection.accounts.ata of
                Just ata ->
                    Html.div
                        [ class "has-border-2 px-2 py-2 mb-2"
                        ]
                        [ Html.text <| String.fromInt ata.balance
                        ]

                Nothing ->
                    Html.div
                        []
                        []
    in
    Html.div
        [ class "has-border-2 px-2 py-2"
        ]
        [ select
        , Html.div
            [ class "has-border-2 px-2 py-2 mb-2"
            ]
            [ Html.text collection.meta.name
            ]
        , Html.div
            [ class "has-border-2 px-2 py-2 mb-2"
            ]
            [ Html.text collection.meta.symbol
            ]
        , Html.div
            [ class "has-border-2 px-2 py-2 mb-2"
            ]
            [ Html.text <|
                String.concat
                    [ "mint:"
                    , " "
                    , collection.accounts.mint
                    ]
            ]
        , Html.div
            [ class "has-border-2 px-2 py-2 mb-2"
            ]
            [ Html.text <|
                String.concat
                    [ "pda:"
                    , " "
                    , collection.accounts.pda
                    ]
            ]
        , ataDiv
        ]
