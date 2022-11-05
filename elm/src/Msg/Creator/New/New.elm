module Msg.Creator.New.New exposing (New(..), toString)

import Model.Handle as Handle


type New
    = StartHandleForm
    | HandleForm Handle.Form


toString : New -> String
toString new =
    case new of
        HandleForm handleForm ->
            case handleForm of
                Handle.Confirm _ ->
                    "new-creator-confirm-handle"

                _ ->
                    "no-op"

        _ ->
            "no-op"
