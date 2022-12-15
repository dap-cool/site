module Model.Creator.Existing.Existing exposing (Existing(..))

import Model.Collection exposing (Collection)
import Model.Creator.Existing.NewCollection exposing (NewCollection)
import Model.Creator.Existing.UploadForm exposing (UploadForm)
import Model.Datum exposing (Datum)


type Existing
    = Top
    | CreatingNewCollection NewCollection
    | WaitingForUploaded
    | SelectedCollection Collection Uploaded
    | Uploading Collection UploadForm
    | WaitingForUpload Collection
    | UploadSuccessful Collection


type alias Uploaded =
    List Datum
