module Msg.Creator.Creator exposing (FromCreator(..), toString)

import Msg.Creator.Existing.Existing as Existing exposing (Existing)
import Msg.Creator.New.New as New exposing (New)


type FromCreator
    = New New
    | Existing Existing


toString : FromCreator -> String
toString fromCreator =
    case fromCreator of
        New new ->
            New.toString new

        Existing existing ->
            Existing.toString existing
