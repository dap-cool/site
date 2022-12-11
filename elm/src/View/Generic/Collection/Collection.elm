module View.Generic.Collection.Collection exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class, src, style)
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
        [ class "columns is-multiline"
        ]
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
                        [ class "is-light-text-container-5 is-size-5 has-text-centered"
                        ]
                        [ Html.text "Sold Out 😮\u{200D}💨"
                        ]

                False ->
                    Html.div
                        []
                        [ Html.div
                            [ class "is-light-text-container-5 is-size-5 has-text-centered"
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
        [ class "column is-collection is-one-third is-half-mobile"
        ]
        [ Html.div
            [ class "is-image-container-1"
            ]
            [ Html.img
                [ style "width" "100%"
                , src "images/upload/default-pfp.jpg"
                ]
                []
            ]
        , Html.div
            [ class "my-3 is-text-container-3 is-size-3 is-text-container-5-mobile is-size-5-mobile has-text-centered"
            ]
            [ Html.text collection.meta.name
            ]
        , supply
        , Html.div
            [ class "mt-4"
            ]
            [ select
            ]
        ]
