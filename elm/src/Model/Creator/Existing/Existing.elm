module Model.Creator.Existing.Existing exposing (Existing(..))

import Model.Collection exposing (Collection)
import Model.Creator.Existing.NewCollection exposing (NewCollection)
import Model.Datum exposing (Datum)


type Existing
    = Top
    | CreatingNewCollection NewCollection
    | WaitingForUploaded
    | SelectedCollection Collection Uploaded


type alias Uploaded =
    List Datum
