module Msg.Creator.Existing.NewCollectionForm exposing (NewCollectionForm(..))

import Model.Creator.Existing.NewCollection as NewCollection exposing (NewCollection)


type NewCollectionForm
    = Image
    | Name String NewCollection.MetaForm
    | Symbol String NewCollection.MetaForm
