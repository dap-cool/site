module Model.Collector.Collector exposing (AtaBalance(..), Collector(..), Found(..), MaybeCollected(..))

import Model.Collection exposing (Collection, Intersection, Remainder)
import Model.Collector.WithCollections exposing (WithCollections)
import Model.Datum exposing (Datum)


type
    Collector
    -- searching
    = TypingHandle String
    | WaitingForHandleConfirmation
    | HandleInvalid String
    | HandleDoesNotExist String
      -- select collection
    | SelectedCreator ( Intersection, Remainder ) WithCollections
    | SelectedCollection MaybeCollected Selected Uploaded
    | UnlockedDatum Collected Unlocked Uploaded
      -- search by url
    | MaybeExistingCreator String
    | MaybeExistingCollection String Int


type alias Selected =
    Collection


type alias Collected =
    Collection


type alias Uploaded =
    List Datum


type alias Unlocked =
    Datum


type MaybeCollected
    = NotLoggedInYet
    | LoggedIn Found AtaBalance


type Found
    = Yes Collection
    | No


type AtaBalance
    = Positive
    | Zero
