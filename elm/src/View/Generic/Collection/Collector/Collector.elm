module View.Generic.Collection.Collector.Collector exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Model.Collection exposing (Collection)
import Model.Collector.Collector as Collector
import Model.Handle exposing (Handle)
import Model.State as State exposing (State(..))
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Collection


view : Handle -> Collection -> Html Msg
view handle collection =
    View.Generic.Collection.Collection.view handle collection


viewMany : Handle -> List Collection -> Html Msg
viewMany handle collections =
    View.Generic.Collection.Collection.viewMany handle collections select


select : Handle -> Collection -> Html Msg
select handle collection =
    Html.div
        []
        [ Html.a
            [ class "is-button-1"
            , State.href <| Collect <| Collector.MaybeExistingCollection handle collection.index
            ]
            [ Html.text "Select this"
            ]
        ]
