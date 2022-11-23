module Sub.Listener.Local.Creator.Existing exposing (Existing(..), fromString)


type
    Existing
    -- creating collection
    = CreatedNewCollection -- step one
    | MarkedNewCollection -- step two


fromString : String -> Maybe Existing
fromString string =
    case string of
        "creator-created-new-collection" ->
            Just <| CreatedNewCollection

        "creator-marked-new-collection" ->
            Just <| MarkedNewCollection

        _ ->
            Nothing
