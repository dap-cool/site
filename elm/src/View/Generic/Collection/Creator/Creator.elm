module View.Generic.Collection.Creator.Creator exposing (view, viewMany)

import Html exposing (Html)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Model.Collection exposing (Collection)
import Model.Global exposing (Global)
import Model.Handle exposing (Handle)
import Model.Wallet exposing (Wallet)
import Msg.Creator.Creator exposing (FromCreator(..))
import Msg.Creator.Existing.Existing exposing (Existing(..))
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Collection


view : Global -> Handle -> Collection -> Html Msg
view global handle collection =
    View.Generic.Collection.Collection.view global handle collection


viewMany : Global -> Wallet -> Handle -> List Collection -> Html Msg
viewMany global wallet handle collections =
    let
        f : Global -> Handle -> Collection -> Html Msg
        f =
            select wallet
    in
    View.Generic.Collection.Collection.viewMany global handle collections f


select : Wallet -> Global -> Handle -> Collection -> Html Msg
select wallet global handle collection =
    Html.div
        []
        [ Html.button
            [ class "is-button-1"
            , style "width" "100%"
            , onClick <| FromCreator global <| Existing <| SelectCollection wallet handle collection
            ]
            [ Html.text "Select"
            ]
        ]
