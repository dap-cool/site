module Main exposing (main)

-- MAIN

import Browser
import Browser.Navigation as Nav
import Model.AlmostExistingCollection as AlmostExistingCollection
import Model.AlmostNewCollection as AlmostNewCollection
import Model.Collection as Collection
import Model.Collector.Collector as Collector
import Model.Collector.WithCollection as WithCollection
import Model.Collector.WithCollections as WithCollections
import Model.Creator.Creator as Creator
import Model.Creator.Existing.Existing as ExistingCreator
import Model.Creator.Existing.HandleFormStatus as ExistingHandleFormStatus
import Model.Creator.Existing.NewCollection as NewCollection
import Model.Creator.New.New as NewCreator
import Model.Global as Global
import Model.Handle as Handle
import Model.Model as Model exposing (Model)
import Model.State as State exposing (State(..))
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
                    case ( model.state, state ) of
                        ( Valid global _, Valid _ local ) ->
                            { model | state = Valid global local, url = url }

                        _ ->
                            { model | state = state, url = url }
            in
            case bump.state of
                Valid global (State.Collect (Collector.MaybeExistingCreator handle)) ->
                    ( bump
                    , Cmd.batch
                        [ sender <|
                            Sender.encode <|
                                { sender = Sender.Collect <| FromCollector.HandleForm <| Handle.Confirm handle
                                , global = global
                                , more = Handle.encode handle
                                }
                        , resetViewport
                        ]
                    )

                Valid global (State.Collect (Collector.MaybeExistingCollection handle index)) ->
                    ( bump
                    , Cmd.batch
                        [ sender <|
                            Sender.encode <|
                                { sender = Sender.Collect <| FromCollector.SelectCollection handle index
                                , global = global
                                , more = AlmostExistingCollection.encode { handle = handle, index = index }
                                }
                        , resetViewport
                        ]
                    )

                Valid global (State.Create (Creator.MaybeExisting handle)) ->
                    ( bump
                    , Cmd.batch
                        [ sender <|
                            Sender.encode <|
                                { sender =
                                    Sender.Create <|
                                        FromCreator.Existing <|
                                            FromExistingCreator.ConfirmHandle handle
                                , global = global
                                , more = Handle.encode handle
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

        FromCreator global from ->
            case from of
                FromCreator.New new ->
                    case new of
                        FromNewCreator.StartHandleForm ->
                            ( { model
                                | state =
                                    Valid global <|
                                        State.Create <|
                                            Creator.New <|
                                                NewCreator.TypingHandle ""
                              }
                            , Cmd.none
                            )

                        FromNewCreator.HandleForm handleForm ->
                            case handleForm of
                                Handle.Typing string ->
                                    ( { model
                                        | state =
                                            Valid global <|
                                                State.Create <|
                                                    Creator.New <|
                                                        NewCreator.TypingHandle <|
                                                            Handle.normalize string
                                      }
                                    , Cmd.none
                                    )

                                Handle.Confirm handle ->
                                    ( { model
                                        | state =
                                            Valid global <|
                                                State.Create <|
                                                    Creator.New <|
                                                        NewCreator.WaitingForHandleConfirmation
                                      }
                                    , sender <|
                                        Sender.encode <|
                                            { sender = Sender.Create from
                                            , global = global
                                            , more = Handle.encode handle
                                            }
                                    )

                FromCreator.Existing existing ->
                    case existing of
                        FromExistingCreator.ConfirmHandle handle ->
                            ( { model
                                | state =
                                    Valid global <|
                                        State.Create <|
                                            Creator.Existing <|
                                                ExistingCreator.AuthorizingFromUrl
                                                    ExistingHandleFormStatus.WaitingForHandleConfirmation
                              }
                            , sender <|
                                Sender.encode <|
                                    { sender = Sender.Create from
                                    , global = global
                                    , more = Handle.encode handle
                                    }
                            )

                        FromExistingCreator.StartCreatingNewCollection ->
                            ( { model
                                | state =
                                    Valid global <|
                                        State.Create <|
                                            Creator.Existing <|
                                                ExistingCreator.CreatingNewCollection <|
                                                    NewCollection.Input
                                                        NewCollection.default
                              }
                            , Cmd.none
                            )

                        FromExistingCreator.NewCollectionForm newCollectionForm ->
                            case newCollectionForm of
                                NewCollectionForm.Name stringForm newCollection ->
                                    let
                                        bumpNewCollection =
                                            { newCollection | name = stringForm }
                                    in
                                    ( { model
                                        | state =
                                            Valid global <|
                                                State.Create <|
                                                    Creator.Existing <|
                                                        ExistingCreator.CreatingNewCollection <|
                                                            NewCollection.Input
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
                                            Valid global <|
                                                State.Create <|
                                                    Creator.Existing <|
                                                        ExistingCreator.CreatingNewCollection <|
                                                            NewCollection.Input
                                                                bumpNewCollection
                                      }
                                    , Cmd.none
                                    )

                                NewCollectionForm.Image ->
                                    ( model
                                    , sender <| Sender.encode0 <| Sender.Create from
                                      -- prepare image form events
                                    )

                        FromExistingCreator.CreateNewCollection almostNewCollection ->
                            ( model
                              -- todo; waiting without changing dom
                            , sender <|
                                Sender.encode <|
                                    { sender = Sender.Create from
                                    , global = global
                                    , more = AlmostNewCollection.encode almostNewCollection
                                    }
                            )

                        FromExistingCreator.MarkNewCollection collection ->
                            ( { model
                                | state =
                                    Valid global <|
                                        State.Create <|
                                            Creator.Existing <|
                                                ExistingCreator.CreatingNewCollection <|
                                                    NewCollection.WaitingForMarkNft collection
                              }
                            , sender <|
                                Sender.encode <|
                                    { sender = Sender.Create from
                                    , global = global
                                    , more = Collection.encode collection
                                    }
                            )

                        FromExistingCreator.SelectCollection collection ->
                            ( { model
                                | state =
                                    Valid global <|
                                        State.Create <|
                                            Creator.Existing <|
                                                ExistingCreator.SelectedCollection
                                                    collection
                              }
                            , Cmd.none
                            )

        FromCollector global from ->
            case from of
                FromCollector.HandleForm form ->
                    case form of
                        Handle.Typing string ->
                            ( { model
                                | state =
                                    Valid global <|
                                        State.Collect <|
                                            Collector.TypingHandle <|
                                                Handle.normalize string
                              }
                            , Cmd.none
                            )

                        Handle.Confirm string ->
                            ( { model | state = Valid global <| State.Collect <| Collector.WaitingForHandleConfirmation }
                            , sender <|
                                Sender.encode <|
                                    { sender = Sender.Collect from
                                    , global = global
                                    , more = Handle.encode string
                                    }
                            )

                FromCollector.SelectCollection _ _ ->
                    ( model
                    , Cmd.none
                    )

                FromCollector.PurchaseCollection handle int ->
                    ( { model | state = Valid global <| State.Collect <| Collector.WaitingForPurchase }
                    , sender <|
                        Sender.encode <|
                            { sender = Sender.Collect from
                            , global = global
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
                        Ok ( global, maybeListener ) ->
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
                                                                            Valid global <|
                                                                                State.Create <|
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
                                                                            Valid global <|
                                                                                State.Create <|
                                                                                    Creator.New <|
                                                                                        NewCreator.HandleAlreadyExists
                                                                                            handle
                                                                    }
                                                            in
                                                            Listener.decode model json Handle.decode f

                                                        ToNewCreator.NewHandleSuccess ->
                                                            ( { model
                                                                | state =
                                                                    Valid global <|
                                                                        State.Create <|
                                                                            Creator.Existing <|
                                                                                ExistingCreator.Top []
                                                              }
                                                            , Cmd.none
                                                            )

                                                ToCreator.Existing existing ->
                                                    case existing of
                                                        ToExistingCreator.HandleForm handleFormStatus ->
                                                            case handleFormStatus of
                                                                ToExistingCreator.Invalid ->
                                                                    let
                                                                        f handle =
                                                                            { model
                                                                                | state =
                                                                                    Valid global <|
                                                                                        State.Create <|
                                                                                            Creator.Existing <|
                                                                                                ExistingCreator.AuthorizingFromUrl <|
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
                                                                                    Valid global <|
                                                                                        State.Create <|
                                                                                            Creator.Existing <|
                                                                                                ExistingCreator.AuthorizingFromUrl <|
                                                                                                    ExistingHandleFormStatus.HandleDoesNotExist
                                                                                                        handle
                                                                            }
                                                                    in
                                                                    Listener.decode model json Handle.decode f

                                                                ToExistingCreator.UnAuthorized ->
                                                                    ( { model
                                                                        | state =
                                                                            Valid global <|
                                                                                State.Create <|
                                                                                    Creator.Existing <|
                                                                                        ExistingCreator.AuthorizingFromUrl <|
                                                                                            ExistingHandleFormStatus.UnAuthorized
                                                                      }
                                                                    , Cmd.none
                                                                    )

                                                        ToExistingCreator.CreatedNewCollection ->
                                                            let
                                                                f collection =
                                                                    { model
                                                                        | state =
                                                                            Valid global <|
                                                                                State.Create <|
                                                                                    Creator.Existing <|
                                                                                        ExistingCreator.CreatingNewCollection <|
                                                                                            NewCollection.HasCreateNft
                                                                                                collection
                                                                    }
                                                            in
                                                            Listener.decode model json Collection.decode f

                                                        ToExistingCreator.MarkedNewCollection ->
                                                            let
                                                                f collection =
                                                                    { model
                                                                        | state =
                                                                            Valid global <|
                                                                                State.Create <|
                                                                                    Creator.Existing <|
                                                                                        ExistingCreator.CreatingNewCollection <|
                                                                                            NewCollection.Done
                                                                                                collection
                                                                    }
                                                            in
                                                            Listener.decode model json Collection.decode f

                                                        ToExistingCreator.Authorized ->
                                                            let
                                                                f collections =
                                                                    { model
                                                                        | state =
                                                                            Valid global <|
                                                                                State.Create <|
                                                                                    Creator.Existing <|
                                                                                        ExistingCreator.Top <|
                                                                                            collections
                                                                    }
                                                            in
                                                            Listener.decode model json Collection.decodeList f

                                        -- found msg for collector
                                        Listener.Collect toCollector ->
                                            -- what is creator doing?
                                            case toCollector of
                                                ToCollector.HandleInvalid ->
                                                    let
                                                        f handle =
                                                            { model
                                                                | state =
                                                                    Valid global <|
                                                                        State.Collect <|
                                                                            Collector.HandleInvalid handle
                                                            }
                                                    in
                                                    Listener.decode model json Handle.decode f

                                                ToCollector.HandleDoesNotExist ->
                                                    let
                                                        f handle =
                                                            { model
                                                                | state =
                                                                    Valid global <|
                                                                        State.Collect <|
                                                                            Collector.HandleDoesNotExist handle
                                                            }
                                                    in
                                                    Listener.decode model json Handle.decode f

                                                ToCollector.HandleFound ->
                                                    let
                                                        f withCollections =
                                                            { model
                                                                | state =
                                                                    Valid global <|
                                                                        State.Collect <|
                                                                            Collector.SelectedCreator withCollections
                                                            }
                                                    in
                                                    Listener.decode model json WithCollections.decode f

                                                ToCollector.CollectionSelected ->
                                                    let
                                                        f withCollection =
                                                            { model
                                                                | state =
                                                                    Valid global <|
                                                                        State.Collect <|
                                                                            Collector.SelectedCollection withCollection
                                                            }
                                                    in
                                                    Listener.decode model json WithCollection.decode f

                                                ToCollector.CollectionPurchased ->
                                                    let
                                                        f withCollection =
                                                            { model
                                                                | state =
                                                                    Valid global <|
                                                                        State.Collect <|
                                                                            Collector.PurchaseSuccess withCollection
                                                            }
                                                    in
                                                    Listener.decode model json WithCollection.decode f

                                        Listener.Global ->
                                            case model.state of
                                                Valid _ local ->
                                                    ( { model | state = Valid global local }
                                                    , Cmd.none
                                                    )

                                                Error _ ->
                                                    ( model
                                                    , Cmd.none
                                                    )

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

        Global fromGlobal ->
            case model.state of
                Valid _ local ->
                    ( { model | state = Valid Global.Connecting local }
                    , sender <| Sender.encode0 <| Sender.Global fromGlobal
                    )

                Error _ ->
                    ( model
                    , Cmd.none
                    )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        html =
            case model.state of
                Valid global (State.Create creator) ->
                    View.Hero.view global <| View.Create.Create.body global creator

                Valid global (State.Collect collector) ->
                    View.Hero.view global <| View.Collect.Collect.body global collector

                Error error ->
                    View.Hero.view Global.default (View.Error.Error.body error)
    in
    { title = "dap.cool"
    , body =
        [ html
        ]
    }
