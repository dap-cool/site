module Sub.Listener.Creator.Creator exposing (ToCreator(..), fromString)

import Sub.Listener.Creator.Existing as Existing exposing (Existing)
import Sub.Listener.Creator.New as New exposing (New)


type ToCreator
    = New New
    | Existing Existing


fromString : String -> Maybe ToCreator
fromString string =
    case Existing.fromString string of
        Just existing ->
            Just <| Existing existing

        Nothing ->
            case New.fromString string of
                Just new ->
                    Just <| New new

                Nothing ->
                    Nothing
