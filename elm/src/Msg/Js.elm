module Msg.Js exposing (FromJs(..))


type FromJs
    = Success Json
    | Error String
    | Exception String


type alias Json =
    String
