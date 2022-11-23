module View.Generic.Collection.Creator.Creator exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Model.Collection exposing (Collection)
import Model.State.Global.HasWalletAndHandle exposing (HasWalletAndHandle)
import Msg.Creator.Creator exposing (FromCreator(..))
import Msg.Creator.Existing.Existing exposing (Existing(..))
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Collection


view : Collection -> Html Msg
view collection =
    View.Generic.Collection.Collection.view collection


viewMany : HasWalletAndHandle -> List Collection -> Html Msg
viewMany fromGlobal collections =
    View.Generic.Collection.Collection.viewMany collections <| select fromGlobal


select : HasWalletAndHandle -> Collection -> Html Msg
select fromGlobal collection =
    Html.div
        []
        [ Html.button
            [ class "is-button-1"
            , style "width" "100%"
            , onClick <| FromCreator <| Existing fromGlobal <| SelectCollection collection
            ]
            [ Html.text "Select"
            ]
        ]
