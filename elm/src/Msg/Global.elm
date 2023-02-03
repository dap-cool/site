module Msg.Global exposing (Global(..), toString)


type
    Global
    -- wallet
    = Connect
    | Disconnect
      -- featured creators
    | FetchFeaturedCreators


toString : Global -> String
toString global =
    case global of
        Connect ->
            "connect"

        Disconnect ->
            "disconnect"

        FetchFeaturedCreators ->
            "fetch-featured-creators"
