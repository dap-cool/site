module View.Generic.Collection.Creator.Creator exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Model.Collection exposing (Collection)
import Msg.Creator.Creator exposing (FromCreator(..))
import Msg.Creator.Existing.Existing exposing (Existing(..))
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Collection



-- TODO: 11111111111111111111111111111111
--  if .collection is undefined expose method to create collection


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
            , style "width" "100%"
            , onClick <| FromCreator <| Existing <| SelectCollection collection
            ]
            [ Html.text "Select"
            ]
        ]
