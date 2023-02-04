module View.Generic.Collection.Collection exposing (view, viewMany)

import FormatNumber
import FormatNumber.Locales exposing (usLocale)
import Html exposing (Html)
import Html.Attributes exposing (class, id, src, style)
import Model.Collection as Collection exposing (Collection)
import Msg.Msg exposing (Msg(..))


view : Collection -> Html Msg
view collection =
    let
        body : Html msg
        body =
            Html.div
                []
                [ Html.div
                    [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile has-text-centered"
                    ]
                    [ Html.text <|
                        String.concat
                            [ "$USDC"
                            , " "
                            , FormatNumber.format usLocale (Basics.toFloat collection.math.price / 1000000)
                            ]
                    ]
                ]
    in
    view_ collection body


viewMany : List Collection -> (Collection -> Html Msg) -> Html Msg
viewMany collections f =
    Html.div
        [ class "columns is-multiline is-mobile"
        ]
    <|
        List.map
            (\c ->
                Html.div
                    [ class "column is-half"
                    ]
                    [ view_ c <| f c
                    ]
            )
            collections


view_ : Collection -> Html Msg -> Html Msg
view_ collection select =
    let
        supply =
            case Collection.isSoldOut collection of
                True ->
                    Html.div
                        [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile has-text-centered"
                        ]
                        [ Html.text "Sold Out 😮\u{200D}💨"
                        ]

                False ->
                    Html.div
                        []
                        [ Html.div
                            [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile has-text-centered"
                            ]
                            [ Html.text <|
                                String.concat
                                    [ String.fromInt (collection.math.totalSupply - collection.math.numMinted)
                                    , " "
                                    , "still available out of"
                                    , " "
                                    , String.fromInt collection.math.totalSupply
                                    ]
                            ]
                        ]
    in
    Html.div
        [ class "is-collection px-1 py-1"
        ]
        [ Html.div
            [ class "is-image-container-1"
            ]
            [ Html.img
                [ style "width" "100%"
                , src collection.meta.image
                ]
                []
            ]
        , Html.div
            [ class "my-3 mt-1-mobile is-text-container-4 is-size-4 is-text-container-5-mobile is-size-5-mobile has-text-centered"
            ]
            [ Html.text collection.meta.name
            ]
        , Html.div
            [ class "my-1-mobile"
            ]
            [ supply
            ]
        , Html.div
            [ class "mt-4 my-1-mobile"
            ]
            [ select
            ]
        ]
