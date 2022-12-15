module Msg.Global exposing (Global(..), toString)


type
    Global
    -- wallet
    = Connect
    | Disconnect
      -- file reader
    | ReadLogos


toString : Global -> String
toString global =
    case global of
        Connect ->
            "connect"

        Disconnect ->
            "disconnect"

        ReadLogos ->
            "read-logos"
