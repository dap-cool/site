module Model.State.Local.Local exposing (..)

import Html
import Html.Attributes
import Model.Collector.Collector as Collector exposing (Collector)
import Model.Creator.Creator as Creator exposing (Creator)
import Model.Creator.New.New as NewCreator
import Url
import Url.Parser as UrlParser exposing ((</>))


type Local
    = Create Creator
    | Collect Collector
    | Error String


urlParser : UrlParser.Parser (Local -> c) c
urlParser =
    UrlParser.oneOf
        -- collector
        [ UrlParser.map
            (Collect (Collector.TypingHandle ""))
            UrlParser.top
        , UrlParser.map
            (Collect (Collector.TypingHandle ""))
            (UrlParser.s "creator")
        , UrlParser.map
            (\handle -> Collect (Collector.MaybeExistingCreator handle))
            (UrlParser.s "creator" </> UrlParser.string)
        , UrlParser.map
            (\handle index -> Collect (Collector.MaybeExistingCollection handle index))
            (UrlParser.s "creator" </> UrlParser.string </> UrlParser.int)

        -- creator
        , UrlParser.map
            (Create Creator.Top)
            (UrlParser.s "admin")
        , UrlParser.map
            (\handle -> Create (Creator.MaybeExisting handle))
            (UrlParser.s "admin" </> UrlParser.string)
        , UrlParser.map
            (Create (Creator.New NewCreator.Top))
            (UrlParser.s "new")
        ]


parse : Url.Url -> Local
parse url =
    let
        target =
            -- The RealWorld spec treats the fragment like a path.
            -- This makes it *literally* the path, so we can proceed
            -- with parsing as if it had been a normal path all along.
            { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
    in
    case UrlParser.parse urlParser target of
        Just state ->
            state

        Nothing ->
            Error "404; Invalid Path"


path : Local -> String
path local =
    case local of
        Create creator ->
            case creator of
                Creator.Top ->
                    "#/admin"

                Creator.New NewCreator.Top ->
                    "#/new"

                Creator.MaybeExisting string ->
                    String.concat
                        [ "#/admin"
                        , "/"
                        , string
                        ]

                _ ->
                    path (Create Creator.Top)

        Collect collector ->
            case collector of
                Collector.MaybeExistingCreator string ->
                    String.concat
                        [ "#/creator"
                        , "/"
                        , string
                        ]

                Collector.MaybeExistingCollection string int ->
                    String.join
                        "/"
                        [ "#/creator"
                        , string
                        , String.fromInt int
                        ]

                _ ->
                    "#/creator"

        Error _ ->
            "#/invalid"


href : Local -> Html.Attribute msg
href local =
    Html.Attributes.href (path local)
