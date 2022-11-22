module Model.Creator.Existing.Existing exposing (Existing(..))

import Model.Collection exposing (Collection)
import Model.Creator.Existing.NewCollection exposing (NewCollection)


type Existing
    = Top
    | CreatingNewCollection NewCollection
    | SelectedCollection Collection
