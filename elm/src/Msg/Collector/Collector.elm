module Msg.Collector.Collector exposing (FromCollector(..), toString)

import Model.Handle as Handle exposing (Handle)


type FromCollector
    = HandleForm Handle.Form
    | SelectCollection Handle Int
    | PurchaseCollection Handle Int


toString : FromCollector -> String
toString collector =
    case collector of
        HandleForm (Handle.Confirm _) ->
            "collector-search-handle"

        SelectCollection _ _ ->
            "collector-select-collection"

        PurchaseCollection _ _ ->
            "collector-purchase-collection"

        _ ->
            "no-op"
