module View.Create.Create exposing (body)

import Html exposing (Html)
import Html.Attributes exposing (accept, class, id, placeholder, src, type_, width)
import Html.Events exposing (onClick, onInput)
import Model.Collection as Collection
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
                                                    FromCreator <|
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
                                                    FromCreator <|
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
                                [ class "has-border-2 px-2 pt-2 pb-6"
                                ]
                                [ header
                                , Html.div
                                    []
                                    [ Html.text <|
                                        String.concat
                                            [ "authorized as:"
                                            , " "
                                            , fromGlobal.handle
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
                                , View.Generic.Collection.Creator.Creator.viewMany
                                    fromGlobal
                                    fromGlobal.collections
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
                                                                                ExistingMsg.CreateNewCollection form
                                                                    ]
                                                                    [ Html.text "create"
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
                                        [ class "has-border-2 px-2 pt-2 pb-6"
                                        ]
                                        [ header
                                        , imageForm
                                        , nameForm
                                        , symbolFrom
                                        , create
                                        , retries
                                        , waiting
                                        ]

                                NewCollection.HasCreateNft collection ->
                                    Html.div
                                        [ class "has-border-2 px-2 pt-2 pb-6"
                                        ]
                                        [ header
                                        , View.Generic.Collection.Creator.Creator.view
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
                                                        FromCreator <|
                                                            CreatorMsg.Existing fromGlobal <|
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
                                            collection
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

                        Existing.SelectedCollection collection ->
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
                                                            FromCreator <|
                                                                CreatorMsg.Existing fromGlobal <|
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
                                [ header
                                , View.Generic.Collection.Creator.Creator.view collection
                                , button
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
