module Sub.Sender.Sender exposing (Sender(..), WithMore, encode, encode0)

import Json.Encode as Encode
import Model.Global as Global exposing (Global)
import Msg.Collector.Collector as CollectorMsg exposing (FromCollector)
import Msg.Creator.Creator as CreatorMsg exposing (FromCreator)
import Msg.Global as FromGlobal


type Sender
    = Create FromCreator
    | Collect FromCollector
    | Global FromGlobal.Global


type alias WithMore =
    { sender : Sender
    , global : Global
    , more : Json
    }


encode : WithMore -> Json
encode withMore =
    let
        encoder =
            Encode.object
                [ ( "sender", Encode.string <| toString withMore.sender )
                , ( "global", Global.encoder withMore.global )
                , ( "more", Encode.string withMore.more )
                ]
    in
    Encode.encode 0 encoder


encode0 : Sender -> Json
encode0 role =
    let
        encoder =
            Encode.object
                [ ( "sender", Encode.string <| toString role )
                ]
    in
    Encode.encode 0 encoder


toString : Sender -> String
toString role =
    case role of
        Create fromCreator ->
            CreatorMsg.toString fromCreator

        Collect fromCollector ->
            CollectorMsg.toString fromCollector

        Global fromGlobal ->
            FromGlobal.toString fromGlobal


type alias Json =
    String
