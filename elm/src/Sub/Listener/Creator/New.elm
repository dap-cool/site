module Sub.Listener.Creator.New exposing (New(..), fromString)


type New
    = HandleInvalid
    | HandleAlreadyExists
    | NewHandleSuccess


fromString : String -> Maybe New
fromString string =
    case string of
        "new-creator-handle-invalid" ->
            Just HandleInvalid

        "creator-handle-already-exists" ->
            Just HandleAlreadyExists

        "creator-new-handle-success" ->
            Just NewHandleSuccess

        _ ->
            Nothing
