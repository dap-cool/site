module View.Create.Create exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (accept, class, href, id, multiple, placeholder, src, style, target, type_, width)
import Html.Events exposing (onClick, onInput)
import Model.Collection
import Model.Creator.Creator exposing (Creator(..))
import Model.Creator.Existing.Existing as Existing
import Model.Creator.Existing.NewCollection as NewCollection
import Model.Creator.New.New as New
import Model.Handle as Handle
import Model.State.Local.Local as Local
import Msg.Creator.Creator as CreatorMsg
import Msg.Creator.Existing.Existing as ExistingMsg
import Msg.Creator.Existing.NewCollectionForm as NewCollectionForm
import Msg.Creator.New.New as NewMsg
import Msg.Msg exposing (Msg(..))
import View.Generic.Collection.Creator.Creator


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
                                                []
                                                [ Html.button
                                                    [ class "is-button-1"
                                                    , onClick <|
                                                        FromCreator <|
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

                        New.WaitingForHandleConfirmation ->
                            Html.div
                                []
                                [ header
                                , Html.div
                                    [ class "is-loading"
                                    ]
                                    []
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
                        Existing.Top ->
                            Html.div
                                []
                                [ header2 fromGlobal.handle
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
                                , Html.div
                                    [ class "mt-5"
                                    ]
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
                                                        FromCreator <|
                                                            CreatorMsg.Existing fromGlobal <|
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
                                                        ]

                                        create =
                                            case submitted of
                                                NewCollection.Yes _ ->
                                                    Html.div
                                                        []
                                                        []

                                                NewCollection.No form ->
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
                                                                        FromCreator <|
                                                                            CreatorMsg.Existing fromGlobal <|
                                                                                ExistingMsg.CreateNewNft form
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
                                                                []
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
                                                NewCollection.Yes _ ->
                                                    Html.div
                                                        [ class "is-loading"
                                                        ]
                                                        []

                                                NewCollection.No _ ->
                                                    Html.div
                                                        []
                                                        []
                                    in
                                    Html.div
                                        []
                                        [ header3 fromGlobal.handle
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
                                                , create
                                                , retries
                                                , waiting
                                                ]
                                            ]
                                        ]

                                NewCollection.Done collection ->
                                    Html.div
                                        []
                                        [ header3 fromGlobal.handle
                                        , Html.div
                                            [ class "columns is-mobile"
                                            ]
                                            [ Html.div
                                                [ class "column is-half-mobile is-one-third-tablet"
                                                ]
                                                [ View.Generic.Collection.Creator.Creator.view collection
                                                ]
                                            ]
                                        , Html.div
                                            [ class "column is-half-mobile is-two-third-tablet"
                                            ]
                                            [ Html.text
                                                """Your NFT has successfully been created! 😁
                                                """
                                            , Html.a
                                                [ class "has-sky-blue-text"
                                                , target "_blank"
                                                , href <|
                                                    String.concat
                                                        [ "https://explorer.solana.com/address/"
                                                        , collection.accounts.mint
                                                        ]
                                                ]
                                                [ Html.text "view it here 👀"
                                                ]
                                            , Html.div
                                                []
                                                [ Html.a
                                                    [ Local.href <| Local.Create (New New.Top)
                                                    , class "has-sky-blue-text"
                                                    ]
                                                    [ Html.text "back 2 collections 🔙"
                                                    ]
                                                ]
                                            ]
                                        ]

                        Existing.WaitingForUploaded ->
                            Html.div
                                []
                                [ header3 fromGlobal.handle
                                , Html.div
                                    [ class "is-loading"
                                    ]
                                    []
                                ]

                        Existing.SelectedCollection collection uploaded ->
                            Html.div
                                []
                                [ header3 fromGlobal.handle
                                , Html.div
                                    [ class "mt-3"
                                    ]
                                    [ View.Generic.Collection.Creator.Creator.view collection
                                    ]
                                , Html.div
                                    [ class "mt-3"
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
                                    , Html.div
                                        [ class "columns"
                                        ]
                                      <|
                                        List.map
                                            (\datum ->
                                                Html.div
                                                    [ class "column is-one-third"
                                                    ]
                                                    [ Html.div
                                                        [ class "is-upload"
                                                        ]
                                                        [ Html.div
                                                            [ class "is-text-container-3 is-size-3 is-text-container-4-mobile is-size-4-mobile"
                                                            ]
                                                            [ Html.text datum.metadata.title
                                                            ]
                                                        , Html.div
                                                            [ class "is-text-container-4 is-size-4 is-text-container-5-mobile is-size-5-mobile"
                                                            ]
                                                            [ Html.text <|
                                                                String.concat
                                                                    [ "# of files"
                                                                    , "➡️"
                                                                    , String.fromInt datum.metadata.zip.count
                                                                    ]
                                                            ]
                                                        ]
                                                    ]
                                            )
                                            uploaded
                                    ]
                                ]

                        Existing.Uploading collection form ->
                            let
                                title =
                                    case form.title of
                                        "" ->
                                            Html.div
                                                [ class "is-text-container-3 is-size-3"
                                                ]
                                                [ Html.text <|
                                                    String.concat
                                                        [ "title"
                                                        , " "
                                                        , "➡️"
                                                        , " "
                                                        , "untitled"
                                                        ]
                                                ]

                                        nes ->
                                            Html.div
                                                [ class "is-text-container-3 is-size-3"
                                                ]
                                                [ Html.text <|
                                                    String.concat
                                                        [ "title"
                                                        , "➡️"
                                                        , " "
                                                        , nes
                                                        ]
                                                ]

                                uploadForm =
                                    case form.title of
                                        "" ->
                                            { form | title = "untitled" }

                                        _ ->
                                            form
                            in
                            Html.div
                                []
                                [ header3 fromGlobal.handle
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
                                        [ Html.input
                                            [ id "dap-cool-collection-upload-selector"
                                            , type_ "file"
                                            , multiple True
                                            ]
                                            []
                                        , Html.div
                                            []
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
                                                                    ExistingMsg.TypingUploadTitle collection s
                                                    ]
                                                    []
                                                ]
                                            ]
                                        , Html.div
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
                                        ]
                                    ]
                                ]

                        Existing.WaitingForUpload collection ->
                            Html.div
                                []
                                [ header3 fromGlobal.handle
                                , Html.div
                                    [ class "columns is-mobile"
                                    ]
                                    [ Html.div
                                        [ class "column is-half-mobile is-one-third-tablet"
                                        ]
                                        [ View.Generic.Collection.Creator.Creator.view collection
                                        ]
                                    , Html.div
                                        [ class "column is-half-mobile is-two-thirds-tablet"
                                        ]
                                        [ Html.div
                                            [ class "is-loading"
                                            ]
                                            []
                                        ]
                                    ]
                                ]

                        Existing.UploadSuccessful collection ->
                            Html.div
                                []
                                [ header3 fromGlobal.handle
                                , Html.div
                                    [ class "columns is-mobile"
                                    ]
                                    [ Html.div
                                        [ class "column is-half-mobile is-one-third-tablet"
                                        ]
                                        [ View.Generic.Collection.Creator.Creator.view collection
                                        ]
                                    , Html.div
                                        [ class "column is-half-mobile is-two-thirds-tablet"
                                        ]
                                        [ Html.div
                                            []
                                            [ Html.text <|
                                                String.concat
                                                    [ "Upload successful"
                                                    ]
                                            ]
                                        , Html.div
                                            []
                                            [ Html.a
                                                [ Local.href <| Local.Create (New New.Top)
                                                , class "has-sky-blue-text"
                                                ]
                                                [ Html.text "back 2 collections 🔙"
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
    in
    Html.div
        []
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
                    [ class "mb-1"
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
                        """ derives an unique URL from your handle so that collectors can find your page 😎
                        """
                    ]
                ]
            ]
        ]


header2 : String -> Html Msg
header2 handle =
    Html.div
        []
        [ header3 handle
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


header3 : String -> Html Msg
header3 handle =
    Html.div
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
            [ Html.text handle
            ]
        ]
