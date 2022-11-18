module Sub.Listener.Listener exposing (Listener(..), decode, decode0)

import Json.Decode as Decode
import Model.Global.Global as Global
import Model.Model exposing (Model)
import Model.State as Model
import Msg.Msg exposing (Msg)
import Sub.Listener.Collector.Collector as ToCollector exposing (ToCollector)
import Sub.Listener.Creator.Creator as ToCreator exposing (ToCreator)
import Util.Decode as Util


type Listener
    = Create ToCreator
    | Collect ToCollector
    | Global


decode0 : String -> Result String ( Global.Global, Maybe Listener )
decode0 string =
    let
        decoder : Decode.Decoder (Maybe Listener)
        decoder =
            Decode.field "listener" <| Decode.map fromString Decode.string
    in
    case Util.decode string decoder (\a -> a) of
        Ok maybeListener ->
            case Global.decode string of
                Ok global ->
                    Ok ( global, maybeListener )

                Err error ->
                    Err error

        Err error ->
            Err error


decode : Model -> Json -> (String -> Result String a) -> (a -> Model) -> ( Model, Cmd Msg )
decode model json moreDecoder update =
    case decodeMore json of
        -- more found
        Ok moreJson ->
            -- decode
            case moreDecoder moreJson of
                Ok decoded ->
                    ( update decoded
                    , Cmd.none
                    )

                -- error from decoder
                Err string ->
                    ( { model | state = Model.Error string }
                    , Cmd.none
                    )

        -- error from decoder
        Err string ->
            ( { model | state = Model.Error string }
            , Cmd.none
            )


decodeMore : String -> Result String Json
decodeMore string =
    let
        decoder =
            Decode.field "more" Decode.string
    in
    Util.decode string decoder (\a -> a)


fromString : String -> Maybe Listener
fromString string =
    case string of
        "global-connect" ->
            Just Global

        _ ->
            case ToCreator.fromString string of
                Just toCreator ->
                    Just <| Create toCreator

                Nothing ->
                    case ToCollector.fromString string of
                        Just toCollector ->
                            Just <| Collect toCollector

                        Nothing ->
                            Nothing


type alias Json =
    String
