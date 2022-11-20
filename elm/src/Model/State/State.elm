module Model.State.State exposing (State)

import Model.State.Global.Global exposing (Global)
import Model.State.Local.Local exposing (Local)


type alias State =
    { local : Local
    , global : Global
    }
