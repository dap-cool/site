module Model.Creator.Creator exposing (Creator(..))

import Model.Creator.Existing.Existing exposing (Existing)
import Model.Creator.New.New exposing (New)
import Model.State.Global.HasWalletAndHandle exposing (HasWalletAndHandle)


type Creator
    = Top
    | New New
    | Existing HasWalletAndHandle Existing
