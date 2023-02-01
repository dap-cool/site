module Model.Creator.Existing.Existing exposing (Existing(..))

import Model.Collection exposing (Collection)
import Model.Creator.Existing.LogoForm exposing (LogoForm)
import Model.Creator.Existing.NewCollection exposing (NewCollection)
import Model.Creator.Existing.UploadForm exposing (UploadForm)
import Model.Datum exposing (Datum)


type Existing
    = Top LogoForm
    | CreatingNewCollection NewCollection
    | SelectedCollection Collection Uploaded
    | Uploading Collection UploadForm
    | UploadSuccessful Collection


type alias Uploaded =
    List Datum
