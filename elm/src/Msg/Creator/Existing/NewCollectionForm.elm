module Msg.Creator.Existing.NewCollectionForm exposing (NewCollectionForm(..))

import Model.Creator.Existing.NewCollection as NewCollection exposing (NewCollection)


type NewCollectionForm
    = Image
    | Name String NewCollection.Form
    | Symbol String NewCollection.Form
