module Model.Model exposing (Model, init)

import Browser.Navigation as Nav
import Model.AlmostExistingCollection as AlmostExistingCollection
import Model.Collector.Collector as Collector
import Model.Handle as Handle
import Model.State.Exception.Exception as Exception
import Model.State.Global.Global as Global
import Model.State.Local.Local as Local exposing (Local)
import Model.State.State exposing (State)
import Msg.Collector.Collector as FromCollector
import Msg.Msg exposing (Msg(..))
import Sub.Sender.Ports exposing (sender)
import Sub.Sender.Sender as Sender
import Url


type alias Model =
    { state : State
    , url : Url.Url
    , key : Nav.Key
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        local : Local
        local =
            Local.parse url

        model : Model
        model =
            { state =
                { local = local
                , global = Global.default
                , exception = Exception.Closed
                }
            , url = url
            , key = key
            }
    in
    case local of
        Local.Collect (Collector.MaybeExistingCreator handle) ->
            ( model
            , sender <|
                Sender.encode <|
                    { sender = Sender.Collect <| FromCollector.HandleForm <| Handle.Confirm handle
                    , more = Handle.encode handle
                    }
            )

        Local.Collect (Collector.MaybeExistingCollection handle index) ->
            ( model
            , sender <|
                Sender.encode <|
                    { sender = Sender.Collect <| FromCollector.SelectCollection handle index
                    , more = AlmostExistingCollection.encode { handle = handle, index = index }
                    }
            )

        _ ->
            ( model
            , Cmd.none
            )
