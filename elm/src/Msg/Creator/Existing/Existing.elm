module Msg.Creator.Existing.Existing exposing (Existing(..), toString)

import Model.AlmostNewCollection exposing (AlmostNewCollection)
import Model.Collection exposing (Collection)
import Msg.Creator.Existing.NewCollectionForm as NewCollectionForm exposing (NewCollectionForm)


type Existing
    = ConfirmHandle String
      -- new collection
    | StartCreatingNewCollection
    | NewCollectionForm NewCollectionForm
    | CreateNewCollection AlmostNewCollection
    | MarkNewCollection Collection
      -- existing collection
    | SelectCollection Collection


toString : Existing -> String
toString existing =
    case existing of
        ConfirmHandle _ ->
            "existing-creator-confirm-handle"

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
