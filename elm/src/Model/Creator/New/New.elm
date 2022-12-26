module Model.Creator.New.New exposing (New(..))


type New
    = Top
    | TypingHandle String
    | HandleInvalid String
    | HandleAlreadyExists String
