module Model.Collector.Collector exposing (Collector(..))

import Model.WithCollection exposing (WithCollection)
import Model.WithCollections exposing (WithCollections)


type
    Collector
    -- searching
    = TypingHandle String
    | WaitingForHandleConfirmation
    | HandleInvalid String
    | HandleDoesNotExist String
      -- select collection
    | SelectedCreator WithCollections
    | SelectedCollection WithCollection
      -- purchase collection
    | WaitingForPurchase
    | PurchaseSuccess WithCollection
      -- search by url
    | MaybeExistingCreator String
    | MaybeExistingCollection String Int
