module Model.Collector.Collector exposing (AtaBalance(..), Collector(..), Found(..), MaybeCollected(..))

import Model.Collection exposing (Collection)
import Model.Collector.WithCollections exposing (WithCollections)
import Model.Handle exposing (Handle)


type
    Collector
    -- searching
    = TypingHandle String
    | WaitingForHandleConfirmation
    | HandleInvalid String
    | HandleDoesNotExist String
      -- select collection
    | SelectedCreator Handle Intersection WithCollections
    | SelectedCollection MaybeCollected Selected
      -- search by url
    | MaybeExistingCreator String
    | MaybeExistingCollection String Int


type alias Intersection =
    List Collection


type alias Selected =
    Collection


type MaybeCollected
    = NotLoggedInYet
    | LoggedIn Found AtaBalance


type Found
    = Yes Collection
    | No


type AtaBalance
    = Positive
    | Zero
