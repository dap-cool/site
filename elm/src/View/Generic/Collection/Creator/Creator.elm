module View.Generic.Collection.Creator.Creator exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Model.Collection exposing (Collection)
import Model.Global.Global exposing (Global)
import Msg.Creator.Creator exposing (FromCreator(..))
import Msg.Creator.Existing.Existing exposing (Existing(..))
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Collection



-- TODO: 11111111111111111111111111111111
--  if .collection is undefined expose method to create collection


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
        [ Html.button
            [ class "is-button-1"
            , style "width" "100%"
            , onClick <| FromCreator global <| Existing <| SelectCollection collection -- TODO; href ??
            ]
            [ Html.text "Select"
            ]
        ]
