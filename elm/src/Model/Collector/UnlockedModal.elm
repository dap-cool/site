module Model.Collector.UnlockedModal exposing (Current, IndexedFile, Total, UnlockedModal, apply)

import Model.Datum exposing (File)


type alias UnlockedModal =
    { current : IndexedFile
    , next : List File
    , previous : List File
    }


type alias IndexedFile =
    { file : File
    , index : Index
    }


type alias Current =
    IndexedFile


type alias Total =
    List IndexedFile


type alias Index =
    Int


apply : IndexedFile -> List IndexedFile -> UnlockedModal
apply file list =
    let
        init =
            { current = file
            , next = []
            , previous = []
            }
    in
    apply_ file list init


apply_ : IndexedFile -> List IndexedFile -> UnlockedModal -> UnlockedModal
apply_ file list modal =
    case list of
        [] ->
            modal

        head :: tail ->
            case modal.next of
                -- still adding to previous
                [] ->
                    case file.index == head.index of
                        True ->
                            -- start adding to next
                            case tail of
                                [] ->
                                    -- but actually we've completed iteration
                                    -- where the last element is the current index
                                    modal

                                headOfNext :: next ->
                                    apply_ file next { modal | next = headOfNext.file :: [] }

                        False ->
                            -- keep adding to previous
                            apply_ file tail { modal | previous = modal.previous ++ [ file.file ] }

                -- already started adding to next
                nel ->
                    apply_ file tail { modal | next = nel ++ [ head.file ] }
