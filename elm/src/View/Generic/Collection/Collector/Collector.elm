module View.Generic.Collection.Collector.Collector exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Model.Collection exposing (Collection)
import Model.Collector.Collector as Collector
import Model.State.Local.Local as Local
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
        [ Html.a
            [ class "is-button-1"
            , Local.href <|
                Local.Collect <|
                    Collector.MaybeExistingCollection
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
                        [ class "fas fa-home"
                        ]
                        []
                    ]
                , Html.span
                    []
                    [ Html.text <|
                        String.concat
                            [ "15.00"
                            , " "
                            , "USDC"
                            ]
                    ]
                ]
            ]
        ]
