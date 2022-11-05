module Msg.Js exposing (FromJs(..))


type FromJs
    = Success Json
    | Error String


type alias Json =
    String
