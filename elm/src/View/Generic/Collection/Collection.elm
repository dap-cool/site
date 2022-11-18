module View.Generic.Collection.Collection exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Model.Collection exposing (Collection)
import Model.Global.Global exposing (Global)
import Msg.Msg exposing (Msg(..))


view : Global -> Collection -> Html Msg
view global collection =
    let
        nop : a -> b -> Html msg
        nop _ _ =
            Html.div
                []
                []
    in
    view_ global collection nop


viewMany : Global -> List Collection -> (Global -> Collection -> Html Msg) -> Html Msg
viewMany global collections f =
    Html.div
        []
    <|
        List.map
            (\c -> view_ global c f)
            collections


view_ : Global -> Collection -> (Global -> Collection -> Html Msg) -> Html Msg
view_ global collection select =
    Html.div
        [ class "has-border-2 px-2 py-2"
        ]
        [ select global collection
        , Html.div
            [ class "has-border-2 px-2 py-2 mb-2"
            ]
            [ Html.text collection.name
            ]
        , Html.div
            [ class "has-border-2 px-2 py-2 mb-2"
            ]
            [ Html.text collection.symbol
            ]
        , Html.div
            [ class "has-border-2 px-2 py-2 mb-2"
            ]
            [ Html.text <| String.fromInt collection.index
            ]
        ]
