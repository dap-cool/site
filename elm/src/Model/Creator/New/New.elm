module Model.Creator.New.New exposing (New(..))


type New
    = Top
    | TypingHandle String
    | WaitingForHandleConfirmation
    | HandleInvalid String
    | HandleAlreadyExists String
