module Msg.Creator.Existing.Existing exposing (Existing(..), toString)

import Model.Collection exposing (Collection)
import Model.Creator.Existing.NewCollection as NewCollection
import Model.Creator.Existing.UploadForm exposing (UploadForm)
import Msg.Creator.Existing.NewCollectionForm as NewCollectionForm exposing (NewCollectionForm)


type
    Existing
    -- new collection form
    = StartCreatingNewCollection
    | NewCollectionForm NewCollectionForm
      -- create new nft rpc transactions
    | CreateNewNft NewCollection.MetaForm
      -- existing collection
    | SelectCollection Collection
    | StartUploading Collection
    | SelectFilesToUpload
    | TypingUploadTitle Collection UploadForm String
    | Upload Collection UploadForm


toString : Existing -> String
toString existing =
    case existing of
        NewCollectionForm form ->
            case form of
                NewCollectionForm.Image ->
                    "creator-prepare-image-form"

                _ ->
                    "no-op"

        CreateNewNft _ ->
            "creator-create-new-nft"

        SelectCollection _ ->
            "creator-select-collection"

        SelectFilesToUpload ->
            "creator-select-files-to-upload"

        Upload _ _ ->
            "creator-upload"

        _ ->
            "no-op"
