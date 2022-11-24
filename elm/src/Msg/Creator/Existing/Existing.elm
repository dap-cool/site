module Msg.Creator.Existing.Existing exposing (Existing(..), toString)

import Model.Collection exposing (Collection)
import Model.Creator.Existing.NewCollection as NewCollection
import Msg.Creator.Existing.NewCollectionForm as NewCollectionForm exposing (NewCollectionForm)


type
    Existing
    -- new collection
    = StartCreatingNewCollection
    | NewCollectionForm NewCollectionForm
    | CreateNewCollection NewCollection.Form
    | MarkNewCollection Collection
      -- existing collection
    | SelectCollection Collection


toString : Existing -> String
toString existing =
    case existing of
        NewCollectionForm form ->
            case form of
                NewCollectionForm.Image ->
                    "creator-prepare-image-form"

                _ ->
                    "no-op"

        CreateNewCollection _ ->
            "creator-create-new-collection"

        MarkNewCollection _ ->
            "creator-mark-new-collection"

        _ ->
            "no-op"
