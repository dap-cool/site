module Msg.Creator.Existing.Existing exposing (Existing(..), toString)

import Model.Collection exposing (Collection)
import Model.Creator.Existing.BioForm exposing (BioForm)
import Model.Creator.Existing.NewCollection as NewCollection
import Model.Creator.Existing.UploadForm exposing (UploadForm)
import Model.File exposing (File)
import Msg.Creator.Existing.NewCollectionForm as NewCollectionForm exposing (NewCollectionForm)


type
    Existing
    -- creator metadata
    = ProvisionMetadata
    | SelectLogo
    | UploadLogo File
    | TypingBio BioForm String
    | UploadBio String
      -- new collection form
    | StartCreatingNewCollection
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
        ProvisionMetadata ->
            "creator-provision-metadata"

        SelectLogo ->
            "creator-select-logo"

        UploadLogo _ ->
            "creator-upload-logo"

        UploadBio _ ->
            "creator-upload-bio"

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
