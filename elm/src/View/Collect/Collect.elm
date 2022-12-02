module View.Collect.Collect exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, placeholder, src, style, type_, width)
import Html.Events exposing (onClick, onInput)
import Model.Collection as Collection
import Model.Collector.Collector as Collector exposing (Collector(..))
import Model.Handle as Handle
import Model.State.Global.Global as Global exposing (Global)
import Model.State.Local.Local as Local
import Msg.Collector.Collector as CollectorMsg
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Collector.Collector



-- TODO; drop global


body : Global -> Collector -> Html Msg
body global collector =
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

                        hiwOrCollections =
                            case global of
                                Global.HasWallet hasWallet ->
                                    Html.div
                                        []
                                        [ View.Generic.Collection.Collector.Collector.viewMany
                                            hasWallet.collected
                                        ]

                                Global.HasWalletAndHandle hasWalletAndHandle ->
                                    Html.div
                                        []
                                        [ View.Generic.Collection.Collector.Collector.viewMany
                                            hasWalletAndHandle.collected
                                        ]

                                _ ->
                                    hiw
                    in
                    Html.div
                        []
                        [ header
                        , Html.div
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
                        , Html.div
                            [ class "my-6"
                            ]
                            []
                        , hiwOrCollections
                        ]

                WaitingForHandleConfirmation ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ header
                        , Html.div
                            [ class "is-loading"
                            ]
                            []
                        ]

                HandleInvalid string ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ header
                        , Html.div
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
                        [ header
                        , Html.div
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

                SelectedCreator intersection withCollections ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ header
                        , Html.div
                            []
                            [ Html.text <|
                                String.concat
                                    [ "creator:"
                                    , " "
                                    , withCollections.handle
                                    ]
                            ]
                        , Html.div
                            []
                            [ Html.text "intersection ⬇️"
                            ]
                        , View.Generic.Collection.Collector.Collector.viewMany
                            intersection
                        , Html.div
                            []
                            [ Html.text "collections ⬇️"
                            ]
                        , View.Generic.Collection.Collector.Collector.viewMany
                            withCollections.collections
                        ]

                SelectedCollection maybeCopiedEdition masterEdition ->
                    let
                        purchase =
                            Html.button
                                [ class "is-button-1"
                                , onClick <|
                                    FromCollector <|
                                        CollectorMsg.PrintCopy
                                            masterEdition.meta.handle
                                            masterEdition.meta.index
                                ]
                                [ Html.text "Purchase"
                                ]

                        purchaseOrMark =
                            case maybeCopiedEdition of
                                Just copiedEdition ->
                                    case Collection.isEmpty copiedEdition of
                                        True ->
                                            Html.div
                                                []
                                                [ Html.div
                                                    []
                                                    [ Html.text
                                                        """You've already purchased this NFT --
                                                        """
                                                    , Html.a
                                                        [ href <|
                                                            String.concat
                                                                [ "https://explorer.solana.com/address/"
                                                                , copiedEdition.accounts.mint
                                                                ]
                                                        ]
                                                        [ Html.text "view it here or in your wallet 👀"
                                                        ]
                                                    ]
                                                , Html.div
                                                    []
                                                    [ Html.text
                                                        """but you still need to mark your copy
                                                        as part of the on-chain collection
                                                        before you can unlock stuff
                                                        """
                                                    ]
                                                , Html.div
                                                    []
                                                    [ Html.button
                                                        [ class "is-button-1"
                                                        , onClick <|
                                                            FromCollector <|
                                                                CollectorMsg.MarkCopy
                                                                    masterEdition.meta.handle
                                                                    masterEdition.meta.index
                                                        ]
                                                        [ Html.text "Mark your copy"
                                                        ]
                                                    ]
                                                ]

                                        False ->
                                            Html.div
                                                []
                                                [ Html.text "unlock stuff"
                                                ]

                                -- TODO; href to secondary market + button to add to collection from secondary
                                Nothing ->
                                    purchase
                    in
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ header
                        , Html.div
                            []
                            [ Html.text <|
                                String.concat
                                    [ "creator:"
                                    , " "
                                    , masterEdition.meta.handle
                                    ]
                            ]
                        , Html.div
                            []
                            [ Html.text "collection selected ⬇️"
                            ]
                        , View.Generic.Collection.Collector.Collector.view
                            masterEdition
                        , purchaseOrMark
                        ]

                PrintedAndMarked collection ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ header
                        , Html.div
                            []
                            [ Html.div
                                []
                                [ Html.text
                                    """You've successfully purchased your NFT &
                                    marked it as part of the official collection
                                    """
                                ]
                            , Html.div
                                []
                                [ Html.a
                                    [ class "is-button-1"
                                    , Local.href <|
                                        Local.Collect <|
                                            Collector.MaybeExistingCollection
                                                collection.meta.handle
                                                collection.meta.index
                                    ]
                                    [ Html.text "go start unlocking stuff 🔓"
                                    ]
                                ]
                            ]
                        , Html.div
                            []
                            [ Html.text <|
                                String.concat
                                    [ "creator:"
                                    , " "
                                    , collection.meta.handle
                                    ]
                            ]
                        , Html.div
                            []
                            [ Html.text "collection selected ⬇️"
                            ]
                        , Html.div
                            []
                            [ View.Generic.Collection.Collector.Collector.view
                                collection
                            ]
                        ]

                MaybeExistingCreator _ ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ header
                        , Html.div
                            [ class "is-loading"
                            ]
                            []
                        ]

                MaybeExistingCollection _ _ ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ header
                        , Html.div
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


header : Html Msg
header =
    Html.div
        [ class "has-head-space has-text-centered"
        ]
        [ Html.h2
            [ class "is-text-container-1 is-size-1 mb-2"
            ]
            [ Html.text "Sell your work."
            ]
        , Html.h2
            [ class "is-text-container-1 is-size-1 mb-5"
            ]
            [ Html.p
                []
                [ Html.text <|
                    String.concat
                        [ "Unlock and"
                        , " "
                        ]
                , Html.strong
                    [ class "is-family-secondary is-italic"
                    ]
                    [ Html.text "own"
                    ]
                , Html.text <|
                    String.concat
                        [ " "
                        , "exclusive content."
                        ]
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
