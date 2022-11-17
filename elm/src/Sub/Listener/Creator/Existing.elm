module Sub.Listener.Creator.Existing exposing (Existing(..), HandleFormStatus(..), fromString)


type Existing
    = HandleForm HandleFormStatus
      -- creating collection
    | CreatedNewCollection -- step one
    | MarkedNewCollection -- step two
      -- authorized with list of collections
    | Authorized


type HandleFormStatus
    = Invalid
    | DoesNotExist
    | UnAuthorized


fromString : String -> Maybe Existing
fromString string =
    case string of
        "creator-authorized" ->
            Just <| Authorized

        "existing-creator-handle-invalid" ->
            Just <| HandleForm Invalid

        "creator-handle-dne" ->
            Just <| HandleForm DoesNotExist

        "creator-handle-unauthorized" ->
            Just <| HandleForm UnAuthorized

        "creator-created-new-collection" ->
            Just <| CreatedNewCollection

        "creator-marked-new-collection" ->
            Just <| MarkedNewCollection

        _ ->
            Nothing
