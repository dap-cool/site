module View.Generic.Collection.Collector.Collector exposing (view, viewMany)

import FormatNumber
import FormatNumber.Locales exposing (usLocale)
import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model.Collection exposing (Collection)
import Msg.Collector.Collector as CollectorMsg
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Collection


view : Collection -> Html Msg
view collection =
    View.Generic.Collection.Collection.view collection


viewMany : List Collection -> Html Msg
viewMany collections =
    View.Generic.Collection.Collection.viewMany collections select


select : Collection -> Html Msg
select collection =
    Html.div
        []
        [ Html.button
            [ class "is-button-1"
            , onClick <|
                FromCollector <|
                    CollectorMsg.SelectCollection
                        collection.meta.handle
                        collection.meta.index
            ]
            [ Html.span
                [ class "icon-text"
                ]
                [ Html.span
                    [ class "icon"
                    ]
                    [ Html.i
                        [ class "fas fa-coins"
                        ]
                        []
                    ]
                , Html.span
                    []
                    [ Html.text <|
                        String.concat
                            [ FormatNumber.format usLocale (Basics.toFloat collection.math.price / 1000000)
                            , " "
                            , "USDC"
                            ]
                    ]
                ]
            ]
        ]
