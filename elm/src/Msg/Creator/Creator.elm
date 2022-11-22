module Msg.Creator.Creator exposing (FromCreator(..), toString)

import Model.State.Global.HasWalletAndHandle exposing (HasWalletAndHandle)
import Msg.Creator.Existing.Existing as Existing exposing (Existing)
import Msg.Creator.New.New as New exposing (New)


type FromCreator
    = New New
    | Existing HasWalletAndHandle Existing


toString : FromCreator -> String
toString fromCreator =
    case fromCreator of
        New new ->
            New.toString new

        Existing _ existing ->
            Existing.toString existing
