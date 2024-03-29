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
        [ -- invalid literal
          UrlParser.map
            (Error "Invalid state; Click to homepage.")
            (UrlParser.s "invalid")

        -- creator
        , UrlParser.map
            (Create (Creator.New NewCreator.Top))
            (UrlParser.s "admin")

        -- collector
        , UrlParser.map
            (Collect (Collector.Top [] []))
            UrlParser.top
        , UrlParser.map
            (\handle -> Collect (Collector.MaybeExistingCreator handle))
            UrlParser.string
        , UrlParser.map
            (\handle index -> Collect (Collector.MaybeExistingCollection handle index))
            (UrlParser.string </> UrlParser.int)
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
        Create _ ->
            "#/admin"

        Collect collector ->
            case collector of
                Collector.Top _ _ ->
                    -- top
                    "#/"

                Collector.MaybeExistingCreator string ->
                    String.concat
                        [ "#/"
                        , string
                        ]

                Collector.MaybeExistingCollection string int ->
                    String.join
                        "/"
                        [ "#"
                        , string
                        , String.fromInt int
                        ]

                _ ->
                    "#/invalid"

        _ ->
            "#/invalid"


href : Local -> Html.Attribute msg
href local =
    Html.Attributes.href (path local)
