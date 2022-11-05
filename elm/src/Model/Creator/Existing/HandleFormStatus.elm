module Model.Creator.Existing.HandleFormStatus exposing (..)

import Model.Handle exposing (Handle)
import Model.Wallet exposing (Wallet)


type HandleFormStatus
    = TypingHandle String
    | WaitingForHandleConfirmation
    | HandleInvalid String
    | HandleDoesNotExist String
    | UnAuthorized Wallet Handle
