module View.Collect.Collect exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, placeholder, src, style, target, type_, width)
import Html.Events exposing (onClick, onInput)
import Model.Collection as Collection exposing (Collection)
import Model.Collector.Collector as Collector exposing (Collector(..))
import Model.Datum as Datum exposing (Datum)
import Model.Handle as Handle exposing (Handle)
import Model.State.Local.Local as Local
import Msg.Collector.Collector as CollectorMsg
import Msg.Global as FromGlobal
import Msg.Msg as Msg exposing (Msg(..))
import View.Generic.Collection.Collector.Collector
import View.Generic.Datum.Datum


body : Collector -> Html Msg
body collector =
    let
        html =
            case collector of
                TypingHandle string ->
                    let
                        select =
                            case string of
                                "" ->
                                    Html.div
                                        []
                                        []

                                _ ->
                                    Html.div
                                        []
                                        [ Html.button
                                            [ class "is-button-1"
                                            , onClick <|
                                                FromCollector <|
                                                    CollectorMsg.HandleForm <|
                                                        Handle.Confirm string
                                            ]
                                            [ Html.text <|
                                                String.concat
                                                    [ "search for collections from handle:"
                                                    , " "
                                                    , string
                                                    ]
                                            ]
                                        ]
                    in
                    Html.div
                        []
                        [ Html.div
                            []
                            [ Html.input
                                [ class "input is-size-3"
                                , type_ "text"
                                , placeholder "🔍 Find Creators"
                                , onInput <|
                                    \s ->
                                        FromCollector <|
                                            CollectorMsg.HandleForm <|
                                                Handle.Typing s
                                ]
                                []
                            ]
                        , select
                        , hiw
                        ]

                WaitingForHandleConfirmation ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ Html.div
                            [ class "is-loading"
                            ]
                            []
                        ]

                HandleInvalid string ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ Html.div
                            [ class "has-border-2 px-2 py-2"
                            ]
                            [ Html.text <|
                                String.concat
                                    [ "input handle found to be invalid:"
                                    , " "
                                    , string
                                    ]
                            , Html.div
                                [ class "pt-1"
                                ]
                                [ Html.button
                                    [ class "is-button-1"
                                    , onClick <|
                                        FromCollector <|
                                            CollectorMsg.HandleForm <|
                                                Handle.Typing ""
                                    ]
                                    [ Html.text
                                        """try again
                                        """
                                    ]
                                ]
                            ]
                        ]

                HandleDoesNotExist string ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ Html.div
                            [ class "has-border-2 px-2 py-2"
                            ]
                            [ Html.text <|
                                String.concat
                                    [ "input handle does-not-exist:"
                                    , " "
                                    , string
                                    ]
                            , Html.div
                                [ class "pt-1"
                                ]
                                [ Html.button
                                    [ class "is-button-1"
                                    , onClick <|
                                        FromCollector <|
                                            CollectorMsg.HandleForm <|
                                                Handle.Typing ""
                                    ]
                                    [ Html.text
                                        """try again
                                        """
                                    ]
                                ]
                            ]
                        ]

                SelectedCreator ( intersection, remainder ) total ->
                    let
                        ix =
                            case intersection of
                                [] ->
                                    Html.div
                                        []
                                        []

                                _ ->
                                    Html.div
                                        [ class "mt-5"
                                        ]
                                        [ Html.div
                                            [ class "mb-3 is-text-container-3 is-size-3 is-text-container-4-mobile is-size-4-mobile"
                                            ]
                                            [ Html.text "Already collected ⬇️"
                                            ]
                                        , View.Generic.Collection.Collector.Collector.viewMany
                                            intersection
                                        ]

                        rx =
                            case remainder of
                                [] ->
                                    Html.div
                                        []
                                        []

                                _ ->
                                    Html.div
                                        [ class "mt-5"
                                        ]
                                        [ Html.div
                                            [ class "mb-3 is-text-container-3 is-size-3 is-text-container-4-mobile is-size-4-mobile"
                                            ]
                                            [ Html.text "Not collected yet ⬇️"
                                            ]
                                        , View.Generic.Collection.Collector.Collector.viewMany
                                            remainder
                                        ]
                    in
                    Html.div
                        []
                        [ breadcrumb total.handle
                        , header total.handle
                        , ix
                        , rx
                        ]

                SelectedCollection maybeCollected selected uploaded ->
                    let
                        purchase =
                            case Collection.isSoldOut selected of
                                True ->
                                    Html.div
                                        []
                                        [ Html.div
                                            []
                                            [ Html.text
                                                """Check out
                                                """
                                            , Html.a
                                                [ class "has-sky-blue-text"
                                                , href <|
                                                    String.concat
                                                        [ "https://hyperspace.xyz/token/"
                                                        , selected.accounts.mint
                                                        ]
                                                , target "_blank"
                                                ]
                                                [ Html.text
                                                    """this collection on hyperspace
                                                    """
                                                ]
                                            , Html.text
                                                """ to place your bid on the secondary market. 🤝
                                                """
                                            ]
                                        ]

                                False ->
                                    Html.button
                                        [ class "is-button-1"
                                        , onClick <|
                                            FromCollector <|
                                                CollectorMsg.PrintCopy
                                                    selected.meta.handle
                                                    selected.meta.index
                                        ]
                                        [ Html.text "purchase"
                                        ]

                        purchaseAgain =
                            case Collection.isSoldOut selected of
                                True ->
                                    Html.div
                                        []
                                        [ Html.div
                                            []
                                            [ Html.text
                                                """Check out
                                                """
                                            , Html.a
                                                [ class "has-sky-blue-text"
                                                , href <|
                                                    String.concat
                                                        [ "https://hyperspace.xyz/token/"
                                                        , selected.accounts.mint
                                                        ]
                                                , target "_blank"
                                                ]
                                                [ Html.text
                                                    """this collection on hyperspace
                                                    """
                                                ]
                                            , Html.text
                                                """ to list or place your bid for another on the secondary market. 🤝
                                                """
                                            ]
                                        ]

                                False ->
                                    Html.button
                                        [ class "is-button-1"
                                        , onClick <|
                                            FromCollector <|
                                                CollectorMsg.PrintCopy
                                                    selected.meta.handle
                                                    selected.meta.index
                                        ]
                                        [ Html.text "purchase again"
                                        ]

                        uploads maybeUnlockable =
                            let
                                unlock : Datum -> Html Msg
                                unlock datum =
                                    case maybeUnlockable of
                                        Just unlockable ->
                                            Html.div
                                                []
                                                [ Html.button
                                                    [ class "is-button-3"
                                                    , onClick <|
                                                        FromCollector <|
                                                            CollectorMsg.UnlockDatum
                                                                unlockable
                                                                datum
                                                                uploaded
                                                    ]
                                                    [ Html.text "unlock"
                                                    ]
                                                ]

                                        Nothing ->
                                            Html.div
                                                []
                                                [ Html.text
                                                    """🔒
                                                    """
                                                ]

                                row : Datum -> Html Msg
                                row datum =
                                    Html.tr
                                        []
                                        [ Html.td
                                            []
                                            [ Html.div
                                                [ class "is-text-container-4 is-size-4"
                                                ]
                                                [ Html.text datum.metadata.title
                                                ]
                                            ]
                                        , Html.td
                                            []
                                            [ Html.div
                                                [ class "is-text-container-4 is-size-4"
                                                ]
                                                [ Html.text <|
                                                    String.fromInt datum.metadata.zip.count
                                                ]
                                            ]
                                        , Html.td
                                            []
                                            [ Html.div
                                                [ class "is-text-container-4 is-size-4"
                                                ]
                                                [ Html.text <|
                                                    String.fromInt datum.metadata.timestamp
                                                ]
                                            ]
                                        , Html.td
                                            []
                                            [ Html.div
                                                [ class "is-text-container-4 is-size-4"
                                                ]
                                                [ unlock datum
                                                ]
                                            ]
                                        ]

                                rows : Html Msg
                                rows =
                                    Html.tbody
                                        []
                                    <|
                                        List.map
                                            row
                                            uploaded
                            in
                            Html.div
                                [ class "table-container"
                                ]
                                [ Html.table
                                    [ class "table is-fullwidth"
                                    ]
                                    [ Html.thead
                                        []
                                        [ Html.tr
                                            []
                                            [ Html.th
                                                []
                                                [ Html.text <|
                                                    String.concat
                                                        [ "Collectables"
                                                        , " "
                                                        , "("
                                                        , String.fromInt <| List.length uploaded
                                                        , ")"
                                                        ]
                                                ]
                                            , Html.th
                                                []
                                                [ Html.text
                                                    """Files
                                                    """
                                                ]
                                            , Html.th
                                                []
                                                [ Html.text
                                                    """Uploaded
                                                    """
                                                ]
                                            , Html.th
                                                []
                                                []
                                            ]
                                        ]
                                    , rows
                                    ]
                                ]

                        view_ =
                            case maybeCollected of
                                Collector.NotLoggedInYet ->
                                    Html.div
                                        []
                                        [ Html.div
                                            [ class "columns is-mobile"
                                            ]
                                            [ Html.div
                                                [ class "column is-half-mobile is-one-third-tablet"
                                                ]
                                                [ View.Generic.Collection.Collector.Collector.view selected
                                                , Html.div
                                                    []
                                                    [ purchase
                                                    ]
                                                , Html.div
                                                    []
                                                    [ Html.button
                                                        [ class "is-light-text-container-4 mr-2"
                                                        , onClick <| Msg.Global FromGlobal.Connect
                                                        ]
                                                        [ Html.text "Connect Wallet"
                                                        ]
                                                    , Html.text
                                                        """ to unlock if you've already purchased.
                                                        """
                                                    ]
                                                ]
                                            , Html.div
                                                [ class "column is-half-mobile is-two-third-tablet"
                                                ]
                                                [ Html.div
                                                    []
                                                    [ uploads Nothing
                                                    ]
                                                ]
                                            ]
                                        ]

                                Collector.LoggedIn found ataBalance ->
                                    case ( found, ataBalance ) of
                                        ( Collector.No, Collector.Positive ) ->
                                            Html.div
                                                []
                                                [ Html.div
                                                    [ class "columns is-mobile"
                                                    ]
                                                    [ Html.div
                                                        [ class "column is-half-mobile is-one-third-tablet"
                                                        ]
                                                        [ View.Generic.Collection.Collector.Collector.view selected
                                                        , Html.text
                                                            """It looks like you already have a positive token balance
                                                            for this collection 👀
                                                            """
                                                        , Html.div
                                                            []
                                                            [ Html.button
                                                                []
                                                                [ Html.text "Declare"
                                                                ]
                                                            , Html.text
                                                                """ as an official collector to start unlocking stuff 😎
                                                                """
                                                            ]
                                                        ]
                                                    , Html.div
                                                        [ class "column is-half-mobile is-two-third-tablet"
                                                        ]
                                                        [ Html.div
                                                            []
                                                            [ uploads Nothing
                                                            ]
                                                        ]
                                                    ]
                                                ]

                                        ( Collector.No, Collector.Zero ) ->
                                            Html.div
                                                []
                                                [ Html.div
                                                    [ class "columns is-mobile"
                                                    ]
                                                    [ Html.div
                                                        [ class "column is-half-mobile is-one-third-tablet"
                                                        ]
                                                        [ View.Generic.Collection.Collector.Collector.view selected
                                                        , Html.div
                                                            []
                                                            [ purchase
                                                            ]
                                                        ]
                                                    , Html.div
                                                        [ class "column is-half-mobile is-two-third-tablet"
                                                        ]
                                                        [ uploads Nothing
                                                        ]
                                                    ]
                                                ]

                                        ( Collector.Yes collected, Collector.Positive ) ->
                                            Html.div
                                                []
                                                [ Html.div
                                                    [ class "columns is-mobile"
                                                    ]
                                                    [ Html.div
                                                        [ class "column is-half-mobile is-one-third-tablet"
                                                        ]
                                                        [ View.Generic.Collection.Collector.Collector.view selected
                                                        , Html.div
                                                            []
                                                            [ Html.text
                                                                """Welcome back official collector \u{1FAE1}
                                                                """
                                                            ]
                                                        , Html.div
                                                            []
                                                            [ Html.text <|
                                                                String.concat
                                                                    [ "token balance:"
                                                                    , " "
                                                                    , String.fromInt collected.accounts.ata.balance
                                                                    ]
                                                            ]
                                                        , Html.div
                                                            []
                                                            [ purchaseAgain
                                                            ]
                                                        ]
                                                    , Html.div
                                                        [ class "column is-half-mobile is-two-third-tablet"
                                                        ]
                                                        [ Html.div
                                                            []
                                                            [ uploads <| Just collected
                                                            ]
                                                        ]
                                                    ]
                                                ]

                                        ( Collector.Yes collected, Collector.Zero ) ->
                                            Html.div
                                                []
                                                [ Html.div
                                                    [ class "columns is-mobile"
                                                    ]
                                                    [ Html.div
                                                        [ class "column is-half-mobile is-one-third-tablet"
                                                        ]
                                                        [ View.Generic.Collection.Collector.Collector.view collected
                                                        , Html.div
                                                            []
                                                            [ Html.text
                                                                """Welcome back official collector \u{1FAE1}
                                                                """
                                                            ]
                                                        , Html.div
                                                            []
                                                            [ Html.text
                                                                """It looks like you've sold or transferred your tokens here
                                                                which means you can no longer unlock stuff.
                                                                """
                                                            ]
                                                        , Html.div
                                                            []
                                                            [ purchaseAgain
                                                            ]
                                                        ]
                                                    , Html.div
                                                        [ class "column is-half-mobile is-two-third-tablet"
                                                        ]
                                                        [ Html.div
                                                            []
                                                            [ uploads Nothing
                                                            ]
                                                        ]
                                                    ]
                                                ]
                    in
                    Html.div
                        []
                        [ breadcrumb2 selected
                        , header selected.meta.handle
                        , Html.div
                            [ class "mt-6"
                            ]
                            [ view_
                            ]
                        ]

                UnlockedDatum collection datum _ ->
                    Html.div
                        []
                        [ breadcrumb3 collection datum
                        , header collection.meta.handle
                        , Html.div
                            [ class "mt-6 columns"
                            ]
                          <|
                            List.map
                                (\file ->
                                    Html.div
                                        [ class "column is-one-third"
                                        ]
                                        [ Html.div
                                            -- [ class "is-upload"
                                            []
                                            [ View.Generic.Datum.Datum.view file
                                            ]
                                        ]
                                )
                                datum.metadata.zip.files
                        ]

                MaybeExistingCreator _ ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ Html.div
                            [ class "is-loading"
                            ]
                            []
                        ]

                MaybeExistingCollection _ _ ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ Html.div
                            [ class "is-loading"
                            ]
                            []
                        ]
    in
    Html.div
        [ class "container"
        ]
        [ html
        ]


header : String -> Html Msg
header handle =
    Html.div
        []
        [ Html.div
            [ class "mt-4"
            ]
            [ Html.div
                [ class "is-family-secondary is-light-text-container-6 is-size-6 is-light-text-container-6-mobile is-size-6-mobile is-italic"
                ]
                [ Html.text "Creator"
                ]
            , Html.div
                [ class "is-text-container-2 is-size-2 is-text-container-3-mobile is-size-3-mobile"
                ]
                [ Html.text handle
                ]
            ]
        , Html.div
            [ class "mt-5"
            ]
            [ Html.div
                [ class "is-family-secondary is-light-text-container-6 is-size-6 is-light-text-container-6-mobile is-size-6-mobile is-italic"
                ]
                [ Html.text "bio"
                ]
            , Html.div
                [ class "mt-1 container is-text-container-3 is-size-3 is-text-container-4-mobile is-size-4-mobile"
                ]
                [ Html.text
                    """Lorem ipsum dolor sit amet, consectetur adipiscing elit,
                    sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
                    Aliquet enim tortor at auctor urna nunc id cursus.
                    Pulvinar etiam non quam lacus.
                    """
                ]
            ]
        ]


hiw : Html Msg
hiw =
    Html.div
        [ class "is-hiw mt-6"
        ]
        [ Html.h3
            [ class "is-text-container-2 is-size-2 has-text-centered mt-6"
            , style "height" "100px"
            ]
            [ Html.text "How It Works"
            ]
        , Html.div
            [ class "columns is-mobile mb-6"
            , style "height" "203px"
            ]
            [ Html.div
                [ class "column is-2"
                ]
                []
            , Html.div
                [ class "column is-3"
                ]
                [ Html.img
                    [ src "images/landing/landing-a.svg"
                    , width 269
                    ]
                    []
                ]
            , Html.div
                [ class "column is-7"
                , style "margin-top" "75px"
                ]
                [ Html.div
                    [ class "is-text-container-3 is-size-3"
                    ]
                    [ Html.text "Creators"
                    ]
                , Html.div
                    [ class "is-light-text-container-4 is-size-4"
                    ]
                    [ Html.div
                        []
                        [ Html.text "Publish exclusive content that can be"
                        ]
                    , Html.div
                        []
                        [ Html.text "unlocked with the purchase of an NFT."
                        ]
                    ]
                ]
            ]
        , Html.div
            [ class "columns is-mobile mt-6"
            , style "height" "203px"
            ]
            [ Html.div
                [ class "column is-2"
                ]
                []
            , Html.div
                [ class "column is-5"
                , style "margin-top" "55px"
                ]
                [ Html.div
                    [ class "is-text-container-3 is-size-3"
                    ]
                    [ Html.text "Collectors"
                    ]
                , Html.div
                    [ class "is-light-text-container-4 is-size-4"
                    ]
                    [ Html.div
                        []
                        [ Html.text
                            """Unlock exclusive content from your
                            favorite Creators. Take ownership and
                            re-sell in secondary markets with blockchain.
                            """
                        ]
                    ]
                ]
            , Html.div
                [ class "column is-5"
                ]
                [ Html.img
                    [ src "images/landing/landing-b.svg"
                    , width 215
                    ]
                    []
                ]
            ]
        ]


breadcrumb : Handle -> Html Msg
breadcrumb handle =
    Html.div
        [ class "is-family-secondary is-light-text-container-6 is-size-6"
        ]
        [ Html.a
            [ class "is-underlined"
            , Local.href <|
                Local.Collect <|
                    Collector.TypingHandle
                        ""
            ]
            [ Html.text <|
                String.concat
                    [ "Search creators"
                    ]
            ]
        , Html.text <|
            String.concat
                [ ">"
                , " "
                , handle
                ]
        ]


breadcrumb2 : Collection -> Html Msg
breadcrumb2 collection =
    Html.div
        [ class "is-family-secondary is-light-text-container-6 is-size-6"
        ]
        [ Html.a
            [ class "is-underlined"
            , Local.href <|
                Local.Collect <|
                    Collector.TypingHandle
                        ""
            ]
            [ Html.text <|
                String.concat
                    [ "Search creators"
                    ]
            ]
        , Html.text <|
            String.concat
                [ " "
                , ">"
                , " "
                ]
        , Html.a
            [ class "is-underlined"
            , Local.href <|
                Local.Collect <|
                    Collector.MaybeExistingCreator
                        collection.meta.handle
            ]
            [ Html.text collection.meta.handle
            ]
        , Html.text <|
            String.concat
                [ " "
                , ">"
                , " "
                , String.fromInt collection.meta.index
                ]
        ]


breadcrumb3 : Collection -> Datum -> Html Msg
breadcrumb3 collection datum =
    Html.div
        [ class "is-family-secondary is-light-text-container-6 is-size-6"
        ]
        [ Html.a
            [ class "is-underlined"
            , Local.href <|
                Local.Collect <|
                    Collector.TypingHandle
                        ""
            ]
            [ Html.text <|
                String.concat
                    [ "Search creators"
                    ]
            ]
        , Html.text <|
            String.concat
                [ " "
                , ">"
                , " "
                ]
        , Html.a
            [ class "is-underlined"
            , Local.href <|
                Local.Collect <|
                    Collector.MaybeExistingCreator
                        collection.meta.handle
            ]
            [ Html.text collection.meta.handle
            ]
        , Html.text <|
            String.concat
                [ " "
                , ">"
                , " "
                ]
        , Html.a
            [ class "is-underlined"
            , Local.href <|
                Local.Collect <|
                    Collector.MaybeExistingCollection
                        collection.meta.handle
                        collection.meta.index
            ]
            [ Html.text <| String.fromInt collection.meta.index
            ]
        , Html.text <|
            String.concat
                [ " "
                , ">"
                , " "
                , datum.metadata.title
                ]
        ]
