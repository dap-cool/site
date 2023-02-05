module View.Create.Create exposing (body)

import FormatNumber
import FormatNumber.Locales exposing (usLocale)
import Html exposing (Html)
import Html.Attributes exposing (accept, class, default, disabled, href, id, multiple, placeholder, src, step, style, target, type_, value, width)
import Html.Events exposing (onClick, onInput)
import Model.Collection
import Model.Collector.Collector as Collector
import Model.Collector.UnlockedModal exposing (Current, Total)
import Model.Creator.Creator exposing (Creator(..))
import Model.Creator.Existing.BioForm as BioForm exposing (BioForm)
import Model.Creator.Existing.Existing as Existing
import Model.Creator.Existing.LogoForm as LogoForm exposing (LogoForm)
import Model.Creator.Existing.NewCollection as NewCollection
import Model.Creator.New.New as New
import Model.CreatorMetadata as CreatorMetadata exposing (CreatorMetadata)
import Model.Datum exposing (Datum)
import Model.Handle as Handle
import Model.State.Global.HasWalletAndHandle exposing (HasWalletAndHandle)
import Model.State.Local.Local as Local
import Model.Wallet as Wallet
import Msg.Creator.Creator as CreatorMsg
import Msg.Creator.Existing.Existing as ExistingMsg
import Msg.Creator.Existing.NewCollectionForm as NewCollectionForm
import Msg.Creator.New.New as NewMsg
import Msg.Global as FromGlobal
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Creator.Creator
import View.Generic.Collection.Header as Header


body : Creator -> Html Msg
body creator =
    let
        html =
            case creator of
                New newCreator ->
                    case newCreator of
                        New.Top ->
                            Html.div
                                []
                                [ header
                                , Html.div
                                    [ class "mt-6"
                                    ]
                                    [ Html.input
                                        [ class "input"
                                        , type_ "text"
                                        , placeholder "Handle @@@"
                                        , onInput <|
                                            \s ->
                                                FromCreator <|
                                                    CreatorMsg.New <|
                                                        NewMsg.HandleForm <|
                                                            Handle.Typing s
                                        ]
                                        []
                                    ]
                                ]

                        New.TypingHandle string ->
                            let
                                select =
                                    case string of
                                        "" ->
                                            Html.div
                                                []
                                                []

                                        _ ->
                                            Html.div
                                                [ class "mt-3"
                                                ]
                                                [ Html.button
                                                    [ class "is-button-1"
                                                    , onClick <|
                                                        FromCreator <|
                                                            CreatorMsg.New <|
                                                                NewMsg.HandleForm <|
                                                                    Handle.Confirm string
                                                    ]
                                                    [ Html.b
                                                        [ class "is-text-container-4 is-size-4 is-text-container-5-mobile is-size-5-mobile"
                                                        ]
                                                        [ Html.text <|
                                                            String.concat
                                                                [ "mint new handle"
                                                                , " "
                                                                ]
                                                        ]
                                                    , Html.i
                                                        [ class "is-text-container-4 is-size-4 is-text-container-5-mobile is-size-5-mobile is-family-secondary"
                                                        ]
                                                        [ Html.text string
                                                        ]
                                                    ]
                                                ]
                            in
                            Html.div
                                []
                                [ header
                                , Html.div
                                    [ class "mt-6"
                                    ]
                                    [ Html.input
                                        [ class "input"
                                        , type_ "text"
                                        , placeholder "Handle @@@"
                                        , onInput <|
                                            \s ->
                                                FromCreator <|
                                                    CreatorMsg.New <|
                                                        NewMsg.HandleForm <|
                                                            Handle.Typing s
                                        ]
                                        []
                                    ]
                                , select
                                ]

                        New.HandleInvalid string ->
                            Html.div
                                []
                                [ header
                                , Html.div
                                    [ class "mt-6"
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
                                                FromCreator <|
                                                    CreatorMsg.New <|
                                                        NewMsg.HandleForm <|
                                                            Handle.Typing ""
                                            ]
                                            [ Html.text
                                                """try again
                                                """
                                            ]
                                        ]
                                    ]
                                ]

                        New.HandleAlreadyExists string ->
                            Html.div
                                []
                                [ header
                                , Html.div
                                    [ class "mt-6"
                                    ]
                                    [ Html.text <|
                                        String.concat
                                            [ "input handle already exists:"
                                            , " "
                                            , string
                                            ]
                                    , Html.div
                                        [ class "pt-1"
                                        ]
                                        [ Html.button
                                            [ class "is-button-1"
                                            , onClick <|
                                                FromCreator <|
                                                    CreatorMsg.New <|
                                                        NewMsg.HandleForm <|
                                                            Handle.Typing ""
                                            ]
                                            [ Html.text
                                                """try again
                                                """
                                            ]
                                        ]
                                    ]
                                ]

                Existing fromGlobal existingCreator ->
                    case existingCreator of
                        Existing.Top logoForm bioForm ->
                            let
                                shadowAta =
                                    case fromGlobal.metadata of
                                        CreatorMetadata.Initialized metadata ->
                                            metadata.shadowAta

                                        CreatorMetadata.UnInitialized shadowAta_ ->
                                            shadowAta_

                                createNewCollection =
                                    let
                                        normalized =
                                            Basics.toFloat shadowAta.balance / 1000000000

                                        formatted =
                                            FormatNumber.format usLocale normalized
                                    in
                                    case ( normalized > 0.25, shadowAta.address ) of
                                        ( True, Just address ) ->
                                            Html.div
                                                []
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
                                                                    [ class "is-text-container-5 is-size-5"
                                                                    ]
                                                                    [ Html.text "storage-token-balance"
                                                                    ]
                                                                , Html.td
                                                                    [ class "is-text-container-5 is-size-5"
                                                                    ]
                                                                    [ Html.a
                                                                        [ class "has-sky-blue-text"
                                                                        , href <|
                                                                            String.concat
                                                                                [ "https://solscan.io/account/"
                                                                                , address
                                                                                ]
                                                                        , target "_blank"
                                                                        ]
                                                                        [ Html.text formatted
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        ]
                                                    ]
                                                , Html.div
                                                    []
                                                    [ Html.button
                                                        [ class "is-button-1"
                                                        , onClick <|
                                                            FromCreator <|
                                                                CreatorMsg.Existing fromGlobal <|
                                                                    ExistingMsg.StartCreatingNewCollection
                                                        ]
                                                        [ Html.text "create new collection"
                                                        ]
                                                    ]
                                                ]

                                        ( False, Just address ) ->
                                            Html.div
                                                []
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
                                                                    [ class "is-text-container-5 is-size-5"
                                                                    ]
                                                                    [ Html.text "insufficient storage-token-balance"
                                                                    ]
                                                                , Html.td
                                                                    [ class "is-text-container-5 is-size-5"
                                                                    ]
                                                                    [ Html.a
                                                                        [ class "has-sky-blue-text"
                                                                        , href <|
                                                                            String.concat
                                                                                [ "https://solscan.io/account/"
                                                                                , address
                                                                                ]
                                                                        , target "_blank"
                                                                        ]
                                                                        [ Html.text formatted
                                                                        ]
                                                                    , Html.b
                                                                        [ class "is-text-container-5 is-size-5"
                                                                        ]
                                                                        [ Html.text <|
                                                                            String.concat
                                                                                [ " "
                                                                                , "<"
                                                                                , " "
                                                                                , "0.25"
                                                                                ]
                                                                        ]
                                                                    ]
                                                                ]
                                                            , Html.tr
                                                                []
                                                                [ Html.td
                                                                    [ class "is-text-container-5 is-size-5"
                                                                    ]
                                                                    [ Html.a
                                                                        [ class "has-sky-blue-text"
                                                                        , href "https://jup.ag/swap/SOL-SHDW"
                                                                        , target "_blank"
                                                                        ]
                                                                        [ Html.text "swap sol for storage-token"
                                                                        ]
                                                                    ]
                                                                , Html.td
                                                                    [ class "is-text-container-5 is-size-5"
                                                                    ]
                                                                    [ Html.button
                                                                        [ onClick <|
                                                                            Global <|
                                                                                FromGlobal.Connect
                                                                        ]
                                                                        [ Html.text "refresh"
                                                                        ]
                                                                    ]
                                                                ]
                                                            , Html.tr
                                                                []
                                                                [ Html.th
                                                                    [ class "is-text-container-5 is-size-5"
                                                                    ]
                                                                    [ Html.text "new-collection"
                                                                    ]
                                                                , Html.td
                                                                    [ class "is-text-container-5 is-size-5"
                                                                    ]
                                                                    [ Html.button
                                                                        [ onClick <|
                                                                            FromCreator <|
                                                                                CreatorMsg.Existing fromGlobal <|
                                                                                    ExistingMsg.StartCreatingNewCollection
                                                                        , disabled True
                                                                        ]
                                                                        [ Html.text "create"
                                                                        ]
                                                                    ]
                                                                ]
                                                            ]
                                                        ]
                                                    ]
                                                ]

                                        _ ->
                                            Html.div
                                                []
                                                []
                            in
                            Html.div
                                []
                                [ Html.div
                                    [ class "mb-6"
                                    ]
                                    [ header2 logoForm bioForm fromGlobal
                                    ]
                                , Html.div
                                    [ class "mb-6"
                                    ]
                                    [ createNewCollection
                                    ]
                                , Html.div
                                    []
                                    [ Html.div
                                        [ class "mb-3 is-text-container-3 is-size-3 is-text-container-4-mobile is-size-4-mobile"
                                        ]
                                        [ Html.text "Your collections ⬇️"
                                        ]
                                    , View.Generic.Collection.Creator.Creator.viewMany
                                        fromGlobal
                                        fromGlobal.collections
                                    ]
                                ]

                        Existing.CreatingNewCollection newCollection ->
                            case newCollection of
                                NewCollection.Input submitted ->
                                    let
                                        imageForm =
                                            case submitted of
                                                NewCollection.Yes form ->
                                                    Html.div
                                                        []
                                                        [ Html.img
                                                            [ src form.meta.logo.base64
                                                            , width 500
                                                            ]
                                                            []
                                                        ]

                                                NewCollection.No maybeMetaForm ->
                                                    let
                                                        selector name =
                                                            Html.div
                                                                [ class "file has-name"
                                                                ]
                                                                [ Html.label
                                                                    [ class "file-label"
                                                                    ]
                                                                    [ Html.input
                                                                        [ id "dap-cool-collection-logo-selector"
                                                                        , class "file-input"
                                                                        , type_ "file"
                                                                        , accept <|
                                                                            String.join
                                                                                ", "
                                                                                [ ".jpg"
                                                                                , ".jpeg"
                                                                                , ".png"
                                                                                ]
                                                                        , onClick <|
                                                                            FromCreator <|
                                                                                CreatorMsg.Existing fromGlobal <|
                                                                                    ExistingMsg.NewCollectionForm
                                                                                        NewCollectionForm.Image
                                                                        ]
                                                                        []
                                                                    , Html.span
                                                                        [ class "file-cta"
                                                                        ]
                                                                        [ Html.span
                                                                            [ class "file-icon"
                                                                            ]
                                                                            [ Html.i
                                                                                [ class "fas fa-upload"
                                                                                ]
                                                                                []
                                                                            ]
                                                                        , Html.span
                                                                            [ class "file-label"
                                                                            ]
                                                                            [ Html.text "Select a logo for your new coin . . ."
                                                                            ]
                                                                        ]
                                                                    , Html.span
                                                                        [ class "file-name"
                                                                        ]
                                                                        [ Html.text name
                                                                        ]
                                                                    ]
                                                                ]

                                                        ( logoImg, logoName ) =
                                                            case maybeMetaForm.logo of
                                                                Just logo ->
                                                                    ( Html.div
                                                                        []
                                                                        [ Html.img
                                                                            [ src logo.base64
                                                                            , width 500
                                                                            ]
                                                                            []
                                                                        ]
                                                                    , logo.name
                                                                    )

                                                                Nothing ->
                                                                    ( Html.div
                                                                        []
                                                                        [ Html.img
                                                                            [ src "images/upload/default-pfp.jpg"
                                                                            , width 500
                                                                            ]
                                                                            []
                                                                        ]
                                                                    , "Waiting . . ."
                                                                    )
                                                    in
                                                    Html.div
                                                        []
                                                        [ Html.div
                                                            [ class "mb-3"
                                                            ]
                                                            [ selector logoName
                                                            ]
                                                        , logoImg
                                                        ]

                                        inputted : Maybe a -> (a -> String) -> Html Msg
                                        inputted maybeA toString =
                                            case maybeA of
                                                Just a ->
                                                    Html.div
                                                        [ class "mt-1 mb-3 is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                        ]
                                                        [ Html.text <|
                                                            toString a
                                                        ]

                                                Nothing ->
                                                    Html.div
                                                        []
                                                        []

                                        nameForm =
                                            case submitted of
                                                NewCollection.Yes _ ->
                                                    Html.div
                                                        []
                                                        []

                                                NewCollection.No form ->
                                                    Html.div
                                                        []
                                                        [ Html.div
                                                            [ class "field"
                                                            ]
                                                            [ Html.p
                                                                [ class "control has-icons-left"
                                                                ]
                                                                [ Html.input
                                                                    [ class "input"
                                                                    , type_ "text"
                                                                    , placeholder "Name your new collection"
                                                                    , onInput <|
                                                                        \s ->
                                                                            FromCreator <|
                                                                                CreatorMsg.Existing fromGlobal <|
                                                                                    ExistingMsg.NewCollectionForm <|
                                                                                        NewCollectionForm.Name s form
                                                                    ]
                                                                    []
                                                                , Html.span
                                                                    [ class "icon is-left"
                                                                    ]
                                                                    [ Html.i
                                                                        [ class "fas fa-file-signature"
                                                                        ]
                                                                        []
                                                                    ]
                                                                ]
                                                            ]
                                                        , inputted form.name identity
                                                        ]

                                        symbolFrom =
                                            case submitted of
                                                NewCollection.Yes _ ->
                                                    Html.div
                                                        []
                                                        []

                                                NewCollection.No form ->
                                                    Html.div
                                                        []
                                                        [ Html.div
                                                            [ class "field"
                                                            ]
                                                            [ Html.p
                                                                [ class "control has-icons-left"
                                                                ]
                                                                [ Html.input
                                                                    [ class "input"
                                                                    , type_ "text"
                                                                    , placeholder "Symbol"
                                                                    , onInput <|
                                                                        \s ->
                                                                            FromCreator <|
                                                                                CreatorMsg.Existing fromGlobal <|
                                                                                    ExistingMsg.NewCollectionForm <|
                                                                                        NewCollectionForm.Symbol
                                                                                            (String.toUpper s)
                                                                                            form
                                                                    ]
                                                                    []
                                                                , Html.span
                                                                    [ class "icon is-left"
                                                                    ]
                                                                    [ Html.i
                                                                        [ class "fas fa-file-signature"
                                                                        ]
                                                                        []
                                                                    ]
                                                                ]
                                                            ]
                                                        , inputted form.symbol identity
                                                        ]

                                        tsForm =
                                            case submitted of
                                                NewCollection.Yes _ ->
                                                    Html.div
                                                        []
                                                        []

                                                NewCollection.No form ->
                                                    Html.div
                                                        []
                                                        [ Html.div
                                                            [ class "field"
                                                            ]
                                                            [ Html.p
                                                                [ class "control has-icons-left"
                                                                ]
                                                                [ Html.input
                                                                    [ class "input"
                                                                    , type_ "number"
                                                                    , placeholder "Total supply"
                                                                    , onInput <|
                                                                        \s ->
                                                                            FromCreator <|
                                                                                CreatorMsg.Existing fromGlobal <|
                                                                                    ExistingMsg.NewCollectionForm <|
                                                                                        NewCollectionForm.TotalSupply
                                                                                            (String.toUpper s)
                                                                                            form
                                                                    ]
                                                                    []
                                                                , Html.span
                                                                    [ class "icon is-left"
                                                                    ]
                                                                    [ Html.i
                                                                        [ class "fas fa-file-signature"
                                                                        ]
                                                                        []
                                                                    ]
                                                                ]
                                                            ]
                                                        , inputted
                                                            form.totalSupply
                                                            (\int -> FormatNumber.format usLocale (Basics.toFloat int))
                                                        ]

                                        cdForm =
                                            case submitted of
                                                NewCollection.Yes _ ->
                                                    Html.div
                                                        []
                                                        []

                                                NewCollection.No form ->
                                                    Html.div
                                                        []
                                                        [ Html.div
                                                            [ class "field"
                                                            ]
                                                            [ Html.p
                                                                [ class "control has-icons-left"
                                                                ]
                                                                [ Html.input
                                                                    [ class "input"
                                                                    , type_ "number"
                                                                    , placeholder "How many to mint to yourself?"
                                                                    , onInput <|
                                                                        \s ->
                                                                            FromCreator <|
                                                                                CreatorMsg.Existing fromGlobal <|
                                                                                    ExistingMsg.NewCollectionForm <|
                                                                                        NewCollectionForm.CreatorDistribution
                                                                                            (String.toUpper s)
                                                                                            form
                                                                    ]
                                                                    []
                                                                , Html.span
                                                                    [ class "icon is-left"
                                                                    ]
                                                                    [ Html.i
                                                                        [ class "fas fa-file-signature"
                                                                        ]
                                                                        []
                                                                    ]
                                                                ]
                                                            ]
                                                        , inputted
                                                            form.creatorDistribution
                                                            (\int -> FormatNumber.format usLocale (Basics.toFloat int))
                                                        ]

                                        priceForm =
                                            case submitted of
                                                NewCollection.Yes _ ->
                                                    Html.div
                                                        []
                                                        []

                                                NewCollection.No form ->
                                                    Html.div
                                                        []
                                                        [ Html.div
                                                            [ class "field"
                                                            ]
                                                            [ Html.p
                                                                [ class "control has-icons-left"
                                                                ]
                                                                [ Html.input
                                                                    [ class "input"
                                                                    , type_ "number"
                                                                    , placeholder "Price"
                                                                    , step "0.01"
                                                                    , onInput <|
                                                                        \s ->
                                                                            FromCreator <|
                                                                                CreatorMsg.Existing fromGlobal <|
                                                                                    ExistingMsg.NewCollectionForm <|
                                                                                        NewCollectionForm.Price
                                                                                            (String.toUpper s)
                                                                                            form
                                                                    ]
                                                                    []
                                                                , Html.span
                                                                    [ class "icon is-left"
                                                                    ]
                                                                    [ Html.i
                                                                        [ class "fas fa-file-signature"
                                                                        ]
                                                                        []
                                                                    ]
                                                                ]
                                                            ]
                                                        , inputted
                                                            form.price
                                                            (\f ->
                                                                String.concat
                                                                    [ "$"
                                                                    , FormatNumber.format usLocale f
                                                                    ]
                                                            )
                                                        ]

                                        feeForm =
                                            case submitted of
                                                NewCollection.Yes _ ->
                                                    Html.div
                                                        []
                                                        []

                                                NewCollection.No form ->
                                                    Html.div
                                                        []
                                                        [ Html.div
                                                            [ class "field"
                                                            ]
                                                            [ Html.p
                                                                [ class "control has-icons-left"
                                                                ]
                                                                [ Html.input
                                                                    [ class "input"
                                                                    , type_ "number"
                                                                    , placeholder "Royalty fee % in secondary markets"
                                                                    , step "0.01"
                                                                    , onInput <|
                                                                        \s ->
                                                                            FromCreator <|
                                                                                CreatorMsg.Existing fromGlobal <|
                                                                                    ExistingMsg.NewCollectionForm <|
                                                                                        NewCollectionForm.Fee
                                                                                            (String.toUpper s)
                                                                                            form
                                                                    ]
                                                                    []
                                                                , Html.span
                                                                    [ class "icon is-left"
                                                                    ]
                                                                    [ Html.i
                                                                        [ class "fas fa-file-signature"
                                                                        ]
                                                                        []
                                                                    ]
                                                                ]
                                                            ]
                                                        , inputted
                                                            form.fee
                                                            (\f ->
                                                                String.concat
                                                                    [ FormatNumber.format usLocale f
                                                                    , "%"
                                                                    ]
                                                            )
                                                        ]

                                        create =
                                            case submitted of
                                                NewCollection.Yes _ ->
                                                    Html.div
                                                        []
                                                        []

                                                NewCollection.No form ->
                                                    case ( form.logo, ( form.name, form.symbol ), ( ( form.totalSupply, form.creatorDistribution ), form.price, form.fee ) ) of
                                                        ( Just logo, ( Just name, Just symbol ), ( ( Just totalSupply, Just cd ), Just price, Just fee ) ) ->
                                                            Html.div
                                                                []
                                                                [ Html.button
                                                                    [ class "is-button-1"
                                                                    , onClick <|
                                                                        FromCreator <|
                                                                            CreatorMsg.Existing fromGlobal <|
                                                                                ExistingMsg.CreateNewNft
                                                                                    { logo = logo
                                                                                    , name = name
                                                                                    , symbol = symbol
                                                                                    , totalSupply = totalSupply
                                                                                    , creatorDistribution = cd
                                                                                    , price = price
                                                                                    , fee = fee
                                                                                    }
                                                                    ]
                                                                    [ Html.text
                                                                        """create nft "original" edition
                                                                        """
                                                                    ]
                                                                ]

                                                        _ ->
                                                            Html.div
                                                                []
                                                                []

                                        retries =
                                            case submitted of
                                                NewCollection.Yes form ->
                                                    case form.retries of
                                                        0 ->
                                                            Html.div
                                                                []
                                                                []

                                                        gto ->
                                                            Html.div
                                                                [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                                ]
                                                                [ Html.text <|
                                                                    String.concat
                                                                        [ "caught exception; retry:"
                                                                        , " "
                                                                        , String.fromInt gto
                                                                        ]
                                                                ]

                                                _ ->
                                                    Html.div
                                                        []
                                                        []

                                        waiting =
                                            case submitted of
                                                NewCollection.Yes form ->
                                                    let
                                                        step : String -> Bool -> Html Msg
                                                        step caption done =
                                                            case done of
                                                                True ->
                                                                    Html.div
                                                                        [ class "is-text-container-4 is-size-4 is-text-container-5-mobile is-size-5-mobile is-family-secondary"
                                                                        ]
                                                                        [ Html.text <|
                                                                            String.concat
                                                                                [ "☑️"
                                                                                , " "
                                                                                , caption
                                                                                ]
                                                                        ]

                                                                False ->
                                                                    Html.div
                                                                        [ class "is-text-container-4 is-size-4 is-text-container-5-mobile is-size-5-mobile is-family-secondary"
                                                                        ]
                                                                        [ Html.text caption
                                                                        , Html.div
                                                                            [ class "is-loading-tiny mr-1"
                                                                            , style "float" "left"
                                                                            ]
                                                                            []
                                                                        ]

                                                        stepOne : Bool -> Html Msg
                                                        stepOne =
                                                            step "provisioning storage"

                                                        stepTwo : Bool -> Html Msg
                                                        stepTwo =
                                                            step "uploading metadata"

                                                        stepThree : Bool -> Html Msg
                                                        stepThree =
                                                            step "minting your new collection"
                                                    in
                                                    case form.step of
                                                        1 ->
                                                            Html.div
                                                                []
                                                                [ Html.div
                                                                    [ class "mb-6"
                                                                    ]
                                                                    [ stepOne False
                                                                    ]
                                                                , Html.div
                                                                    [ class "mb-6"
                                                                    ]
                                                                    [ stepTwo False
                                                                    ]
                                                                , Html.div
                                                                    [ class "mb-6"
                                                                    ]
                                                                    [ stepThree False
                                                                    ]
                                                                ]

                                                        2 ->
                                                            Html.div
                                                                []
                                                                [ Html.div
                                                                    [ class "mb-6"
                                                                    ]
                                                                    [ stepOne True
                                                                    ]
                                                                , Html.div
                                                                    [ class "mb-6"
                                                                    ]
                                                                    [ stepTwo False
                                                                    ]
                                                                , Html.div
                                                                    [ class "mb-6"
                                                                    ]
                                                                    [ stepThree False
                                                                    ]
                                                                ]

                                                        3 ->
                                                            Html.div
                                                                []
                                                                [ Html.div
                                                                    [ class "mb-6"
                                                                    ]
                                                                    [ stepOne True
                                                                    ]
                                                                , Html.div
                                                                    [ class "mb-6"
                                                                    ]
                                                                    [ stepTwo True
                                                                    ]
                                                                , Html.div
                                                                    [ class "mb-6"
                                                                    ]
                                                                    [ stepThree False
                                                                    ]
                                                                ]

                                                        _ ->
                                                            Html.div
                                                                []
                                                                []

                                                NewCollection.No _ ->
                                                    Html.div
                                                        []
                                                        []
                                    in
                                    Html.div
                                        []
                                        [ Html.div
                                            [ class "mb-3"
                                            ]
                                            [ header3 fromGlobal
                                            ]
                                        , Html.div
                                            [ class "columns"
                                            ]
                                            [ Html.div
                                                [ class "column is-half"
                                                ]
                                                [ imageForm
                                                ]
                                            , Html.div
                                                [ class "column is-half"
                                                ]
                                                [ nameForm
                                                , symbolFrom
                                                , tsForm
                                                , cdForm
                                                , priceForm
                                                , feeForm
                                                , create
                                                , retries
                                                , Html.div
                                                    [ class "mt-5"
                                                    ]
                                                    [ waiting
                                                    ]
                                                ]
                                            ]
                                        ]

                        Existing.SelectedCollection collection uploaded ->
                            let
                                uploaded_ =
                                    let
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
                                                    ]
                                                ]
                                            , rows
                                            ]
                                        ]

                                metadata =
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
                                                                    , collection.accounts.mint
                                                                    ]
                                                            , target "_blank"
                                                            ]
                                                            [ Html.text <|
                                                                Wallet.slice collection.accounts.mint
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
                                                                    , collection.accounts.ata.address
                                                                    ]
                                                            , target "_blank"
                                                            ]
                                                            [ Html.text <|
                                                                String.fromInt collection.accounts.ata.balance
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
                                                            """🔎 view as collector
                                                            """
                                                        ]
                                                    , Html.td
                                                        [ class "is-text-container-5 is-size-5 is-text-container-6-mobile is-size-6-mobile"
                                                        , style "opacity" "50%"
                                                        ]
                                                        [ Html.a
                                                            [ class "has-sky-blue-text"
                                                            , Local.href <|
                                                                Local.Collect <|
                                                                    Collector.MaybeExistingCollection
                                                                        collection.meta.handle
                                                                        collection.meta.index
                                                            ]
                                                            [ Html.text <|
                                                                String.concat
                                                                    [ "dap.cool/#/"
                                                                    , collection.meta.handle
                                                                    , "/"
                                                                    , String.fromInt collection.meta.index
                                                                    ]
                                                            ]
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                            in
                            Html.div
                                []
                                [ header3 fromGlobal
                                , Html.div
                                    [ class "mt-3"
                                    ]
                                    [ View.Generic.Collection.Creator.Creator.view collection
                                    ]
                                , Html.div
                                    [ class "mt-3"
                                    ]
                                    [ metadata
                                    ]
                                , Html.div
                                    [ class "mt-6"
                                    ]
                                    [ Html.div
                                        [ class "mb-3"
                                        ]
                                        [ Html.button
                                            [ class "is-button-1"
                                            , onClick <|
                                                FromCreator <|
                                                    CreatorMsg.Existing fromGlobal <|
                                                        ExistingMsg.StartUploading collection
                                            ]
                                            [ Html.text "upload stuff"
                                            ]
                                        ]
                                    ]
                                , Html.div
                                    [ class "mt-3"
                                    ]
                                    [ uploaded_
                                    ]
                                ]

                        Existing.Uploading collection form ->
                            let
                                selector =
                                    Html.div
                                        [ class "file has-name"
                                        ]
                                        [ Html.label
                                            [ class "file-label"
                                            ]
                                            [ Html.input
                                                [ id "dap-cool-collection-upload-selector"
                                                , class "file-input"
                                                , type_ "file"
                                                , multiple True
                                                , onClick <|
                                                    FromCreator <|
                                                        CreatorMsg.Existing fromGlobal <|
                                                            ExistingMsg.SelectFilesToUpload
                                                ]
                                                []
                                            , Html.span
                                                [ class "file-cta"
                                                ]
                                                [ Html.span
                                                    [ class "file-icon"
                                                    ]
                                                    [ Html.i
                                                        [ class "fas fa-upload"
                                                        ]
                                                        []
                                                    ]
                                                , Html.span
                                                    [ class "file-label"
                                                    ]
                                                    [ Html.text "Select files to upload . . . "
                                                    ]
                                                ]
                                            , Html.span
                                                [ class "file-name"
                                                ]
                                                [ Html.text <|
                                                    String.concat
                                                        [ String.fromInt form.files.count
                                                        , " "
                                                        , "files selected"
                                                        ]
                                                ]
                                            ]
                                        ]

                                files =
                                    Html.div
                                        []
                                        [ Html.text <|
                                            String.concat
                                                [ String.fromInt form.files.count
                                                , " "
                                                , "files selected"
                                                ]
                                        ]

                                title =
                                    case form.title of
                                        "" ->
                                            Html.div
                                                [ class "is-text-container-3 is-size-3"
                                                ]
                                                [ Html.text <|
                                                    String.concat
                                                        [ "untitled"
                                                        ]
                                                ]

                                        nes ->
                                            Html.div
                                                [ class "is-text-container-3 is-size-3"
                                                ]
                                                [ Html.text <|
                                                    String.concat
                                                        [ nes
                                                        ]
                                                ]

                                uploadForm =
                                    case form.title of
                                        "" ->
                                            { form | title = "untitled" }

                                        _ ->
                                            form

                                step =
                                    case form.step of
                                        0 ->
                                            let
                                                upload =
                                                    case form.files.count > 0 of
                                                        True ->
                                                            Html.div
                                                                []
                                                                [ Html.button
                                                                    [ onClick <|
                                                                        FromCreator <|
                                                                            CreatorMsg.Existing fromGlobal <|
                                                                                ExistingMsg.Upload collection uploadForm
                                                                    ]
                                                                    [ Html.text "upload"
                                                                    ]
                                                                ]

                                                        False ->
                                                            Html.div
                                                                []
                                                                []
                                            in
                                            Html.div
                                                []
                                                [ selector
                                                , Html.div
                                                    [ class "mt-3"
                                                    ]
                                                    [ title
                                                    , Html.div
                                                        []
                                                        [ Html.input
                                                            [ class "input"
                                                            , placeholder "title ✏️"
                                                            , onInput <|
                                                                \s ->
                                                                    FromCreator <|
                                                                        CreatorMsg.Existing fromGlobal <|
                                                                            ExistingMsg.TypingUploadTitle
                                                                                collection
                                                                                form
                                                                                s
                                                            ]
                                                            []
                                                        ]
                                                    ]
                                                , upload
                                                ]

                                        int ->
                                            Html.div
                                                []
                                                [ title
                                                , files
                                                , Html.div
                                                    []
                                                    [ Html.text <|
                                                        String.concat
                                                            [ "step"
                                                            , ": "
                                                            , String.fromInt int
                                                            ]
                                                    ]
                                                , Html.text <| String.fromInt form.retries
                                                ]
                            in
                            Html.div
                                []
                                [ header3 fromGlobal
                                , Html.div
                                    [ class "columns is-mobile"
                                    ]
                                    [ Html.div
                                        [ class "column is-half-mobile is-one-third-tablet"
                                        ]
                                        [ View.Generic.Collection.Creator.Creator.view collection
                                        ]
                                    , Html.div
                                        [ class "column is-half-mobile is-two-third-tablet"
                                        ]
                                        [ step
                                        ]
                                    ]
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
        []
        [ Html.div
            [ class "mt-4"
            ]
            [ Html.div
                [ class "is-family-secondary is-light-text-container-6 is-size-6 is-light-text-container-6-mobile is-size-6-mobile is-italic"
                ]
                [ Html.text "Admin"
                ]
            , Html.div
                [ class "is-text-container-2 is-size-2 is-text-container-3-mobile is-size-3-mobile"
                ]
                [ Html.text "New"
                ]
            ]
        , Html.div
            [ class "mt-5"
            ]
            [ Html.div
                [ class "is-family-secondary is-light-text-container-6 is-size-6 is-light-text-container-6-mobile is-size-6-mobile is-italic"
                ]
                [ Html.text "handle"
                ]
            , Html.div
                [ class "mt-1 container is-text-container-3 is-size-3 is-text-container-4-mobile is-size-4-mobile"
                ]
                [ Html.div
                    [ class "mb-2"
                    ]
                    [ Html.text
                        """Register your wallet on-chain with a creator "handle" 🆒
                        """
                    ]
                , Html.div
                    []
                    [ Html.em
                        [ class "is-family-secondary"
                        ]
                        [ Html.text "dap.cool"
                        ]
                    , Html.text
                        """ derives a unique URL from your handle so that collectors can find your page 😎
                        """
                    ]
                ]
            ]
        ]


header2 : LogoForm -> BioForm -> HasWalletAndHandle -> Html Msg
header2 logoForm bioForm global =
    Header.view (Header.Admin global logoForm bioForm) global.handle global.metadata


header3 : HasWalletAndHandle -> Html Msg
header3 global =
    Header.header0 (Header.Admin global LogoForm.Top BioForm.Empty) global.handle
