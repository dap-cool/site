module Msg.Collector.Collector exposing (FromCollector(..), toString)

import Model.Collector.UnlockedModal exposing (Current, Total)
import Model.Datum exposing (Datum, File)
import Model.Handle as Handle exposing (Handle)


type FromCollector
    = HandleForm Handle.Form
    | SelectCollection Handle Int
    | PrintCopy Handle Int
    | UnlockDatum Datum
    | ViewFile Current Total
    | CloseFile


toString : FromCollector -> String
toString collector =
    case collector of
        HandleForm (Handle.Confirm _) ->
            "collector-search-handle"

        SelectCollection _ _ ->
            "collector-select-collection"

        PrintCopy _ _ ->
            "collector-print-copy"

        UnlockDatum _ ->
            "collector-unlock-datum"

        _ ->
            "no-op"
