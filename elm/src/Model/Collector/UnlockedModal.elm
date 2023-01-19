module Model.Collector.UnlockedModal exposing (UnlockedModal)

import Model.Datum exposing (File)


type alias UnlockedModal =
    { current : File
    , next : List File
    , previous : List File
    }
