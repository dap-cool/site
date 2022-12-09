module View.Generic.Collection.Collection exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Model.Collection as Collection exposing (Collection)
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
        supply =
            case Collection.isSoldOut collection of
                True ->
                    Html.div
                        []
                        [ Html.text "Sold Out 😮\u{200D}💨"
                        ]

                False ->
                    Html.div
                        []
                        [ Html.div
                            [ class "has-border-2 px-2 py-2 mb-2"
                            ]
                            [ Html.text <|
                                String.concat
                                    [ String.fromInt (collection.meta.totalSupply - collection.meta.numMinted)
                                    , " "
                                    , "still available out of"
                                    , " "
                                    , String.fromInt collection.meta.totalSupply
                                    ]
                            ]
                        ]
    in
    Html.div
        [ class "has-border-2 px-2 py-2"
        ]
        [ select
        , supply
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
        ]
