port module Main exposing (main)

import Browser
import Html exposing (Html)
import Html.Events exposing (onClick)


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( { state = Home }, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { state : State
    }


type State
    = Home


type Msg
    = Init


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init ->
            ( model, init () )


port init : () -> Cmd msg


view : Model -> Html Msg
view _ =
    Html.div
        []
        [ Html.button
            [ onClick Init
            ]
            [ Html.text "init"
            ]
        ]
