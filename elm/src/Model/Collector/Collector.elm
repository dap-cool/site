module Model.Collector.Collector exposing (Collector(..))

import Model.Collection exposing (Collection)
import Model.Collector.WithCollections exposing (WithCollections)


type
    Collector
    -- searching
    = TypingHandle String
    | WaitingForHandleConfirmation
    | HandleInvalid String
    | HandleDoesNotExist String
      -- select collection
    | SelectedCreator Intersection WithCollections
    | SelectedCollection (Maybe CopiedEdition) MasterEdition
      -- search by url
    | MaybeExistingCreator String
    | MaybeExistingCollection String Int


type alias Intersection =
    List Collection


type alias MasterEdition =
    Collection


type alias CopiedEdition =
    Collection
