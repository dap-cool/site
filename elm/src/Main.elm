module Main exposing (main)

-- MAIN

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Model.AlmostExistingCollection as AlmostExistingCollection
import Model.AlmostNewCollection as AlmostCollection
import Model.Collector.Collector as Collector
import Model.Creator.Creator as Creator
import Model.Creator.Existing.Authorized as Authorized
import Model.Creator.Existing.Existing as ExistingCreator
import Model.Creator.Existing.HandleFormStatus as ExistingHandleFormStatus
import Model.Creator.Existing.NewCollection as NewCollection
import Model.Creator.New.New as NewCreator
import Model.Handle as Handle
import Model.Model as Model exposing (Model)
import Model.State as State exposing (State(..))
import Model.WithCollection as WithCollection
import Model.WithCollections as WithCollections
import Msg.Collector.Collector as FromCollector
import Msg.Creator.Creator as FromCreator
import Msg.Creator.Existing.Existing as FromExistingCreator
import Msg.Creator.Existing.NewCollectionForm as NewCollectionForm
import Msg.Creator.New.New as FromNewCreator
import Msg.Js as JsMsg
import Msg.Msg exposing (Msg(..), resetViewport)
import Sub.Listener.Collector.Collector as ToCollector
import Sub.Listener.Creator.Creator as ToCreator
import Sub.Listener.Creator.Existing as ToExistingCreator
import Sub.Listener.Creator.New as ToNewCreator
import Sub.Listener.Listener as Listener
import Sub.Sender.Ports exposing (sender)
import Sub.Sender.Sender as Sender
import Sub.Sub as Sub
import Url
import View.Collect.Collect
import View.Create.Create
import View.Error.Error
import View.Hero


main : Program () Model Msg
main =
    Browser.application
        { init = Model.init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.subs
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UrlChanged url ->
            let
                state : State
                state =
                    State.parse url

                bump : Model
                bump =
                    { model | state = state, url = url }
            in
            case state of
                Collect (Collector.MaybeExistingCreator handle) ->
                    ( bump
                    , Cmd.batch
                        [ sender <|
                            Sender.encode <|
                                { sender = Sender.Collect <| FromCollector.HandleForm <| Handle.Confirm handle
                                , more = Handle.encode handle
                                }
                        , resetViewport
                        ]
                    )

                Collect (Collector.MaybeExistingCollection handle index) ->
                    ( bump
                    , Cmd.batch
                        [ sender <|
                            Sender.encode <|
                                { sender = Sender.Collect <| FromCollector.SelectCollection handle index
                                , more = AlmostExistingCollection.encode { handle = handle, index = index }
                                }
                        , resetViewport
                        ]
                    )

                _ ->
                    ( bump
                    , resetViewport
                    )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        FromCreator from ->
            case from of
                FromCreator.New new ->
                    case new of
                        FromNewCreator.StartHandleForm ->
                            ( { model | state = Create <| Creator.New <| NewCreator.TypingHandle "" }
                            , Cmd.none
                            )

                        FromNewCreator.HandleForm handleForm ->
                            case handleForm of
                                Handle.Typing string ->
                                    ( { model
                                        | state =
                                            Create <|
                                                Creator.New <|
                                                    NewCreator.TypingHandle <|
                                                        Handle.normalize string
                                      }
                                    , Cmd.none
                                    )

                                Handle.Confirm handle ->
                                    ( { model
                                        | state =
                                            Create <|
                                                Creator.New <|
                                                    NewCreator.WaitingForHandleConfirmation
                                      }
                                    , sender <|
                                        Sender.encode <|
                                            { sender = Sender.Create from, more = Handle.encode handle }
                                    )

                FromCreator.Existing existing ->
                    case existing of
                        FromExistingCreator.StartHandleForm ->
                            ( { model
                                | state =
                                    Create <|
                                        Creator.Existing <|
                                            ExistingCreator.HandleForm <|
                                                ExistingHandleFormStatus.TypingHandle ""
                              }
                            , Cmd.none
                            )

                        FromExistingCreator.HandleForm handleForm ->
                            case handleForm of
                                Handle.Typing string ->
                                    ( { model
                                        | state =
                                            Create <|
                                                Creator.Existing <|
                                                    ExistingCreator.HandleForm <|
                                                        ExistingHandleFormStatus.TypingHandle <|
                                                            Handle.normalize string
                                      }
                                    , Cmd.none
                                    )

                                Handle.Confirm handle ->
                                    ( { model
                                        | state =
                                            Create <|
                                                Creator.Existing <|
                                                    ExistingCreator.HandleForm
                                                        ExistingHandleFormStatus.WaitingForHandleConfirmation
                                      }
                                    , sender <|
                                        Sender.encode <|
                                            { sender = Sender.Create from, more = Handle.encode handle }
                                    )

                        FromExistingCreator.StartCreatingNewCollection wallet handle ->
                            ( { model
                                | state =
                                    Create <|
                                        Creator.Existing <|
                                            ExistingCreator.Authorized <|
                                                Authorized.CreatingNewCollection wallet handle NewCollection.default
                              }
                            , Cmd.none
                            )

                        FromExistingCreator.NewCollectionForm wallet handle newCollectionForm ->
                            case newCollectionForm of
                                NewCollectionForm.Name stringForm newCollection ->
                                    let
                                        bumpNewCollection =
                                            { newCollection | name = stringForm }
                                    in
                                    ( { model
                                        | state =
                                            Create <|
                                                Creator.Existing <|
                                                    ExistingCreator.Authorized <|
                                                        Authorized.CreatingNewCollection
                                                            wallet
                                                            handle
                                                            bumpNewCollection
                                      }
                                    , Cmd.none
                                    )

                                NewCollectionForm.Symbol stringForm newCollection ->
                                    let
                                        bumpNewCollection =
                                            { newCollection | symbol = stringForm }
                                    in
                                    ( { model
                                        | state =
                                            Create <|
                                                Creator.Existing <|
                                                    ExistingCreator.Authorized <|
                                                        Authorized.CreatingNewCollection
                                                            wallet
                                                            handle
                                                            bumpNewCollection
                                      }
                                    , Cmd.none
                                    )

                                NewCollectionForm.Image ->
                                    ( model
                                    , sender <| Sender.encode0 <| Sender.Create from
                                      -- prepare image form events
                                    )

                        FromExistingCreator.CreateNewCollection wallet almostCollection ->
                            ( model
                            , sender <|
                                Sender.encode <|
                                    { sender = Sender.Create from, more = AlmostCollection.encode almostCollection }
                            )

                        FromExistingCreator.SelectCollection wallet handle collection ->
                            ( { model
                                | state =
                                    Create <|
                                        Creator.Existing <|
                                            ExistingCreator.Authorized <|
                                                Authorized.SelectedCollection
                                                    wallet
                                                    handle
                                                    collection
                              }
                            , Cmd.none
                            )

        FromCollector from ->
            case from of
                FromCollector.HandleForm form ->
                    case form of
                        Handle.Typing string ->
                            ( { model | state = Collect <| Collector.TypingHandle <| Handle.normalize string }
                            , Cmd.none
                            )

                        Handle.Confirm string ->
                            ( { model | state = Collect <| Collector.WaitingForHandleConfirmation }
                            , sender <|
                                Sender.encode <|
                                    { sender = Sender.Collect from, more = Handle.encode string }
                            )

                FromCollector.SelectCollection _ _ ->
                    ( model
                    , Cmd.none
                    )

                FromCollector.PurchaseCollection handle int ->
                    ( { model | state = Collect <| Collector.WaitingForPurchase }
                    , sender <|
                        Sender.encode <|
                            { sender = Sender.Collect from
                            , more = AlmostExistingCollection.encode { handle = handle, index = int }
                            }
                    )

        FromJs fromJsMsg ->
            case fromJsMsg of
                -- JS sending success for decoding
                JsMsg.Success json ->
                    -- decode
                    case Listener.decode0 json of
                        -- decode success
                        Ok maybeListener ->
                            -- look for role
                            case maybeListener of
                                -- found role
                                Just listener ->
                                    -- which role?
                                    case listener of
                                        -- found msg for creator
                                        Listener.Create toCreator ->
                                            -- what is creator doing?
                                            case toCreator of
                                                ToCreator.New new ->
                                                    case new of
                                                        ToNewCreator.HandleInvalid ->
                                                            let
                                                                f handle =
                                                                    { model
                                                                        | state =
                                                                            Create <|
                                                                                Creator.New <|
                                                                                    NewCreator.HandleInvalid handle
                                                                    }
                                                            in
                                                            Listener.decode model json Handle.decode f

                                                        ToNewCreator.HandleAlreadyExists ->
                                                            let
                                                                f handle =
                                                                    { model
                                                                        | state =
                                                                            Create <|
                                                                                Creator.New <|
                                                                                    NewCreator.HandleAlreadyExists
                                                                                        handle
                                                                    }
                                                            in
                                                            Listener.decode model json Handle.decode f

                                                        ToNewCreator.NewHandleSuccess ->
                                                            let
                                                                f handleWithWallet =
                                                                    { model
                                                                        | state =
                                                                            Create <|
                                                                                Creator.Existing <|
                                                                                    ExistingCreator.Authorized <|
                                                                                        Authorized.Top
                                                                                            { handle = handleWithWallet.handle
                                                                                            , wallet = Just handleWithWallet.wallet
                                                                                            , collections = []
                                                                                            }
                                                                    }
                                                            in
                                                            Listener.decode model json Handle.decodeWithWallet f

                                                ToCreator.Existing existing ->
                                                    case existing of
                                                        ToExistingCreator.HandleForm handleFormStatus ->
                                                            case handleFormStatus of
                                                                ToExistingCreator.Invalid ->
                                                                    let
                                                                        f handle =
                                                                            { model
                                                                                | state =
                                                                                    Create <|
                                                                                        Creator.Existing <|
                                                                                            ExistingCreator.HandleForm <|
                                                                                                ExistingHandleFormStatus.HandleInvalid
                                                                                                    handle
                                                                            }
                                                                    in
                                                                    Listener.decode model json Handle.decode f

                                                                ToExistingCreator.DoesNotExist ->
                                                                    let
                                                                        f handle =
                                                                            { model
                                                                                | state =
                                                                                    Create <|
                                                                                        Creator.Existing <|
                                                                                            ExistingCreator.HandleForm <|
                                                                                                ExistingHandleFormStatus.HandleDoesNotExist
                                                                                                    handle
                                                                            }
                                                                    in
                                                                    Listener.decode model json Handle.decode f

                                                                ToExistingCreator.UnAuthorized ->
                                                                    let
                                                                        f handleWithWallet =
                                                                            { model
                                                                                | state =
                                                                                    Create <|
                                                                                        Creator.Existing <|
                                                                                            ExistingCreator.HandleForm <|
                                                                                                ExistingHandleFormStatus.UnAuthorized
                                                                                                    handleWithWallet.wallet
                                                                                                    handleWithWallet.handle
                                                                            }
                                                                    in
                                                                    Listener.decode model json Handle.decodeWithWallet f

                                                        ToExistingCreator.Authorized ->
                                                            let
                                                                f withCollections =
                                                                    { model
                                                                        | state =
                                                                            Create <|
                                                                                Creator.Existing <|
                                                                                    ExistingCreator.Authorized <|
                                                                                        Authorized.Top
                                                                                            withCollections
                                                                    }
                                                            in
                                                            Listener.decode model json WithCollections.decode f

                                        -- found msg for collector
                                        Listener.Collect toCollector ->
                                            -- what is creator doing?
                                            case toCollector of
                                                ToCollector.HandleInvalid ->
                                                    let
                                                        f handle =
                                                            { model
                                                                | state =
                                                                    Collect <|
                                                                        Collector.HandleInvalid handle
                                                            }
                                                    in
                                                    Listener.decode model json Handle.decode f

                                                ToCollector.HandleDoesNotExist ->
                                                    let
                                                        f handle =
                                                            { model
                                                                | state =
                                                                    Collect <|
                                                                        Collector.HandleDoesNotExist handle
                                                            }
                                                    in
                                                    Listener.decode model json Handle.decode f

                                                ToCollector.HandleFound ->
                                                    let
                                                        f withCollections =
                                                            { model
                                                                | state =
                                                                    Collect <|
                                                                        Collector.SelectedCreator withCollections
                                                            }
                                                    in
                                                    Listener.decode model json WithCollections.decode f

                                                ToCollector.CollectionSelected ->
                                                    let
                                                        f withCollection =
                                                            { model
                                                                | state =
                                                                    Collect <|
                                                                        Collector.SelectedCollection withCollection
                                                            }
                                                    in
                                                    Listener.decode model json WithCollection.decode f

                                                ToCollector.CollectionPurchased ->
                                                    let
                                                        f withCollection =
                                                            { model
                                                                | state =
                                                                    Collect <|
                                                                        Collector.PurchaseSuccess withCollection
                                                            }
                                                    in
                                                    Listener.decode model json WithCollection.decode f

                                -- undefined role
                                Nothing ->
                                    let
                                        message =
                                            String.join
                                                " "
                                                [ "Invalid role sent from client:"
                                                , json
                                                ]
                                    in
                                    ( { model | state = Error message }
                                    , Cmd.none
                                    )

                        -- error from decoder
                        Err string ->
                            ( { model | state = Error string }
                            , Cmd.none
                            )

                -- JS sending error to raise
                JsMsg.Error string ->
                    ( { model | state = Error string }
                    , Cmd.none
                    )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        hero : Html Msg -> Html Msg
        hero =
            View.Hero.view

        html =
            case model.state of
                Create creator ->
                    hero <| View.Create.Create.body creator

                Collect collector ->
                    hero <| View.Collect.Collect.body collector

                Error error ->
                    hero (View.Error.Error.body error)
    in
    { title = "somos-crowd"
    , body =
        [ html
        ]
    }
