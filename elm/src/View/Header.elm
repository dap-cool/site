module View.Header exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Model.Collector.Collector as Collector
import Model.Creator.Creator as Creator
import Model.Creator.New.New as NewCreator
import Model.State.Global.Global exposing (Global(..))
import Model.State.Local.Local as Local
import Model.Wallet as Wallet
import Msg.Global as FromGlobal
import Msg.Msg as Msg exposing (Msg(..))


view : Global -> Html Msg
view global =
    Html.nav
        [ class "level has-text-centered is-size-4" -- is-navbar level is-mobile is-size-4
        ]
        [ Html.div
            [ class "level-left mx-5 my-3"
            ]
            [ Html.div
                [ class "level-item"
                ]
                [ Html.h1
                    []
                    [ Html.a
                        [ Local.href <| Local.Collect (Collector.Top [])
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
            [ class "level-right mx-5 my-3"
            ]
            [ Html.div
                [ class "level-item mx-5"
                ]
                [ Html.span
                    [ class "icon-text"
                    ]
                    [ Html.span
                        []
                        [ viewGlobal global
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
                [ viewWallet global
                ]
            ]
        ]


viewWallet : Global -> Html Msg
viewWallet global =
    case global of
        NoWalletYet ->
            Html.button
                [ class "is-button-2 is-light-text-container-4"
                , onClick <| Msg.Global FromGlobal.Connect
                ]
                [ Html.text "Connect Wallet"
                ]

        WalletMissing ->
            Html.div
                []
                []

        HasWallet hasWallet ->
            Html.div
                []
                [ Html.div
                    []
                    [ Html.button
                        [ class "is-button-2 is-light-text-container-4"
                        , onClick <| Msg.Global FromGlobal.Disconnect
                        ]
                        [ Html.text "Disconnect Wallet"
                        ]
                    ]
                , Html.div
                    [ class "is-light-text-container-5 is-family-secondary is-size-5 mt-2"
                    ]
                    [ Html.text <|
                        Wallet.slice hasWallet.wallet
                    ]
                ]

        HasWalletAndHandle hasWalletAndHandle ->
            Html.div
                []
                [ Html.div
                    []
                    [ Html.button
                        [ class "is-button-2 is-light-text-container-4"
                        , onClick <| Msg.Global FromGlobal.Disconnect
                        ]
                        [ Html.text "Disconnect Wallet"
                        ]
                    ]
                , Html.div
                    [ class "is-light-text-container-5 is-family-secondary is-size-5 mt-2"
                    ]
                    [ Html.text <|
                        Wallet.slice hasWalletAndHandle.wallet
                    ]
                ]


viewGlobal : Global -> Html Msg
viewGlobal global =
    case global of
        NoWalletYet ->
            Html.div
                []
                []

        WalletMissing ->
            Html.div
                []
                [ Html.text "no-wallet-installed"
                ]

        HasWallet _ ->
            Html.div
                [ class "is-text-container-5 is-size-5 is-family-secondary"
                ]
                [ Html.a
                    [ Local.href <| Local.Create (Creator.New NewCreator.Top)
                    ]
                    [ Html.text "start uploading 💹"
                    ]
                ]

        HasWalletAndHandle hasWalletAndHandle ->
            Html.div
                [ class "is-text-container-5 is-size-5 is-family-secondary"
                ]
                [ Html.a
                    [ Local.href <| Local.Create (Creator.New NewCreator.Top)
                    ]
                    [ Html.text hasWalletAndHandle.handle
                    ]
                ]
