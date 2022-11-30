module Sub.Listener.Local.Creator.Existing exposing (Existing(..), fromString)


type
    Existing
    -- creating collection
    = CreatingNewCollection -- processing multi-part step-one
    | CreatedNewCollection -- ready for step two
    | MarkedNewCollection -- step two


fromString : String -> Maybe Existing
fromString string =
    case string of
        "creator-creating-new-collection" ->
            Just <| CreatingNewCollection

        "creator-created-new-collection" ->
            Just <| CreatedNewCollection

        "creator-marked-new-collection" ->
            Just <| MarkedNewCollection

        _ ->
            Nothing
