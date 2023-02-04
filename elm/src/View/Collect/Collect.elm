module View.Collect.Collect exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (class, href, src, style, target, width)
import Html.Events exposing (onClick)
import Model.Collection as Collection exposing (Collection)
import Model.Collector.Collector as Collector exposing (Collector(..))
import Model.Collector.UnlockedModal exposing (Current, IndexedFile, Total)
import Model.CreatorMetadata exposing (CreatorMetadata)
import Model.Datum exposing (Datum)
import Model.Handle exposing (Handle)
import Model.State.Local.Local as Local
import Model.Wallet as Wallet
import Msg.Collector.Collector as CollectorMsg
import Msg.Msg exposing (Msg(..))
import View.Collect.FeaturedCreator
import View.Generic.Collection.Collector.Collector
import View.Generic.Collection.Header as Header
import View.Generic.Datum.Datum


body : Collector -> Html Msg
body collector =
    let
        html =
            case collector of
                Top collected featuredCreators ->
                    case collected of
                        [] ->
                            Html.div
                                []
                                [ Html.div
                                    [ class "mb-6"
                                    ]
                                    [ Html.div
                                        [ class "mb-3 ml-3"
                                        ]
                                        [ Html.h3
                                            [ class "is-text-container-3 is-size-3 is-family-secondary"
                                            ]
                                            [ Html.text <|
                                                "featured creators"
                                            ]
                                        ]
                                    , Html.div
                                        []
                                        [ View.Collect.FeaturedCreator.view featuredCreators
                                        ]
                                    ]
                                , hiw
                                ]

                        nel ->
                            Html.div
                                []
                                [ Html.div
                                    [ class "mb-6"
                                    ]
                                    [ Html.div
                                        [ class "mb-3 ml-3"
                                        ]
                                        [ Html.h3
                                            [ class "is-text-container-3 is-size-3 is-family-secondary"
                                            ]
                                            [ Html.text <|
                                                "your collection"
                                            ]
                                        ]
                                    , Html.div
                                        []
                                        [ View.Generic.Collection.Collector.Collector.viewMany nel
                                        ]
                                    ]
                                , Html.div
                                    [ class "mb-6"
                                    ]
                                    [ Html.div
                                        [ class "mb-3 ml-3"
                                        ]
                                        [ Html.h3
                                            [ class "is-text-container-3 is-size-3 is-family-secondary"
                                            ]
                                            [ Html.text <|
                                                "featured creators"
                                            ]
                                        ]
                                    , Html.div
                                        []
                                        [ View.Collect.FeaturedCreator.view featuredCreators
                                        ]
                                    ]
                                , Html.div
                                    []
                                    [ hiw
                                    ]
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
                        , Html.div
                            [ class "mt-3"
                            ]
                            [ header total.handle total.metadata
                            ]
                        , ix
                        , rx
                        ]

                SelectedCollection maybeCollected selected uploaded maybeUnlockedModal ->
                    let
                        unlockedModalView =
                            case maybeUnlockedModal of
                                Just unlockedModal ->
                                    let
                                        total : Total
                                        total =
                                            unlockedModal.previous
                                                ++ [ unlockedModal.current ]
                                                ++ unlockedModal.next

                                        previous =
                                            case List.reverse unlockedModal.previous of
                                                head :: _ ->
                                                    Html.div
                                                        []
                                                        [ Html.button
                                                            [ onClick <|
                                                                FromCollector <|
                                                                    CollectorMsg.ViewFile
                                                                        head
                                                                        total
                                                            ]
                                                            [ Html.text
                                                                """previous
                                                                """
                                                            ]
                                                        ]

                                                _ ->
                                                    Html.div
                                                        []
                                                        []

                                        next =
                                            case unlockedModal.next of
                                                head :: _ ->
                                                    Html.div
                                                        []
                                                        [ Html.button
                                                            [ onClick <|
                                                                FromCollector <|
                                                                    CollectorMsg.ViewFile
                                                                        head
                                                                        total
                                                            ]
                                                            [ Html.text
                                                                """next
                                                                """
                                                            ]
                                                        ]

                                                _ ->
                                                    Html.div
                                                        []
                                                        []
                                    in
                                    Html.div
                                        [ class "modal is-active"
                                        ]
                                        [ Html.div
                                            [ class "modal-background"
                                            ]
                                            []
                                        , Html.div
                                            [ class "modal-content"
                                            ]
                                            [ Html.div
                                                [ class "columns is-mobile"
                                                ]
                                                [ Html.div
                                                    [ class "is-modal-button column is-2"
                                                    , style "display" "flex"
                                                    ]
                                                    [ previous
                                                    ]
                                                , Html.div
                                                    [ class "column is-8"
                                                    ]
                                                    [ View.Generic.Datum.Datum.view unlockedModal.current.file
                                                    ]
                                                , Html.div
                                                    [ class "is-modal-button column is-2"
                                                    , style "display" "flex"
                                                    ]
                                                    [ next
                                                    ]
                                                ]
                                            ]
                                        , Html.button
                                            [ class "modal-close is-large"
                                            , onClick <|
                                                FromCollector <|
                                                    CollectorMsg.CloseFile
                                            ]
                                            []
                                        ]

                                Nothing ->
                                    Html.div
                                        []
                                        []

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

                        uploads unlockable =
                            let
                                unlock : Datum -> Html Msg
                                unlock datum =
                                    case ( unlockable, List.length datum.metadata.zip.files == 0 ) of
                                        ( True, True ) ->
                                            Html.div
                                                []
                                                [ Html.button
                                                    [ class "is-button-3"
                                                    , onClick <|
                                                        FromCollector <|
                                                            CollectorMsg.UnlockDatum
                                                                datum
                                                    ]
                                                    [ Html.text "unlock"
                                                    ]
                                                ]

                                        ( True, False ) ->
                                            Html.div
                                                []
                                                [ Html.button
                                                    []
                                                    [ Html.text "download"
                                                    ]
                                                ]

                                        ( False, _ ) ->
                                            Html.div
                                                []
                                                [ Html.text
                                                    """🔒
                                                    """
                                                ]

                                row : Datum -> List (Html Msg)
                                row datum =
                                    let
                                        total : Total
                                        total =
                                            List.indexedMap
                                                (\index file ->
                                                    { index = index, file = file }
                                                )
                                                datum.metadata.zip.files

                                        file_ : Current -> Html Msg
                                        file_ current =
                                            Html.tr
                                                []
                                                [ Html.td
                                                    []
                                                    []
                                                , Html.td
                                                    []
                                                    [ Html.div
                                                        [ class "is-light-text-container-5 is-size-5"
                                                        ]
                                                        [ Html.text <|
                                                            current.file.type_
                                                        ]
                                                    ]
                                                , Html.td
                                                    []
                                                    []
                                                , Html.td
                                                    []
                                                    [ Html.div
                                                        []
                                                        [ Html.button
                                                            [ onClick <|
                                                                FromCollector <|
                                                                    CollectorMsg.ViewFile
                                                                        current
                                                                        total
                                                            ]
                                                            [ Html.text
                                                                """view
                                                                """
                                                            ]
                                                        ]
                                                    ]
                                                ]

                                        files : List (Html Msg)
                                        files =
                                            List.map
                                                file_
                                                total
                                    in
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
                                                [ class "is-light-text-container-5 is-size-5"
                                                ]
                                                [ Html.text <|
                                                    String.fromInt datum.metadata.zip.count
                                                ]
                                            ]
                                        , Html.td
                                            []
                                            [ Html.div
                                                [ class "is-light-text-container-5 is-size-5"
                                                ]
                                                [ Html.text <|
                                                    String.fromInt datum.metadata.timestamp
                                                ]
                                            ]
                                        , Html.td
                                            []
                                            [ Html.div
                                                []
                                                [ unlock datum
                                                ]
                                            ]
                                        ]
                                        :: files

                                rows : Html Msg
                                rows =
                                    Html.tbody
                                        []
                                    <|
                                        List.concatMap
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
                                                [ class "is-light-text-container-6 is-size-6 is-family-secondary"
                                                , style "opacity" "50%"
                                                ]
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
                                                [ class "is-light-text-container-6 is-size-6 is-family-secondary"
                                                , style "opacity" "50%"
                                                ]
                                                [ Html.text
                                                    """Files
                                                    """
                                                ]
                                            , Html.th
                                                [ class "is-light-text-container-6 is-size-6 is-family-secondary"
                                                , style "opacity" "50%"
                                                ]
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
                                            [ class "columns"
                                            ]
                                            [ Html.div
                                                [ class "column is-half"
                                                ]
                                                [ View.Generic.Collection.Collector.Collector.view selected
                                                , Html.div
                                                    [ class "mt-2 px-3 py-3"
                                                    ]
                                                    [ Html.div
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
                                                                        []
                                                                    ]
                                                                ]
                                                            , Html.tbody
                                                                []
                                                                [ Html.tr
                                                                    []
                                                                    [ Html.th
                                                                        [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile is-family-secondary"
                                                                        , style "opacity" "50%"
                                                                        ]
                                                                        [ Html.text
                                                                            """\u{1FA99} token
                                                                            """
                                                                        ]
                                                                    , Html.td
                                                                        [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                        , style "opacity" "50%"
                                                                        ]
                                                                        [ Html.a
                                                                            [ class "has-sky-blue-text"
                                                                            , href <|
                                                                                String.concat
                                                                                    [ "https://solscan.io/token/"
                                                                                    , selected.accounts.mint
                                                                                    ]
                                                                            , target "_blank"
                                                                            ]
                                                                            [ Html.text <|
                                                                                Wallet.slice selected.accounts.mint
                                                                            ]
                                                                        ]
                                                                    ]
                                                                , Html.tr
                                                                    []
                                                                    [ Html.th
                                                                        [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile is-family-secondary"
                                                                        , style "opacity" "50%"
                                                                        ]
                                                                        [ Html.text
                                                                            """💰 token balance
                                                                            """
                                                                        ]
                                                                    , Html.td
                                                                        [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                        , style "opacity" "50%"
                                                                        ]
                                                                        [ Html.text <|
                                                                            String.fromInt selected.accounts.ata.balance
                                                                        ]
                                                                    ]
                                                                , Html.tr
                                                                    []
                                                                    [ Html.th
                                                                        [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile is-family-secondary"
                                                                        , style "opacity" "50%"
                                                                        ]
                                                                        [ Html.text
                                                                            """💳 secondary market
                                                                            """
                                                                        ]
                                                                    , Html.td
                                                                        [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                        , style "opacity" "50%"
                                                                        ]
                                                                        [ Html.a
                                                                            [ class "has-sky-blue-text"
                                                                            , href <|
                                                                                String.concat
                                                                                    [ "https://hyperspace.xyz/token/"
                                                                                    , selected.accounts.mint
                                                                                    ]
                                                                            , target "_blank"
                                                                            ]
                                                                            [ Html.text "hyperspace.xyz"
                                                                            ]
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        ]
                                                    ]
                                                , Html.div
                                                    [ class "mt-2"
                                                    ]
                                                    [ purchase
                                                    ]
                                                ]
                                            , Html.div
                                                [ class "column is-half"
                                                ]
                                                [ Html.div
                                                    []
                                                    [ uploads False
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
                                                    [ class "columns"
                                                    ]
                                                    [ Html.div
                                                        [ class "column is-half"
                                                        ]
                                                        [ View.Generic.Collection.Collector.Collector.view selected
                                                        , Html.div
                                                            [ class "mt-2 px-3 py-3"
                                                            ]
                                                            [ Html.div
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
                                                                                []
                                                                            ]
                                                                        ]
                                                                    , Html.tbody
                                                                        []
                                                                        [ Html.tr
                                                                            []
                                                                            [ Html.th
                                                                                [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile is-family-secondary"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.text
                                                                                    """\u{1FA99} token
                                                                                    """
                                                                                ]
                                                                            , Html.td
                                                                                [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.a
                                                                                    [ class "has-sky-blue-text"
                                                                                    , href <|
                                                                                        String.concat
                                                                                            [ "https://solscan.io/token/"
                                                                                            , selected.accounts.mint
                                                                                            ]
                                                                                    , target "_blank"
                                                                                    ]
                                                                                    [ Html.text <|
                                                                                        Wallet.slice selected.accounts.mint
                                                                                    ]
                                                                                ]
                                                                            ]
                                                                        , Html.tr
                                                                            []
                                                                            [ Html.th
                                                                                [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile is-family-secondary"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.text
                                                                                    """💰 token balance
                                                                                    """
                                                                                ]
                                                                            , Html.td
                                                                                [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.a
                                                                                    [ class "has-sky-blue-text"
                                                                                    , href <|
                                                                                        String.concat
                                                                                            [ "https://solscan.io/account/"
                                                                                            , selected.accounts.ata.address
                                                                                            ]
                                                                                    , target "_blank"
                                                                                    ]
                                                                                    [ Html.text <|
                                                                                        String.fromInt selected.accounts.ata.balance
                                                                                    ]
                                                                                ]
                                                                            ]
                                                                        , Html.tr
                                                                            []
                                                                            [ Html.th
                                                                                [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile is-family-secondary"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.text
                                                                                    """🛄 keys to unlock stuff
                                                                                    """
                                                                                ]
                                                                            , Html.td
                                                                                [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.button
                                                                                    [ class "is-button-2"
                                                                                    ]
                                                                                    [ Html.text "claim"
                                                                                    ]
                                                                                ]
                                                                            ]
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        ]
                                                    , Html.div
                                                        [ class "column is-half"
                                                        ]
                                                        [ Html.div
                                                            []
                                                            [ uploads False
                                                            ]
                                                        ]
                                                    ]
                                                ]

                                        ( Collector.No, Collector.Zero ) ->
                                            Html.div
                                                []
                                                [ Html.div
                                                    [ class "columns"
                                                    ]
                                                    [ Html.div
                                                        [ class "column is-half"
                                                        ]
                                                        [ View.Generic.Collection.Collector.Collector.view selected
                                                        , Html.div
                                                            [ class "mt-2 px-3 py-3"
                                                            ]
                                                            [ Html.div
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
                                                                                []
                                                                            ]
                                                                        ]
                                                                    , Html.tbody
                                                                        []
                                                                        [ Html.tr
                                                                            []
                                                                            [ Html.th
                                                                                [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile is-family-secondary"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.text
                                                                                    """\u{1FA99} token
                                                                                    """
                                                                                ]
                                                                            , Html.td
                                                                                [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.a
                                                                                    [ class "has-sky-blue-text"
                                                                                    , href <|
                                                                                        String.concat
                                                                                            [ "https://solscan.io/token/"
                                                                                            , selected.accounts.mint
                                                                                            ]
                                                                                    , target "_blank"
                                                                                    ]
                                                                                    [ Html.text <|
                                                                                        Wallet.slice selected.accounts.mint
                                                                                    ]
                                                                                ]
                                                                            ]
                                                                        , Html.tr
                                                                            []
                                                                            [ Html.th
                                                                                [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile is-family-secondary"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.text
                                                                                    """💰 token balance
                                                                                    """
                                                                                ]
                                                                            , Html.td
                                                                                [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.a
                                                                                    [ class "has-sky-blue-text"
                                                                                    , href <|
                                                                                        String.concat
                                                                                            [ "https://solscan.io/account/"
                                                                                            , selected.accounts.ata.address
                                                                                            ]
                                                                                    , target "_blank"
                                                                                    ]
                                                                                    [ Html.text <|
                                                                                        String.fromInt selected.accounts.ata.balance
                                                                                    ]
                                                                                ]
                                                                            ]
                                                                        , Html.tr
                                                                            []
                                                                            [ Html.th
                                                                                [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile is-family-secondary"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.text
                                                                                    """💳 secondary market
                                                                                    """
                                                                                ]
                                                                            , Html.td
                                                                                [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.a
                                                                                    [ class "has-sky-blue-text"
                                                                                    , href <|
                                                                                        String.concat
                                                                                            [ "https://hyperspace.xyz/token/"
                                                                                            , selected.accounts.mint
                                                                                            ]
                                                                                    , target "_blank"
                                                                                    ]
                                                                                    [ Html.text "hyperspace.xyz"
                                                                                    ]
                                                                                ]
                                                                            ]
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        , Html.div
                                                            [ class "mt-2"
                                                            ]
                                                            [ purchase
                                                            ]
                                                        ]
                                                    , Html.div
                                                        [ class "column is-half"
                                                        ]
                                                        [ uploads False
                                                        ]
                                                    ]
                                                ]

                                        ( Collector.Yes collected, _ ) ->
                                            Html.div
                                                []
                                                [ Html.div
                                                    [ class "columns"
                                                    ]
                                                    [ Html.div
                                                        [ class "column is-half"
                                                        ]
                                                        [ View.Generic.Collection.Collector.Collector.view selected
                                                        , Html.div
                                                            [ class "mt-2 px-3 py-3"
                                                            ]
                                                            [ Html.div
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
                                                                                []
                                                                            ]
                                                                        ]
                                                                    , Html.tbody
                                                                        []
                                                                        [ Html.tr
                                                                            []
                                                                            [ Html.th
                                                                                [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile is-family-secondary"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.text
                                                                                    """\u{1FA99} token
                                                                                    """
                                                                                ]
                                                                            , Html.td
                                                                                [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.a
                                                                                    [ class "has-sky-blue-text"
                                                                                    , href <|
                                                                                        String.concat
                                                                                            [ "https://solscan.io/token/"
                                                                                            , collected.accounts.mint
                                                                                            ]
                                                                                    , target "_blank"
                                                                                    ]
                                                                                    [ Html.text <|
                                                                                        Wallet.slice collected.accounts.mint
                                                                                    ]
                                                                                ]
                                                                            ]
                                                                        , Html.tr
                                                                            []
                                                                            [ Html.th
                                                                                [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile is-family-secondary"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.text
                                                                                    """💰 token balance
                                                                                    """
                                                                                ]
                                                                            , Html.td
                                                                                [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.a
                                                                                    [ class "has-sky-blue-text"
                                                                                    , href <|
                                                                                        String.concat
                                                                                            [ "https://solscan.io/account/"
                                                                                            , collected.accounts.ata.address
                                                                                            ]
                                                                                    , target "_blank"
                                                                                    ]
                                                                                    [ Html.text <|
                                                                                        String.fromInt collected.accounts.ata.balance
                                                                                    ]
                                                                                ]
                                                                            ]
                                                                        , Html.tr
                                                                            []
                                                                            [ Html.th
                                                                                [ class "is-light-text-container-5 is-size-5 is-light-text-container-6-mobile is-size-6-mobile is-family-secondary"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.text
                                                                                    """💳 secondary market
                                                                                    """
                                                                                ]
                                                                            , Html.td
                                                                                [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                                , style "opacity" "50%"
                                                                                ]
                                                                                [ Html.a
                                                                                    [ class "has-sky-blue-text"
                                                                                    , href <|
                                                                                        String.concat
                                                                                            [ "https://hyperspace.xyz/token/"
                                                                                            , collected.accounts.mint
                                                                                            ]
                                                                                    , target "_blank"
                                                                                    ]
                                                                                    [ Html.text "hyperspace.xyz"
                                                                                    ]
                                                                                ]
                                                                            ]
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        , Html.div
                                                            [ class "mt-2"
                                                            ]
                                                            [ purchaseAgain
                                                            ]
                                                        ]
                                                    , Html.div
                                                        [ class "column is-half"
                                                        ]
                                                        [ Html.div
                                                            []
                                                            [ uploads True
                                                            ]
                                                        ]
                                                    ]
                                                ]
                    in
                    Html.div
                        []
                        [ breadcrumb2 selected
                        , Html.div
                            [ class "mt-3"
                            ]
                            [ header0 selected.meta.handle
                            ]
                        , unlockedModalView
                        , Html.div
                            [ class "mt-6"
                            ]
                            [ view_
                            ]
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


header : Handle -> CreatorMetadata -> Html Msg
header handle metadata =
    Header.view Header.Collector handle metadata


header0 : Handle -> Html Msg
header0 handle =
    Header.header0 Header.Collector handle


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
            [ class "columns mb-6 mx-3"
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
            [ class "columns mt-6 mb-3 mx-3"
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
                    Collector.Top [] []
            ]
            [ Html.text <|
                String.concat
                    [ "my collection"
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
                    Collector.Top [] []
            ]
            [ Html.text <|
                String.concat
                    [ "my collection"
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
