module Msg.Collector.Collector exposing (FromCollector(..), toString)

import Model.Collection exposing (Collection)
import Model.Datum exposing (Datum)
import Model.Handle as Handle exposing (Handle)


type FromCollector
    = HandleForm Handle.Form
    | SelectCollection Handle Int
    | PrintCopy Handle Int
    | UnlockDatum Collection Datum (List Datum)


toString : FromCollector -> String
toString collector =
    case collector of
        HandleForm (Handle.Confirm _) ->
            "collector-search-handle"

        SelectCollection _ _ ->
            "collector-select-collection"

        PrintCopy _ _ ->
            "collector-print-copy"

        UnlockDatum _ _ _ ->
            "collector-unlock-datum"

        _ ->
            "no-op"
