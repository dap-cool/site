module Sub.Listener.Creator.Existing exposing (Existing(..), HandleFormStatus(..), fromString)


type Existing
    = HandleForm HandleFormStatus
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

        _ ->
            Nothing
