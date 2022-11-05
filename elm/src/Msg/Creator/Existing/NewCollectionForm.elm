module Msg.Creator.Existing.NewCollectionForm exposing (NewCollectionForm(..))

import Model.Creator.Existing.NewCollection exposing (NewCollection)


type NewCollectionForm
    = Image
    | Name String NewCollection
    | Symbol String NewCollection
