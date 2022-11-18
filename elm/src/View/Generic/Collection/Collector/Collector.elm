module View.Generic.Collection.Collector.Collector exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Model.Collection exposing (Collection)
import Model.Collector.Collector as Collector
import Model.Global.Global exposing (Global)
import Model.State as State exposing (State(..))
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Collection



-- TODO: 11111111111111111111111111111111
--  if .collection is undefined expose method to add to collection
--  add .belongs-to field in pda


view : Global -> Collection -> Html Msg
view global collection =
    View.Generic.Collection.Collection.view global collection


viewMany : Global -> List Collection -> Html Msg
viewMany global collections =
    View.Generic.Collection.Collection.viewMany global collections select


select : Global -> Collection -> Html Msg
select global collection =
    Html.div
        []
        [ Html.a
            [ class "is-button-1"
            , State.href <|
                Valid global <|
                    State.Collect <|
                        Collector.MaybeExistingCollection
                            collection.handle
                            collection.index
            ]
            [ Html.text "Select this"
            ]
        ]
