module Model.State exposing (State(..), href, parse)

import Html
import Html.Attributes
import Model.Collector.Collector as Collector exposing (Collector)
import Model.Creator.Creator as Creator exposing (Creator)
import Model.Creator.New.New as NewCreator
import Model.Global exposing (Global(..))
import Url
import Url.Parser as UrlParser exposing ((</>))


type State
    = Create Global Creator
    | Collect Global Collector
    | Error String


urlParser : UrlParser.Parser (State -> c) c
urlParser =
    UrlParser.oneOf
        -- collector
        [ UrlParser.map
            (Collect NoWalletYet (Collector.TypingHandle ""))
            UrlParser.top
        , UrlParser.map
            (Collect NoWalletYet (Collector.TypingHandle ""))
            (UrlParser.s "creator")
        , UrlParser.map
            (\handle -> Collect NoWalletYet (Collector.MaybeExistingCreator handle))
            (UrlParser.s "creator" </> UrlParser.string)
        , UrlParser.map
            (\handle index -> Collect NoWalletYet (Collector.MaybeExistingCollection handle index))
            (UrlParser.s "creator" </> UrlParser.string </> UrlParser.int)

        -- creator
        , UrlParser.map
            (Create NoWalletYet Creator.Top)
            (UrlParser.s "admin")
        , UrlParser.map
            (\handle -> Create NoWalletYet (Creator.MaybeExisting handle))
            (UrlParser.s "admin" </> UrlParser.string)
        , UrlParser.map
            (Create NoWalletYet (Creator.New NewCreator.Top))
            (UrlParser.s "new")
        ]


parse : Url.Url -> State
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


path : State -> String
path state =
    case state of
        Create _ creator ->
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
                    path (Create NoWalletYet Creator.Top)

        Collect _ collector ->
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


href : State -> Html.Attribute msg
href state =
    Html.Attributes.href (path state)
