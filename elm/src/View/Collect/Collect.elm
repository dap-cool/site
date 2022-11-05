module View.Collect.Collect exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, placeholder, style, type_)
import Html.Events exposing (onClick, onInput)
import Model.Collector.Collector exposing (Collector(..))
import Model.Handle as Handle
import Msg.Collector.Collector as CollectorMsg
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Collector.Collector
import View.Generic.Wallet


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
                        , hiw
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

                SelectedCreator withCollections ->
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
                            [ Html.text "collections ⬇️"
                            ]
                        , View.Generic.Collection.Collector.Collector.viewMany
                            withCollections.handle
                            withCollections.collections
                        ]

                SelectedCollection withCollection ->
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
                                    , withCollection.handle
                                    ]
                            ]
                        , Html.div
                            []
                            [ Html.text "collection selected ⬇️"
                            ]
                        , View.Generic.Collection.Collector.Collector.view
                            withCollection.handle
                            withCollection.collection
                        , Html.button
                            [ class "is-button-1"
                            , onClick <|
                                FromCollector <|
                                    CollectorMsg.PurchaseCollection
                                        withCollection.handle
                                        withCollection.collection.index
                            ]
                            [ Html.text "Purchase"
                            ]
                        ]

                WaitingForPurchase ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ header
                        , Html.div
                            [ class "is-loading"
                            ]
                            []
                        ]

                PurchaseSuccess withCollection ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ View.Generic.Wallet.maybeView withCollection.wallet
                        , header
                        , Html.div
                            []
                            [ Html.text <|
                                String.concat
                                    [ "creator:"
                                    , " "
                                    , withCollection.handle
                                    ]
                            ]
                        , Html.div
                            []
                            [ Html.text "collection selected ⬇️"
                            ]
                        , Html.div
                            []
                            [ View.Generic.Collection.Collector.Collector.view
                                withCollection.handle
                                withCollection.collection
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
            [ class "is-text-container-2 is-size-2 has-text-centered mt-6 mb-5"
            , style "height" "100px"
            ]
            [ Html.text "How It Works"
            ]
        , Html.div
            [ class "columns is-mobile my-6"
            , style "height" "150px"
            ]
            [ Html.div
                [ class "column is-5"
                ]
                []
            , Html.div
                [ class "column is-7"
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
            , style "height" "150px"
            ]
            [ Html.div
                [ class "column is-3"
                ]
                []
            , Html.div
                [ class "column is-5"
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
                        [ Html.text "Unlock exclusive content from your"
                        ]
                    , Html.div
                        []
                        [ Html.text "favorite Creators. Take ownership and re-"
                        ]
                    , Html.div
                        []
                        [ Html.text "sell in secondary markets with blockchain."
                        ]
                    ]
                ]
            , Html.div
                [ class "column is-4"
                ]
                []
            ]
        ]
