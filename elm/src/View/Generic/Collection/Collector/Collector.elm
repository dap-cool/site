module View.Generic.Collection.Collector.Collector exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Model.Collection exposing (Collection)
import Model.Collector.Collector as Collector
import Model.Global exposing (Global)
import Model.Handle exposing (Handle)
import Model.State as State exposing (State(..))
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Collection



-- TODO: 11111111111111111111111111111111
--  if .collection is undefined expose method to add to collection
--  add .belongs-to field in pda


view : Global -> Handle -> Collection -> Html Msg
view global handle collection =
    View.Generic.Collection.Collection.view global handle collection


viewMany : Global -> Handle -> List Collection -> Html Msg
viewMany global handle collections =
    View.Generic.Collection.Collection.viewMany global handle collections select


select : Global -> Handle -> Collection -> Html Msg
select global handle collection =
    Html.div
        []
        [ Html.a
            [ class "is-button-1"
            , State.href <| Valid global <| State.Collect <| Collector.MaybeExistingCollection handle collection.index
            ]
            [ Html.text "Select this"
            ]
        ]
