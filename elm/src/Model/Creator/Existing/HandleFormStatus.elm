module Model.Creator.Existing.HandleFormStatus exposing (..)


type HandleFormStatus
    = WaitingForHandleConfirmation
    | HandleInvalid String
    | HandleDoesNotExist String
    | UnAuthorized
