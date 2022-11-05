module Model.Creator.Existing.Authorized exposing (..)

import Model.Collection exposing (Collection)
import Model.Creator.Existing.NewCollection exposing (NewCollection)
import Model.Handle exposing (Handle)
import Model.Wallet exposing (Wallet)
import Model.WithCollections exposing (WithCollections)


type Authorized
    = Top WithCollections
    | CreatingNewCollection Wallet Handle NewCollection
    | SelectedCollection Wallet Handle Collection
