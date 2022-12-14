module Sub.Listener.Local.Creator.Existing exposing (Existing(..), fromString)


type
    Existing
    -- creating collection
    = CreatingNewNft -- processing multi-part step-one
    | CreatedNewNft


fromString : String -> Maybe Existing
fromString string =
    case string of
        "creator-creating-new-nft" ->
            Just <| CreatingNewNft

        "creator-created-new-nft" ->
            Just <| CreatedNewNft

        _ ->
            Nothing
