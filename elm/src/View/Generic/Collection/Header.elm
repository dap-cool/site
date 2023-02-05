module View.Generic.Collection.Header exposing (Role(..), header0, view)

import FormatNumber
import FormatNumber.Locales exposing (usLocale)
import Html exposing (Html)
import Html.Attributes exposing (class, disabled, href, id, placeholder, src, style, target, type_)
import Html.Events exposing (onClick, onInput)
import Model.Collector.Collector as CollectorState
import Model.Creator.Existing.BioForm as BioForm exposing (BioForm)
import Model.Creator.Existing.LogoForm as LogoForm exposing (LogoForm)
import Model.CreatorMetadata as CreatorMetadata exposing (CreatorMetadata)
import Model.File exposing (File)
import Model.Handle exposing (Handle)
import Model.State.Global.HasWalletAndHandle exposing (HasWalletAndHandle)
import Model.State.Local.Local as Local
import Msg.Creator.Creator as CreatorMsg
import Msg.Creator.Existing.Existing as ExistingMsg
import Msg.Global as FromGlobal
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

                                upload form global =
                                    case form of
                                        BioForm.Empty ->
                                            Html.div
                                                []
                                                []

                                        BioForm.Valid valid ->
                                            Html.button
                                                [ class "button is-fullwidth"
                                                , onClick <|
                                                    FromCreator <|
                                                        CreatorMsg.Existing
                                                            global
                                                            (ExistingMsg.UploadBio valid)
                                                ]
                                                [ Html.text "upload"
                                                ]

                                        BioForm.Invalid _ ->
                                            Html.div
                                                []
                                                []

                                textarea form global =
                                    Html.div
                                        []
                                        [ Html.textarea
                                            [ class "textarea"
                                            , placeholder "write new bio"
                                            , onInput <|
                                                \s ->
                                                    FromCreator <|
                                                        CreatorMsg.Existing
                                                            global
                                                            (ExistingMsg.TypingBio
                                                                form
                                                                s
                                                            )
                                            ]
                                            []
                                        , Html.div
                                            []
                                            [ upload form global
                                            ]
                                        ]
                            in
                            case initialized.bio of
                                Just string ->
                                    case role of
                                        Admin global _ bioForm ->
                                            Html.div
                                                []
                                                [ header_
                                                , Html.div
                                                    [ class "mt-1 container is-text-container-3 is-size-3 is-text-container-4-mobile is-size-4-mobile"
                                                    ]
                                                    [ Html.text string
                                                    ]
                                                , Html.div
                                                    [ class "mt-2"
                                                    ]
                                                    [ textarea bioForm global
                                                    ]
                                                ]

                                        Collector ->
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
                                    case role of
                                        Admin global _ bioForm ->
                                            Html.div
                                                []
                                                [ header_
                                                , Html.div
                                                    [ class "mt-2"
                                                    ]
                                                    [ textarea bioForm global
                                                    ]
                                                ]

                                        Collector ->
                                            Html.div
                                                []
                                                [ header_
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
                                                    [ Html.text "new logo"
                                                    ]
                                                ]
                                            ]
                                        ]

                                upload global file =
                                    Html.button
                                        [ class "button is-dark"
                                        , onClick <|
                                            FromCreator <|
                                                CreatorMsg.Existing
                                                    global
                                                    (ExistingMsg.UploadLogo
                                                        file
                                                    )
                                        ]
                                        [ Html.text
                                            """upload
                                            """
                                        ]

                                buttons global file =
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
                                            [ upload global file
                                            ]
                                        ]
                            in
                            case initialized.logo of
                                Just url ->
                                    case role of
                                        Admin global logoForm _ ->
                                            case logoForm of
                                                LogoForm.Top ->
                                                    Html.div
                                                        []
                                                        [ render url
                                                        , select global
                                                        ]

                                                LogoForm.Selected file ->
                                                    Html.div
                                                        []
                                                        [ render file.dataUrl
                                                        , buttons global file
                                                        ]

                                        Collector ->
                                            render url

                                Nothing ->
                                    case role of
                                        Admin global logoForm _ ->
                                            case logoForm of
                                                LogoForm.Top ->
                                                    Html.div
                                                        []
                                                        [ render "./images/upload/default-pfp.jpg"
                                                        , select global
                                                        ]

                                                LogoForm.Selected file ->
                                                    Html.div
                                                        []
                                                        [ render file.dataUrl
                                                        , buttons global file
                                                        ]

                                        Collector ->
                                            render "./images/upload/default-pfp.jpg"

                        banner_ =
                            Html.div
                                []
                                []
                    in
                    ( bio_, logo_, banner_ )

                CreatorMetadata.UnInitialized shdwAta ->
                    ( case role of
                        Admin hasWalletAndHandle _ _ ->
                            let
                                normalized =
                                    Basics.toFloat shdwAta.balance / 1000000000

                                formatted =
                                    FormatNumber.format usLocale normalized
                            in
                            case ( normalized > 0.25, shdwAta.address ) of
                                ( True, Just address ) ->
                                    Html.div
                                        []
                                        [ Html.div
                                            [ class "table-container"
                                            ]
                                            [ Html.table
                                                [ class "table"
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
                                                    , Html.tr
                                                        []
                                                        [ Html.th
                                                            [ class "is-text-container-5 is-size-5"
                                                            ]
                                                            [ Html.text "storage-space"
                                                            ]
                                                        , Html.td
                                                            [ class "is-text-container-5 is-size-5"
                                                            ]
                                                            [ Html.button
                                                                [ onClick <|
                                                                    FromCreator <|
                                                                        CreatorMsg.Existing
                                                                            hasWalletAndHandle
                                                                            ExistingMsg.ProvisionMetadata
                                                                ]
                                                                [ Html.text
                                                                    """create
                                                                    """
                                                                ]
                                                            ]
                                                        ]
                                                    ]
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
                                                [ class "table"
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
                                                            [ Html.text "storage-space"
                                                            ]
                                                        , Html.td
                                                            [ class "is-text-container-5 is-size-5"
                                                            ]
                                                            [ Html.button
                                                                [ onClick <|
                                                                    FromCreator <|
                                                                        CreatorMsg.Existing
                                                                            hasWalletAndHandle
                                                                            ExistingMsg.ProvisionMetadata
                                                                , disabled True
                                                                ]
                                                                [ Html.text
                                                                    """create
                                                                    """
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
                    [ class "mt-3"
                    ]
                    [ bio
                    ]
                ]
            ]
        ]


header0 : Role -> Handle -> Html Msg
header0 role handle =
    let
        render =
            case role of
                Admin _ _ _ ->
                    Html.a
                        [ class "has-sky-blue-text"
                        , style "opacity" "90%"
                        , Local.href <|
                            Local.Collect <|
                                CollectorState.MaybeExistingCreator
                                    handle
                        ]
                        [ Html.text handle
                        ]

                Collector ->
                    Html.text handle
    in
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
            [ render
            ]
        ]


type Role
    = Admin HasWalletAndHandle LogoForm BioForm
    | Collector


toString : Role -> String
toString role =
    case role of
        Admin _ _ _ ->
            "Admin"

        Collector ->
            -- collectors see this as viewing a creator page
            "Creator"
