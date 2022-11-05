module Sub.Listener.Collector.Collector exposing (ToCollector(..), fromString)


type
    ToCollector
    -- handle search
    = HandleInvalid
    | HandleDoesNotExist
    | HandleFound
      -- select collection
    | CollectionSelected
      -- purchase collection
    | CollectionPurchased


fromString : String -> Maybe ToCollector
fromString string =
    case string of
        "collector-handle-invalid" ->
            Just HandleInvalid

        "collector-handle-dne" ->
            Just HandleDoesNotExist

        "collector-handle-found" ->
            Just HandleFound

        "collector-collection-found" ->
            Just CollectionSelected

        "collector-collection-purchased" ->
            Just CollectionPurchased

        _ ->
            Nothing
