module Model.Creator.Creator exposing (Creator(..))

import Model.Creator.Existing.Existing exposing (Existing)
import Model.Creator.New.New exposing (New)


type Creator
    = Top
    | New New
    | Existing Existing
    | MaybeExisting String
