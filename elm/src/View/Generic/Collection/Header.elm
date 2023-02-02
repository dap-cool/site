module View.Generic.Collection.Header exposing (Role(..), header0, view)

import Html exposing (Html)
import Html.Attributes exposing (class, id, src, type_)
import Html.Events exposing (onClick)
import Model.Creator.Existing.LogoForm as LogoForm exposing (LogoForm)
import Model.CreatorMetadata as CreatorMetadata exposing (CreatorMetadata)
import Model.File exposing (File)
import Model.Handle exposing (Handle)
import Model.State.Global.HasWalletAndHandle exposing (HasWalletAndHandle)
import Msg.Creator.Creator as CreatorMsg
import Msg.Creator.Existing.Existing as ExistingMsg
import Msg.Msg exposing (Msg(..))


view : Role -> Handle -> CreatorMetadata -> Html Msg
view role handle metadata =
    let
        ( bio, logo, banner ) =
            case metadata of
                CreatorMetadata.Initialized initialized ->
                    let
                        bio_ =
                            let
                                header_ =
                                    Html.div
                                        [ class "is-family-secondary is-light-text-container-6 is-size-6 is-light-text-container-6-mobile is-size-6-mobile is-italic"
                                        ]
                                        [ Html.text "bio"
                                        ]
                            in
                            case initialized.bio of
                                Just string ->
                                    Html.div
                                        []
                                        [ header_
                                        , Html.div
                                            [ class "mt-1 container is-text-container-3 is-size-3 is-text-container-4-mobile is-size-4-mobile"
                                            ]
                                            [ Html.text string
                                            ]
                                        ]

                                Nothing ->
                                    let
                                        button =
                                            case role of
                                                Admin _ _ ->
                                                    Html.div
                                                        []
                                                        [ Html.button
                                                            []
                                                            [ Html.text "✏️✏️✏️"
                                                            ]
                                                        ]

                                                Collector ->
                                                    Html.div
                                                        []
                                                        []
                                    in
                                    Html.div
                                        []
                                        [ header_
                                        , button
                                        ]

                        logo_ =
                            let
                                render url_ =
                                    Html.div
                                        []
                                        [ Html.img
                                            [ class "is-image-container-2"
                                            , src url_
                                            ]
                                            []
                                        ]

                                select global =
                                    Html.div
                                        [ class "file"
                                        ]
                                        [ Html.label
                                            [ class "file-label"
                                            ]
                                            [ Html.input
                                                [ id "dap-cool-creator-logo-selector"
                                                , class "file-input"
                                                , type_ "file"
                                                , onClick <|
                                                    FromCreator <|
                                                        CreatorMsg.Existing
                                                            global
                                                            ExistingMsg.SelectLogo
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
                                                    [ Html.text "select logo"
                                                    ]
                                                ]
                                            ]
                                        ]

                                upload =
                                    Html.button
                                        [ class "button is-dark"
                                        ]
                                        [ Html.text
                                            """upload
                                            """
                                        ]

                                buttons global =
                                    Html.div
                                        [ class "field has-addons is-centered"
                                        ]
                                        [ Html.p
                                            [ class "control"
                                            ]
                                            [ select global
                                            ]
                                        , Html.p
                                            [ class "control"
                                            ]
                                            [ upload
                                            ]
                                        ]
                            in
                            case initialized.logo of
                                Just url ->
                                    case role of
                                        Admin global logoForm ->
                                            case logoForm of
                                                LogoForm.Top ->
                                                    Html.div
                                                        []
                                                        [ render url
                                                        , buttons global
                                                        ]

                                                LogoForm.Selected file ->
                                                    Html.div
                                                        []
                                                        [ render file.dataUrl
                                                        , buttons global
                                                        ]

                                        Collector ->
                                            render url

                                Nothing ->
                                    case role of
                                        Admin global logoForm ->
                                            case logoForm of
                                                LogoForm.Top ->
                                                    Html.div
                                                        []
                                                        [ render "./images/upload/default-pfp.jpg"
                                                        , buttons global
                                                        ]

                                                LogoForm.Selected file ->
                                                    Html.div
                                                        []
                                                        [ render file.dataUrl
                                                        , buttons global
                                                        ]

                                        Collector ->
                                            render "./images/upload/default-pfp.jpg"

                        banner_ =
                            Html.div
                                []
                                []
                    in
                    ( bio_, logo_, banner_ )

                CreatorMetadata.UnInitialized ->
                    ( case role of
                        Admin hasWalletAndHandle _ ->
                            Html.div
                                []
                                [ Html.button
                                    [ onClick <|
                                        FromCreator <|
                                            CreatorMsg.Existing
                                                hasWalletAndHandle
                                                ExistingMsg.ProvisionMetadata
                                    ]
                                    [ Html.text
                                        """create storage for profile-picture & bio
                                        """
                                    ]
                                ]

                        Collector ->
                            Html.div
                                []
                                []
                    , Html.div
                        []
                        [ Html.img
                            [ class "is-image-container-2"
                            , src "./images/upload/default-pfp.jpg"
                            ]
                            []
                        ]
                    , Html.div
                        []
                        []
                    )
    in
    Html.div
        []
        [ Html.div
            [ class "columns"
            ]
            [ Html.div
                [ class "column is-2-desktop is-3-tablet has-text-centered-tablet"
                ]
                [ logo
                ]
            , Html.div
                [ class "column is-10-desktop is-9-tablet"
                ]
                [ Html.div
                    []
                    [ header0 role handle
                    ]
                , Html.div
                    []
                    [ bio
                    ]
                ]
            ]
        ]


header0 : Role -> Handle -> Html Msg
header0 role handle =
    Html.div
        []
        [ Html.div
            [ class "is-family-secondary is-light-text-container-6 is-size-6 is-light-text-container-6-mobile is-size-6-mobile is-italic"
            ]
            [ Html.text <| toString role
            ]
        , Html.div
            [ class "is-text-container-2 is-size-2 is-text-container-3-mobile is-size-3-mobile"
            ]
            [ Html.text handle
            ]
        ]


type Role
    = Admin HasWalletAndHandle LogoForm
    | Collector


toString : Role -> String
toString role =
    case role of
        Admin _ _ ->
            "Admin"

        Collector ->
            -- collectors see this as viewing a creator page
            "Creator"
