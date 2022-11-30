module Model.State.Exception.Exception exposing (Exception(..))


type Exception
    = Open String
    | Waiting
    | Closed
