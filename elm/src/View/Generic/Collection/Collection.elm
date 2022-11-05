module View.Generic.Collection.Collection exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Model.Collection exposing (Collection)
import Model.Handle exposing (Handle)
import Msg.Msg exposing (Msg(..))


view : Handle -> Collection -> Html Msg
view handle collection =
    let
        nop : a -> b -> Html msg
        nop _ _ =
            Html.div
                []
                []
    in
    view_ handle collection nop


viewMany : Handle -> List Collection -> (Handle -> Collection -> Html Msg) -> Html Msg
viewMany handle collections f =
    Html.div
        []
    <|
        List.map
            (\c -> view_ handle c f)
            collections


view_ : Handle -> Collection -> (Handle -> Collection -> Html Msg) -> Html Msg
view_ handle collection select =
    Html.div
        [ class "has-border-2 px-2 py-2"
        ]
        [ select handle collection
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
