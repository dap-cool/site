module View.Generic.Collection.Collection exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Model.Collection exposing (Collection)
import Model.Global.Global exposing (Global)
import Model.Handle exposing (Handle)
import Msg.Msg exposing (Msg(..))


view : Global -> Handle -> Collection -> Html Msg
view global handle collection =
    let
        nop : Global -> a -> b -> Html msg
        nop _ _ _ =
            Html.div
                []
                []
    in
    view_ global handle collection nop


viewMany : Global -> Handle -> List Collection -> (Global -> Handle -> Collection -> Html Msg) -> Html Msg
viewMany global handle collections f =
    Html.div
        []
    <|
        List.map
            (\c -> view_ global handle c f)
            collections


view_ : Global -> Handle -> Collection -> (Global -> Handle -> Collection -> Html Msg) -> Html Msg
view_ global handle collection select =
    Html.div
        [ class "has-border-2 px-2 py-2"
        ]
        [ select global handle collection
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
