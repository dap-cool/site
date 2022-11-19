module Sub.Listener.Local.Local exposing (ToLocal(..), fromString)

import Sub.Listener.Local.Collector.Collector as ToCollector exposing (ToCollector)
import Sub.Listener.Local.Creator.Creator as ToCreator exposing (ToCreator)

type ToLocal
    = Create ToCreator
    | Collect ToCollector


fromString : String -> Maybe ToLocal
fromString string =
    case ToCreator.fromString string of
        Just toCreator ->
            Just <| Create toCreator

        Nothing ->
            case ToCollector.fromString string of
                Just toCollector ->
                    Just <| Collect toCollector

                Nothing ->
                    Nothing
