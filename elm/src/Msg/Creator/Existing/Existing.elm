module Msg.Creator.Existing.Existing exposing (Existing(..), toString)

import Model.AlmostNewCollection exposing (AlmostNewCollection)
import Model.Collection exposing (Collection)
import Model.Handle as Handle exposing (Handle)
import Model.Wallet exposing (Wallet)
import Msg.Creator.Existing.NewCollectionForm as NewCollectionForm exposing (NewCollectionForm)


type Existing
    = StartHandleForm
    | HandleForm Handle.Form
      -- new collection
    | StartCreatingNewCollection Wallet Handle
    | NewCollectionForm Wallet Handle NewCollectionForm
    | CreateNewCollection Wallet AlmostNewCollection
      -- existing collection
    | SelectCollection Wallet Handle Collection


toString : Existing -> String
toString existing =
    case existing of
        HandleForm handleForm ->
            case handleForm of
                Handle.Confirm _ ->
                    "existing-creator-confirm-handle"

                _ ->
                    "no-op"

        NewCollectionForm _ _ form ->
            case form of
                NewCollectionForm.Image ->
                    "creator-prepare-image-form"

                _ ->
                    "no-op"

        CreateNewCollection _ _ ->
            "creator-create-new-collection"

        _ ->
            "no-op"
