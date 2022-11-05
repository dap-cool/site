module View.Generic.Collection.Creator.Creator exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Model.Collection exposing (Collection)
import Model.Handle exposing (Handle)
import Model.Wallet exposing (Wallet)
import Msg.Creator.Creator exposing (FromCreator(..))
import Msg.Creator.Existing.Existing exposing (Existing(..))
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Collection


view : Handle -> Collection -> Html Msg
view handle collection =
    View.Generic.Collection.Collection.view handle collection


viewMany : Wallet -> Handle -> List Collection -> Html Msg
viewMany wallet handle collections =
    let
        f : Handle -> Collection -> Html Msg
        f =
            select wallet
    in
    View.Generic.Collection.Collection.viewMany handle collections f


select : Wallet -> Handle -> Collection -> Html Msg
select wallet handle collection =
    Html.div
        []
        [ Html.button
            -- TODO; href
            [ class "is-button-1"
            , style "width" "100%"
            , onClick <| FromCreator <| Existing <| SelectCollection wallet handle collection
            ]
            [ Html.text "Select"
            ]
        ]
