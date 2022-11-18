module View.Create.Create exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (accept, class, href, id, placeholder, src, target, type_, width)
import Html.Events exposing (onClick, onInput)
import Json.Encode
import Model.Collection as Collection
import Model.Creator.Creator as Creator exposing (Creator(..))
import Model.Creator.Existing.Existing as Existing
import Model.Creator.Existing.HandleFormStatus as ExistingHandleFormStatus
import Model.Creator.Existing.NewCollection as NewCollection
import Model.Creator.New.New as New
import Model.Global as Global exposing (Global)
import Model.Handle as Handle
import Model.State as State
import Msg.Creator.Creator as CreatorMsg
import Msg.Creator.Existing.Existing as ExistingMsg
import Msg.Creator.Existing.NewCollectionForm as NewCollectionForm
import Msg.Creator.New.New as NewMsg
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Creator.Creator
import View.Generic.Wallet


body : Global -> Creator -> Html Msg
body global creator =
    let
        html =
            case creator of
                Top ->
                    Html.div
                        [ class "has-border-2 px-2 pt-2 pb-6"
                        ]
                        [ header
                        , Html.div
                            [ class "pb-2"
                            ]
                            [ Html.text
                                """☑️
                                """
                            , Html.text
                                """Create new fungible & non-fungible
                                """
                            , Html.a
                                [ class "has-sky-blue-text"
                                , href "https://spl.solana.com/token"
                                , target "_blank"
                                ]
                                [ Html.text "spl-tokens"
                                ]
                            ]
                        , Html.div
                            [ class "pb-2"
                            ]
                            [ Html.text
                                """☑️
                                """
                            , Html.text
                                """Upload
                                """
                            , Html.a
                                [ class "has-sky-blue-text"
                                , href "https://litprotocol.com/"
                                , target "_blank"
                                ]
                                [ Html.text "token-gated"
                                ]
                            , Html.text
                                """ files for your community
                                """
                            ]
                        , Html.div
                            [ class "pb-2"
                            ]
                            [ Html.text
                                """☑️
                                """
                            , Html.text
                                """Source
                                """
                            , Html.a
                                [ class "has-sky-blue-text"
                                , href "https://docs.metaplex.com/programs/hydra/intro"
                                , target "_blank"
                                ]
                                [ Html.text "crowd-funding"
                                ]
                            , Html.text
                                """ for new projects
                                """
                            ]
                        , Html.div
                            [ class "pb-4"
                            ]
                            [ Html.text
                                """☑️
                                """
                            , Html.text
                                """Customize your own
                                """
                            , Html.a
                                [ class "has-sky-blue-text"
                                , href "https://solana.com/"
                                , target "_blank"
                                ]
                                [ Html.text "on-chain"
                                ]
                            , Html.text
                                """ profile to highlight your work
                                """
                            ]
                        , Html.div
                            []
                            [ Html.text
                                """Login as
                                """
                            , Html.button
                                [ class "is-button-1" -- TODO
                                ]
                                [ Html.text "existing creator"
                                ]
                            , Html.text
                                """ or get started with a
                                """
                            , Html.button
                                [ class "is-button-1"
                                , onClick <| FromCreator global <| CreatorMsg.New <| NewMsg.StartHandleForm
                                ]
                                [ Html.text "new profile"
                                ]
                            ]
                        ]

                New newCreator ->
                    case newCreator of
                        New.Top ->
                            Html.div
                                [ class "has-border-2 px-2 pt-2 pb-6"
                                ]
                                [ header
                                , Html.div
                                    [ class "field"
                                    ]
                                    [ Html.p
                                        [ class "control has-icons-left"
                                        ]
                                        [ Html.input
                                            [ class "input"
                                            , type_ "text"
                                            , placeholder "Handle"
                                            , onInput <|
                                                \s ->
                                                    FromCreator global <|
                                                        CreatorMsg.New <|
                                                            NewMsg.HandleForm <|
                                                                Handle.Typing s
                                            ]
                                            []
                                        , Html.span
                                            [ class "icon is-left"
                                            ]
                                            [ Html.i
                                                [ class "fas fa-at"
                                                ]
                                                []
                                            ]
                                        ]
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
                                                []
                                                [ Html.button
                                                    [ class "is-button-1"
                                                    , onClick <|
                                                        FromCreator global <|
                                                            CreatorMsg.New <|
                                                                NewMsg.HandleForm <|
                                                                    Handle.Confirm string
                                                    ]
                                                    [ Html.text <|
                                                        String.concat
                                                            [ "proceed with handle as:"
                                                            , " "
                                                            , string
                                                            ]
                                                    ]
                                                ]
                            in
                            Html.div
                                [ class "has-border-2 px-2 pt-2 pb-6"
                                ]
                                [ header
                                , Html.div
                                    [ class "field"
                                    ]
                                    [ Html.p
                                        [ class "control has-icons-left"
                                        ]
                                        [ Html.input
                                            [ class "input"
                                            , type_ "text"
                                            , placeholder "Handle"
                                            , onInput <|
                                                \s ->
                                                    FromCreator global <|
                                                        CreatorMsg.New <|
                                                            NewMsg.HandleForm <|
                                                                Handle.Typing s
                                            ]
                                            []
                                        , Html.span
                                            [ class "icon is-left"
                                            ]
                                            [ Html.i
                                                [ class "fas fa-at"
                                                ]
                                                []
                                            ]
                                        ]
                                    ]
                                , select
                                ]

                        New.WaitingForHandleConfirmation ->
                            Html.div
                                [ class "has-border-2 px-2 pt-2 pb-6"
                                ]
                                [ header
                                , Html.div
                                    [ class "is-loading"
                                    ]
                                    []
                                ]

                        New.HandleInvalid string ->
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
                                                FromCreator global <|
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
                                [ class "has-border-2 px-2 pt-2 pb-6"
                                ]
                                [ header
                                , Html.div
                                    [ class "has-border-2 px-2 py-2"
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
                                                FromCreator global <|
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

                Existing existingCreator ->
                    case ( global, existingCreator ) of
                        ( Global.HasWalletAndHandle withWallet, Existing.Top collections ) ->
                            Html.div
                                [ class "has-border-2 px-2 pt-2 pb-6"
                                ]
                                [ View.Generic.Wallet.view withWallet.wallet
                                , header
                                , Html.div
                                    []
                                    [ Html.text <|
                                        String.concat
                                            [ "authorized as:"
                                            , " "
                                            , withWallet.handle
                                            ]
                                    ]
                                , Html.div
                                    []
                                    [ Html.button
                                        [ class "is-button-1"
                                        , onClick <|
                                            FromCreator global <|
                                                CreatorMsg.Existing <|
                                                    ExistingMsg.StartCreatingNewCollection
                                        ]
                                        [ Html.text "create new collection"
                                        ]
                                    ]
                                , View.Generic.Collection.Creator.Creator.viewMany
                                    global
                                    withWallet.handle
                                    collections
                                ]

                        ( Global.HasWalletAndHandle withWallet, Existing.CreatingNewCollection newCollection ) ->
                            case newCollection of
                                NewCollection.Input form submitted ->
                                    let
                                        imageForm =
                                            Html.div
                                                []
                                                [ Html.input
                                                    [ id "dap-cool-collection-logo-selector"
                                                    , type_ "file"
                                                    , accept <|
                                                        String.join
                                                            ", "
                                                            [ ".jpg"
                                                            , ".jpeg"
                                                            , ".png"
                                                            ]
                                                    , onClick <|
                                                        FromCreator global <|
                                                            CreatorMsg.Existing <|
                                                                ExistingMsg.NewCollectionForm
                                                                    NewCollectionForm.Image
                                                    ]
                                                    []
                                                , Html.div
                                                    []
                                                    [ Html.img
                                                        [ src "images/upload/default-pfp.jpg"
                                                        , width 500
                                                        , id "dap-cool-collection-logo"
                                                        ]
                                                        []
                                                    ]
                                                ]

                                        nameForm =
                                            case submitted of
                                                True ->
                                                    Html.div
                                                        []
                                                        []

                                                False ->
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
                                                                            FromCreator global <|
                                                                                CreatorMsg.Existing <|
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
                                                        ]

                                        symbolFrom =
                                            case submitted of
                                                True ->
                                                    Html.div
                                                        []
                                                        []

                                                False ->
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
                                                                            FromCreator global <|
                                                                                CreatorMsg.Existing <|
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
                                                        ]

                                        create =
                                            case submitted of
                                                True ->
                                                    Html.div
                                                        []
                                                        []

                                                False ->
                                                    let
                                                        e1 =
                                                            String.isEmpty form.name

                                                        e2 =
                                                            String.isEmpty form.symbol
                                                    in
                                                    case ( e1, e2 ) of
                                                        ( False, False ) ->
                                                            Html.div
                                                                []
                                                                [ Html.button
                                                                    [ class "is-button-1"
                                                                    , onClick <|
                                                                        FromCreator global <|
                                                                            CreatorMsg.Existing <|
                                                                                ExistingMsg.CreateNewCollection form
                                                                    ]
                                                                    [ Html.text "create"
                                                                    ]
                                                                ]

                                                        _ ->
                                                            Html.div
                                                                []
                                                                []

                                        waiting =
                                            case submitted of
                                                True ->
                                                    Html.div
                                                        [ class "is-loading"
                                                        ]
                                                        []

                                                False ->
                                                    Html.div
                                                        []
                                                        []
                                    in
                                    Html.div
                                        [ class "has-border-2 px-2 pt-2 pb-6"
                                        ]
                                        [ header
                                        , imageForm
                                        , nameForm
                                        , symbolFrom
                                        , create
                                        , waiting
                                        ]

                                NewCollection.HasCreateNft collection ->
                                    Html.div
                                        [ class "has-border-2 px-2 pt-2 pb-6"
                                        ]
                                        [ header
                                        , View.Generic.Collection.Creator.Creator.view
                                            global
                                            withWallet.handle
                                            collection
                                        , Html.div
                                            []
                                            [ Html.text
                                                """This NFT still needs to be marked as an on-chain collection
                                                before we can start listing the primary sale.
                                                """
                                            , Html.div
                                                []
                                                [ Html.button
                                                    [ class "is-button-1"
                                                    , onClick <|
                                                        FromCreator global <|
                                                            CreatorMsg.Existing <|
                                                                ExistingMsg.MarkNewCollection collection
                                                    ]
                                                    [ Html.text "mark collection"
                                                    ]
                                                ]
                                            ]
                                        ]

                                NewCollection.WaitingForMarkNft collection ->
                                    Html.div
                                        [ class "has-border-2 px-2 pt-2 pb-6"
                                        ]
                                        [ header
                                        , View.Generic.Collection.Creator.Creator.view
                                            global
                                            withWallet.handle
                                            collection
                                        , Html.div
                                            [ class "is-loading"
                                            ]
                                            []
                                        ]

                                NewCollection.Done collection ->
                                    Html.div
                                        [ class "has-border-2 px-2 pt-2 pb-6"
                                        ]
                                        [ header
                                        , Html.div
                                            []
                                            [ Html.text
                                                """All done \u{1FAE0}
                                                """
                                            ]
                                        , View.Generic.Collection.Creator.Creator.view
                                            global
                                            withWallet.handle
                                            collection
                                        , Html.div
                                            []
                                            [ Html.a
                                                [ State.href <|
                                                    State.Valid global <|
                                                        State.Create (Creator.MaybeExisting withWallet.handle)
                                                ]
                                                [ Html.text "back 2 collections 🔙"
                                                ]
                                            ]
                                        ]

                        ( Global.HasWalletAndHandle withWallet, Existing.SelectedCollection collection ) ->
                            let
                                button =
                                    case Collection.isEmpty collection of
                                        True ->
                                            Html.div
                                                []
                                                [ Html.text
                                                    """This NFT still needs to be marked as an on-chain collection
                                                    before we can start listing the primary sale.
                                                    """
                                                , Html.div
                                                    []
                                                    [ Html.button
                                                        [ class "is-button-1"
                                                        , onClick <|
                                                            FromCreator global <|
                                                                CreatorMsg.Existing <|
                                                                    ExistingMsg.MarkNewCollection collection
                                                        ]
                                                        [ Html.text "mark collection"
                                                        ]
                                                    ]
                                                ]

                                        False ->
                                            Html.div
                                                []
                                                []
                            in
                            Html.div
                                [ class "has-border-2 px-2 pt-2 pb-6"
                                ]
                                [ View.Generic.Wallet.view withWallet.wallet
                                , header
                                , View.Generic.Collection.Creator.Creator.view global withWallet.handle collection
                                , button
                                ]

                        ( Global.NoWalletYet, Existing.AuthorizingFromUrl ExistingHandleFormStatus.WaitingForHandleConfirmation ) ->
                            Html.div
                                [ class "has-border-2 px-2 pt-2 pb-6"
                                ]
                                [ header
                                , Html.div
                                    [ class "is-loading"
                                    ]
                                    []
                                ]

                        ( Global.NoWalletYet, Existing.AuthorizingFromUrl (ExistingHandleFormStatus.HandleInvalid string) ) ->
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
                                    ]
                                ]

                        ( Global.NoWalletYet, Existing.AuthorizingFromUrl (ExistingHandleFormStatus.HandleDoesNotExist string) ) ->
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
                                    ]
                                ]

                        ( Global.HasWalletAndHandle withWallet, Existing.AuthorizingFromUrl ExistingHandleFormStatus.UnAuthorized ) ->
                            Html.div
                                [ class "has-border-2 px-2 pt-2 pb-6"
                                ]
                                [ View.Generic.Wallet.view withWallet.wallet
                                , header
                                , Html.div
                                    [ class "has-border-2 px-2 py-2"
                                    ]
                                    [ Html.text <|
                                        String.concat
                                            [ "connected wallet is not authorized to manage handle:"
                                            , " "
                                            , withWallet.handle
                                            ]
                                    ]
                                ]

                        _ ->
                            Html.div
                                []
                                [ Html.text <| Json.Encode.encode 0 <| Global.encoder global
                                ]

                MaybeExisting _ ->
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


header : Html Msg
header =
    Html.div
        [ class "is-family-secondary mt-2 mb-5"
        ]
        [ Html.h2
            []
            [ Html.text "Creator Console"
            ]
        ]
