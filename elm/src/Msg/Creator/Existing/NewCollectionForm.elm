module Msg.Creator.Existing.NewCollectionForm exposing (NewCollectionForm(..))

import Model.Creator.Existing.NewCollection as NewCollection exposing (NewCollection)


type NewCollectionForm
    = Image
    | Name String NewCollection.MaybeMetaForm
    | Symbol String NewCollection.MaybeMetaForm
    | CreatorDistribution String NewCollection.MaybeMetaForm
    | Price String NewCollection.MaybeMetaForm
    | Fee String NewCollection.MaybeMetaForm
