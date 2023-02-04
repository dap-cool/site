module View.Collect.FeaturedCreator exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class, src, style)
import Model.Collector.Collector as Collector
import Model.State.Global.FeaturedCreators exposing (FeaturedCreator, FeaturedCreators)
import Model.State.Local.Local as Local
import Msg.Msg exposing (Msg)


view : FeaturedCreators -> Html Msg
view featuredCreators =
    Html.div
        [ class "columns is-multiline is-mobile"
        ]
    <|
        List.map
            (\fc ->
                Html.div
                    [ class "column is-half-mobile is-one-third-tablet"
                    ]
                    [ view_ fc
                    ]
            )
            featuredCreators


view_ : FeaturedCreator -> Html Msg
view_ featuredCreator =
    let
        img =
            let
                render url =
                    Html.div
                        [ class "is-image-container-3"
                        ]
                        [ Html.img
                            [ style "width" "100%"
                            , src url
                            ]
                            []
                        ]
            in
            case featuredCreator.metadata.logo of
                Just url ->
                    render url

                Nothing ->
                    render "./images/upload/default-pfp.jpg"

        handle =
            Html.div
                [ class "is-text-container-4 is-size-4 is-text-container-5-mobile is-size-5-mobile has-text-centered is-family-secondary"
                ]
                [ Html.text featuredCreator.handle
                ]

        href =
            Html.div
                [ class "is-text-container-4 is-size-4 is-text-container-5-mobile is-size-5-mobile has-text-centered"
                ]
                [ Html.a
                    [ class "has-sky-blue-text"
                    , Local.href <|
                        Local.Collect <|
                            Collector.MaybeExistingCreator
                                featuredCreator.handle
                    , style "opacity" "90%"
                    ]
                    [ Html.text
                        """view collections
                        """
                    ]
                ]
    in
    Html.div
        [ class "is-featured-creator"
        ]
        [ img
        , Html.div
            [ class "mt-2"
            ]
            [ handle
            ]
        , Html.div
            [ class "mt-1"
            ]
            [ href
            ]
        ]
