module View.Header exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model.Collector.Collector as Collector
import Model.Creator.Creator as Creator
import Model.Creator.New.New as NewCreator
import Model.State.Global.Global exposing (Global(..))
import Model.State.Local.Local as Local
import Msg.Creator.Creator as FromCreator
import Msg.Creator.Existing.Existing as FromExisting
import Msg.Global as FromGlobal
import Msg.Msg as Msg exposing (Msg(..))
import String as Wallet


view : Global -> Html Msg
view global =
    Html.nav
        [ class "level is-size-4" -- is-navbar level is-mobile is-size-4
        ]
        [ Html.div
            [ class "level-left ml-5 my-3"
            ]
            [ Html.div
                [ class "level-item"
                ]
                [ Html.h1
                    []
                    [ Html.a
                        [ Local.href <| Local.Collect (Collector.TypingHandle "")
                        ]
                        [ Html.div
                            [ class "is-text-container-4"
                            ]
                            [ Html.text "DAP.COOL"
                            , Html.text "🆒"
                            ]
                        ]
                    ]
                ]
            ]
        , Html.div
            [ class "level-right mr-5 my-3"
            ]
            [ Html.div
                [ class "level-item"
                ]
                [ Html.span
                    [ class "icon-text"
                    ]
                    [ Html.span
                        []
                        [ viewWallet global
                        ]
                    , Html.span
                        [ class "icon"
                        ]
                        [ Html.i
                            [ class "fas fa-user"
                            ]
                            []
                        ]
                    ]
                ]
            , Html.div
                [ class "level-item"
                ]
                [ viewGlobal global
                ]
            ]
        ]


viewWallet : Global -> Html Msg
viewWallet global =
    case global of
        NoWalletYet ->
            Html.button
                [ class "is-light-text-container-4 mr-2"
                , onClick <| Msg.Global FromGlobal.Connect
                ]
                [ Html.text "Connect Wallet"
                ]

        WalletMissing ->
            Html.div
                []
                []

        Connecting ->
            Html.div
                [ class "is-loading-tiny"
                ]
                []

        _ ->
            Html.button
                [ class "is-light-text-container-4 mr-2"
                , onClick <| Msg.Global FromGlobal.Disconnect
                ]
                [ Html.text "Disconnect Wallet"
                ]


viewGlobal : Global -> Html Msg
viewGlobal global =
    case global of
        NoWalletYet ->
            Html.div
                []
                [ Html.text "no-wallet-yet"
                ]

        WalletMissing ->
            Html.div
                []
                [ Html.text "no-wallet-installed"
                ]

        Connecting ->
            Html.div
                [ class "is-loading-tiny"
                ]
                []

        HasWallet hasWallet ->
            Html.div
                []
                [ Html.div
                    []
                    [ Html.text <|
                        String.concat
                            [ "wallet:"
                            , " "
                            , Wallet.trim hasWallet.wallet
                            ]
                    ]
                , Html.div
                    []
                    [ Html.text
                        """no-handle-yet
                        """
                    , Html.div
                        []
                        [ Html.a
                            [ Local.href <| Local.Create (Creator.New NewCreator.Top)
                            , class "has-sky-blue-text"
                            ]
                            [ Html.text "create-handle-now"
                            ]
                        ]
                    ]
                ]

        HasWalletAndHandle hasWalletAndHandle ->
            Html.div
                []
                [ Html.div
                    []
                    [ Html.text <|
                        String.concat
                            [ "wallet:"
                            , " "
                            , Wallet.trim hasWalletAndHandle.wallet
                            ]
                    ]
                , Html.div
                    []
                    [ Html.button
                        [ class "is-button-1"
                        , onClick <|
                            FromCreator <|
                                FromCreator.Existing hasWalletAndHandle <|
                                    FromExisting.ViewAdminPage
                        ]
                        [ Html.text hasWalletAndHandle.handle
                        ]
                    ]
                ]
