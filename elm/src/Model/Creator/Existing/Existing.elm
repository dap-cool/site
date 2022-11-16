module Model.Creator.Existing.Existing exposing (Existing(..))

import Model.Collection exposing (Collection)
import Model.Creator.Existing.HandleFormStatus exposing (HandleFormStatus)
import Model.Creator.Existing.NewCollection exposing (NewCollection)


type Existing
    = Top (List Collection)
    | CreatingNewCollection NewCollection -- todo; separate create-collection & mark-collection; catch state & send to selected-collection view
    | SelectedCollection Collection
      -- authorizing from url
    | AuthorizingFromUrl HandleFormStatus
