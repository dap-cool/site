module Model.Creator.Existing.Existing exposing (Existing(..))

import Model.Collection exposing (Collection)
import Model.Creator.Existing.BioForm exposing (BioForm)
import Model.Creator.Existing.LogoForm exposing (LogoForm)
import Model.Creator.Existing.NewCollection exposing (NewCollection)
import Model.Creator.Existing.UploadForm exposing (UploadForm)
import Model.Datum exposing (Datum)


type Existing
    = Top LogoForm BioForm
    | CreatingNewCollection NewCollection
    | SelectedCollection Collection Uploaded
    | Uploading Collection UploadForm


type alias Uploaded =
    List Datum
