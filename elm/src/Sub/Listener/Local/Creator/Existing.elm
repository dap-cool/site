module Sub.Listener.Local.Creator.Existing exposing (Existing(..), fromString)


type
    Existing
    -- creating collection
    = CreatingNewNft -- processing multi-part step-one
    | CreatedNewNft -- ready for step two
    | CreatedNewCollection -- step two -- TODO; delete


fromString : String -> Maybe Existing
fromString string =
    case string of
        "creator-creating-new-nft" ->
            Just <| CreatingNewNft

        "creator-created-new-nft" ->
            Just <| CreatedNewNft

        "creator-created-new-collection" ->
            Just <| CreatedNewCollection

        _ ->
            Nothing
