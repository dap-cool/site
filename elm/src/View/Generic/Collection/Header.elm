module View.Generic.Collection.Header exposing (Role(..), header0, view)

import Html exposing (Html)
import Html.Attributes exposing (class, src)
import Model.CreatorMetadata as CreatorMetadata exposing (CreatorMetadata)
import Model.Handle exposing (Handle)
import Msg.Msg exposing (Msg)


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
                                                Admin ->
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
                                f url_ =
                                    Html.div
                                        []
                                        [ Html.img
                                            [ class "is-image-container-2"
                                            , src url_
                                            ]
                                            []
                                        ]
                            in
                            case initialized.logo of
                                Just url ->
                                    f url

                                Nothing ->
                                    let
                                        button =
                                            case role of
                                                Admin ->
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
                                        [ f "./images/upload/default-pfp.jpg"
                                        , button
                                        ]

                        banner_ =
                            Html.div
                                []
                                []
                    in
                    ( bio_, logo_, banner_ )

                CreatorMetadata.UnInitialized ->
                    ( Html.div
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
                [ class "column is-2 has-text-centered"
                ]
                [ logo
                ]
            , Html.div
                [ class "column is-10"
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
    = Admin
    | Collector


toString : Role -> String
toString role =
    case role of
        Admin ->
            "Admin"

        Collector ->
            -- collectors see this as viewing a creator page
            "Creator"
