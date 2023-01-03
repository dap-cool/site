module Sub.Listener.Local.Creator.Existing exposing (Existing(..), fromString)


type
    Existing
    -- creating collection
    = SelectedNewNftLogo
    | CreatingNewNft -- processing multi-part step-one
    | CreatedNewNft
      -- uploading
    | SelectedCollection
    | StillUploading
    | UploadSuccessful


fromString : String -> Maybe Existing
fromString string =
    case string of
        "creator-selected-new-nft-logo" ->
            Just <| SelectedNewNftLogo

        "creator-creating-new-nft" ->
            Just <| CreatingNewNft

        "creator-created-new-nft" ->
            Just <| CreatedNewNft

        "creator-selected-collection" ->
            Just <| SelectedCollection

        "creator-still-uploading" ->
            Just <| StillUploading

        "creator-upload-success" ->
            Just <| UploadSuccessful

        _ ->
            Nothing
