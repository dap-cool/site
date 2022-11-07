module Model.Creator.Existing.Existing exposing (Existing(..))

import Model.Collection exposing (Collection)
import Model.Creator.Existing.HandleFormStatus exposing (HandleFormStatus)
import Model.Creator.Existing.NewCollection exposing (NewCollection)


type Existing
    = Top (List Collection)
    | CreatingNewCollection NewCollection
    | SelectedCollection Collection
      -- authorizing from url
    | AuthorizingFromUrl HandleFormStatus
