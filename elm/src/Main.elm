module Main exposing (main)

-- MAIN

import Browser
import Browser.Navigation as Nav
import Model.AlmostExistingCollection as AlmostExistingCollection
import Model.Collection as Collection
import Model.Collector.Collector as Collector
import Model.Collector.WithCollection as WithCollectionForCollector
import Model.Collector.WithCollections as WithCollections
import Model.Creator.Creator as Creator
import Model.Creator.Existing.Existing as ExistingCreator
import Model.Creator.Existing.NewCollection as NewCollection
import Model.Creator.Existing.WithCollection as WithCollectionForCreator
import Model.Creator.New.New as NewCreator
import Model.Handle as Handle
import Model.Model as Model exposing (Model)
import Model.State.Exception.Exception as Exception
import Model.State.Global.Global as Global
import Model.State.Global.HasWallet as HasWallet
import Model.State.Global.HasWalletAndHandle as HasWalletAndHandle
import Model.State.Local.Local as Local exposing (Local)
import Msg.Collector.Collector as FromCollector
import Msg.Creator.Creator as FromCreator
import Msg.Creator.Existing.Existing as FromExistingCreator
import Msg.Creator.Existing.NewCollectionForm as NewCollectionForm
import Msg.Creator.New.New as FromNewCreator
import Msg.Js as JsMsg
import Msg.Msg exposing (Msg(..), resetViewport)
import Sub.Listener.Global.Global as ToGlobal
import Sub.Listener.Listener as Listener
import Sub.Listener.Local.Collector.Collector as ToCollector
import Sub.Listener.Local.Creator.Creator as ToCreator
import Sub.Listener.Local.Creator.Existing as ToExistingCreator
import Sub.Listener.Local.Creator.New as ToNewCreator
import Sub.Listener.Local.Local as ToLocal
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
                local : Local
                local =
                    Local.parse url

                bump : Model
                bump =
                    { model
                        | state =
                            { local = local
                            , global = model.state.global
                            , exception = model.state.exception
                            }
                        , url = url
                    }
            in
            case local of
                Local.Create _ ->
                    case model.state.global of
                        Global.HasWalletAndHandle hasWalletAndHandle ->
                            ( { model
                                | state =
                                    { local = Local.Create <| Creator.Existing hasWalletAndHandle <| ExistingCreator.Top
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
                              }
                            , Cmd.none
                            )

                        _ ->
                            ( { model
                                | state =
                                    { local = Local.Create <| Creator.New <| NewCreator.Top
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
                              }
                            , Cmd.none
                            )

                Local.Collect (Collector.MaybeExistingCreator handle) ->
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

                Local.Collect (Collector.MaybeExistingCollection handle index) ->
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
                            ( { model
                                | state =
                                    { local =
                                        Local.Create <|
                                            Creator.New <|
                                                NewCreator.TypingHandle ""
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
                              }
                            , Cmd.none
                            )

                        FromNewCreator.HandleForm handleForm ->
                            case handleForm of
                                Handle.Typing string ->
                                    ( { model
                                        | state =
                                            { local =
                                                Local.Create <|
                                                    Creator.New <|
                                                        NewCreator.TypingHandle <|
                                                            Handle.normalize string
                                            , global = model.state.global
                                            , exception = model.state.exception
                                            }
                                      }
                                    , Cmd.none
                                    )

                                Handle.Confirm handle ->
                                    ( { model
                                        | state =
                                            { local =
                                                Local.Create <|
                                                    Creator.New <|
                                                        NewCreator.WaitingForHandleConfirmation
                                            , global = model.state.global
                                            , exception = model.state.exception
                                            }
                                      }
                                    , sender <|
                                        Sender.encode <|
                                            { sender = Sender.Create from
                                            , more = Handle.encode handle
                                            }
                                    )

                FromCreator.Existing hasWalletAndHandle existing ->
                    case existing of
                        FromExistingCreator.StartCreatingNewCollection ->
                            ( { model
                                | state =
                                    { local =
                                        Local.Create <|
                                            Creator.Existing hasWalletAndHandle <|
                                                ExistingCreator.CreatingNewCollection <|
                                                    NewCollection.Input <|
                                                        NewCollection.No
                                                            NewCollection.default
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
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
                                            { local =
                                                Local.Create <|
                                                    Creator.Existing hasWalletAndHandle <|
                                                        ExistingCreator.CreatingNewCollection <|
                                                            NewCollection.Input <|
                                                                NewCollection.No
                                                                    bumpNewCollection
                                            , global = model.state.global
                                            , exception = model.state.exception
                                            }
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
                                            { local =
                                                Local.Create <|
                                                    Creator.Existing hasWalletAndHandle <|
                                                        ExistingCreator.CreatingNewCollection <|
                                                            NewCollection.Input <|
                                                                NewCollection.No
                                                                    bumpNewCollection
                                            , global = model.state.global
                                            , exception = model.state.exception
                                            }
                                      }
                                    , Cmd.none
                                    )

                                NewCollectionForm.Image ->
                                    ( model
                                    , sender <| Sender.encode0 <| Sender.Create from
                                      -- prepare image form events
                                    )

                        FromExistingCreator.CreateNewCollection metaForm ->
                            let
                                form =
                                    { step = 1
                                    , retries = 0
                                    , meta = metaForm
                                    , shdw = Nothing
                                    }
                            in
                            ( { model
                                | state =
                                    { local =
                                        Local.Create <|
                                            Creator.Existing hasWalletAndHandle <|
                                                ExistingCreator.CreatingNewCollection <|
                                                    NewCollection.Input <|
                                                        NewCollection.Yes
                                                            form
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
                              }
                            , sender <|
                                Sender.encode <|
                                    { sender = Sender.Create from
                                    , more = NewCollection.encode form
                                    }
                            )

                        FromExistingCreator.MarkNewCollection collection ->
                            ( { model
                                | state =
                                    { local = model.state.local
                                    , global = model.state.global
                                    , exception = Exception.Waiting
                                    }
                              }
                            , sender <|
                                Sender.encode <|
                                    { sender = Sender.Create from
                                    , more = Collection.encode collection
                                    }
                            )

                        FromExistingCreator.SelectCollection collection ->
                            ( { model
                                | state =
                                    { local =
                                        Local.Create <|
                                            Creator.Existing hasWalletAndHandle <|
                                                ExistingCreator.SelectedCollection
                                                    collection
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
                              }
                            , Cmd.none
                            )

        FromCollector from ->
            case from of
                FromCollector.HandleForm form ->
                    case form of
                        Handle.Typing string ->
                            ( { model
                                | state =
                                    { local =
                                        Local.Collect <|
                                            Collector.TypingHandle <|
                                                Handle.normalize string
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
                              }
                            , Cmd.none
                            )

                        Handle.Confirm string ->
                            ( { model
                                | state =
                                    { local = Local.Collect <| Collector.WaitingForHandleConfirmation
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
                              }
                            , sender <|
                                Sender.encode <|
                                    { sender = Sender.Collect from
                                    , more = Handle.encode string
                                    }
                            )

                FromCollector.SelectCollection _ _ ->
                    ( model
                      -- href handles this state change
                    , Cmd.none
                    )

                FromCollector.PrintCopy handle int ->
                    ( { model
                        | state =
                            { local = model.state.local
                            , global = model.state.global
                            , exception = Exception.Waiting
                            }
                      }
                    , sender <|
                        Sender.encode <|
                            { sender = Sender.Collect from
                            , more = AlmostExistingCollection.encode { handle = handle, index = int }
                            }
                    )

                FromCollector.MarkCopy handle int ->
                    ( { model
                        | state =
                            { local = model.state.local
                            , global = model.state.global
                            , exception = Exception.Waiting
                            }
                      }
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
                                        -- found msg for local update
                                        Listener.Local toLocal ->
                                            case toLocal of
                                                -- found msg for creator
                                                ToLocal.Create toCreator ->
                                                    -- what is creator doing?
                                                    case toCreator of
                                                        ToCreator.New new ->
                                                            case new of
                                                                ToNewCreator.HandleInvalid ->
                                                                    let
                                                                        f handle =
                                                                            { model
                                                                                | state =
                                                                                    { local =
                                                                                        Local.Create <|
                                                                                            Creator.New <|
                                                                                                NewCreator.HandleInvalid
                                                                                                    handle
                                                                                    , global = model.state.global
                                                                                    , exception = model.state.exception
                                                                                    }
                                                                            }
                                                                    in
                                                                    Listener.decode model json Handle.decode f

                                                                ToNewCreator.HandleAlreadyExists ->
                                                                    let
                                                                        f handle =
                                                                            { model
                                                                                | state =
                                                                                    { local =
                                                                                        Local.Create <|
                                                                                            Creator.New <|
                                                                                                NewCreator.HandleAlreadyExists
                                                                                                    handle
                                                                                    , global = model.state.global
                                                                                    , exception = model.state.exception
                                                                                    }
                                                                            }
                                                                    in
                                                                    Listener.decode model json Handle.decode f

                                                                ToNewCreator.NewHandleSuccess ->
                                                                    let
                                                                        f hasWalletAndHandle =
                                                                            { model
                                                                                | state =
                                                                                    { local =
                                                                                        Local.Create <|
                                                                                            Creator.Existing hasWalletAndHandle <|
                                                                                                ExistingCreator.Top
                                                                                    , global =
                                                                                        Global.HasWalletAndHandle
                                                                                            hasWalletAndHandle
                                                                                    , exception = model.state.exception
                                                                                    }
                                                                            }
                                                                    in
                                                                    Listener.decode model json HasWalletAndHandle.decode f

                                                        ToCreator.Existing existing ->
                                                            case existing of
                                                                ToExistingCreator.CreatingNewCollection ->
                                                                    let
                                                                        f decoded =
                                                                            ( { model
                                                                                | state =
                                                                                    { local =
                                                                                        Local.Create <|
                                                                                            Creator.Existing decoded.global <|
                                                                                                ExistingCreator.CreatingNewCollection <|
                                                                                                    NewCollection.Input <|
                                                                                                        NewCollection.Yes
                                                                                                            decoded.form
                                                                                    , global = model.state.global
                                                                                    , exception = model.state.exception
                                                                                    }
                                                                              }
                                                                            , sender <|
                                                                                Sender.encode <|
                                                                                    { sender =
                                                                                        Sender.Create <|
                                                                                            FromCreator.Existing
                                                                                                decoded.global
                                                                                                (FromExistingCreator.CreateNewCollection decoded.form.meta)
                                                                                    , more = NewCollection.encode decoded.form
                                                                                    }
                                                                            )
                                                                    in
                                                                    Listener.decode2 model json NewCollection.decode f

                                                                ToExistingCreator.CreatedNewCollection ->
                                                                    let
                                                                        f withCollection =
                                                                            { model
                                                                                | state =
                                                                                    { local =
                                                                                        Local.Create <|
                                                                                            Creator.Existing withCollection.global <|
                                                                                                ExistingCreator.CreatingNewCollection <|
                                                                                                    NewCollection.HasCreateNft
                                                                                                        withCollection.collection
                                                                                    , global =
                                                                                        Global.HasWalletAndHandle
                                                                                            withCollection.global
                                                                                    , exception = model.state.exception
                                                                                    }
                                                                            }
                                                                    in
                                                                    Listener.decode model json WithCollectionForCreator.decode f

                                                                ToExistingCreator.MarkedNewCollection ->
                                                                    let
                                                                        f withCollection =
                                                                            { model
                                                                                | state =
                                                                                    { local =
                                                                                        Local.Create <|
                                                                                            Creator.Existing withCollection.global <|
                                                                                                ExistingCreator.CreatingNewCollection <|
                                                                                                    NewCollection.Done
                                                                                                        withCollection.collection
                                                                                    , global =
                                                                                        Global.HasWalletAndHandle
                                                                                            withCollection.global
                                                                                    , exception = Exception.Closed
                                                                                    }
                                                                            }
                                                                    in
                                                                    Listener.decode model json WithCollectionForCreator.decode f

                                                -- found msg for collector
                                                ToLocal.Collect toCollector ->
                                                    -- what is creator doing?
                                                    case toCollector of
                                                        ToCollector.HandleInvalid ->
                                                            let
                                                                f handle =
                                                                    { model
                                                                        | state =
                                                                            { local =
                                                                                Local.Collect <|
                                                                                    Collector.HandleInvalid handle
                                                                            , global = model.state.global
                                                                            , exception = model.state.exception
                                                                            }
                                                                    }
                                                            in
                                                            Listener.decode model json Handle.decode f

                                                        ToCollector.HandleDoesNotExist ->
                                                            let
                                                                f handle =
                                                                    { model
                                                                        | state =
                                                                            { local =
                                                                                Local.Collect <|
                                                                                    Collector.HandleDoesNotExist handle
                                                                            , global = model.state.global
                                                                            , exception = model.state.exception
                                                                            }
                                                                    }
                                                            in
                                                            Listener.decode model json Handle.decode f

                                                        ToCollector.HandleFound ->
                                                            let
                                                                intersection collections =
                                                                    case model.state.global of
                                                                        Global.HasWalletAndHandle hasWalletAndHandle ->
                                                                            Collection.intersection
                                                                                collections
                                                                                hasWalletAndHandle.collected

                                                                        Global.HasWallet hasWallet ->
                                                                            Collection.intersection
                                                                                collections
                                                                                hasWallet.collected

                                                                        _ ->
                                                                            []

                                                                f withCollections =
                                                                    { model
                                                                        | state =
                                                                            { local =
                                                                                Local.Collect <|
                                                                                    Collector.SelectedCreator
                                                                                        (intersection withCollections.collections)
                                                                                        withCollections
                                                                            , global = model.state.global
                                                                            , exception = model.state.exception
                                                                            }
                                                                    }
                                                            in
                                                            Listener.decode model json WithCollections.decode f

                                                        ToCollector.CollectionSelected ->
                                                            let
                                                                maybeCopiedEdition masterEdition =
                                                                    case model.state.global of
                                                                        Global.HasWalletAndHandle g ->
                                                                            Collection.find
                                                                                masterEdition
                                                                                g.collected

                                                                        Global.HasWallet g ->
                                                                            Collection.find
                                                                                masterEdition
                                                                                g.collected

                                                                        _ ->
                                                                            Nothing

                                                                f collection =
                                                                    { model
                                                                        | state =
                                                                            { local =
                                                                                Local.Collect <|
                                                                                    Collector.SelectedCollection
                                                                                        (maybeCopiedEdition collection)
                                                                                        collection
                                                                            , global = model.state.global
                                                                            , exception = Exception.Closed
                                                                            }
                                                                    }
                                                            in
                                                            Listener.decode model json Collection.decode f

                                                        ToCollector.CollectionPurchased ->
                                                            let
                                                                update_ collection global =
                                                                    { model
                                                                        | state =
                                                                            { local =
                                                                                Local.Collect <|
                                                                                    Collector.PrintedAndMarked
                                                                                        collection
                                                                            , global = global
                                                                            , exception = Exception.Closed
                                                                            }
                                                                    }

                                                                f withCollection =
                                                                    case withCollection.global of
                                                                        WithCollectionForCollector.HasWallet g ->
                                                                            update_
                                                                                withCollection.collection
                                                                                (Global.HasWallet g)

                                                                        WithCollectionForCollector.HasWalletAndHandle g ->
                                                                            update_
                                                                                withCollection.collection
                                                                                (Global.HasWalletAndHandle g)
                                                            in
                                                            Listener.decode model json WithCollectionForCollector.decode f

                                        -- found msg for global update
                                        Listener.Global toGlobal ->
                                            case toGlobal of
                                                ToGlobal.DisconnectWallet ->
                                                    let
                                                        local =
                                                            case model.state.local of
                                                                -- TODO; repeat for selected-collection
                                                                --  and on connect. this is disconnect
                                                                Local.Collect (Collector.SelectedCreator _ withCollections) ->
                                                                    Local.Collect <|
                                                                        Collector.SelectedCreator
                                                                            []
                                                                            -- no intersection
                                                                            withCollections

                                                                _ ->
                                                                    model.state.local
                                                    in
                                                    ( { model
                                                        | state =
                                                            { local = local
                                                            , global = Global.NoWalletYet
                                                            , exception = model.state.exception
                                                            }
                                                      }
                                                    , Cmd.none
                                                    )

                                                ToGlobal.FoundMissingWalletPlugin ->
                                                    ( { model
                                                        | state =
                                                            { local = model.state.local
                                                            , global = Global.WalletMissing
                                                            , exception = model.state.exception
                                                            }
                                                      }
                                                    , Cmd.none
                                                    )

                                                ToGlobal.FoundWallet ->
                                                    let
                                                        local collections =
                                                            case model.state.local of
                                                                -- compute intersection from new global state
                                                                Local.Collect (Collector.SelectedCreator _ withCollections) ->
                                                                    Local.Collect <|
                                                                        Collector.SelectedCreator
                                                                            (Collection.intersection
                                                                                withCollections.collections
                                                                                collections
                                                                            )
                                                                            withCollections

                                                                _ ->
                                                                    model.state.local

                                                        f hasWallet =
                                                            { model
                                                                | state =
                                                                    { local = local hasWallet.collected
                                                                    , global = Global.HasWallet hasWallet
                                                                    , exception = model.state.exception
                                                                    }
                                                            }
                                                    in
                                                    Listener.decode model json HasWallet.decode f

                                                ToGlobal.FoundWalletAndHandle ->
                                                    let
                                                        local collections =
                                                            case model.state.local of
                                                                -- compute intersection from new global state
                                                                Local.Collect (Collector.SelectedCreator _ withCollections) ->
                                                                    Local.Collect <|
                                                                        Collector.SelectedCreator
                                                                            (Collection.intersection
                                                                                withCollections.collections
                                                                                collections
                                                                            )
                                                                            withCollections

                                                                _ ->
                                                                    model.state.local

                                                        f hasWalletAndHandle =
                                                            { model
                                                                | state =
                                                                    { local = local hasWalletAndHandle.collected
                                                                    , global =
                                                                        Global.HasWalletAndHandle
                                                                            hasWalletAndHandle
                                                                    , exception = model.state.exception
                                                                    }
                                                            }
                                                    in
                                                    Listener.decode model json HasWalletAndHandle.decode f

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
                                    ( { model
                                        | state =
                                            { local = Local.Error message
                                            , global = model.state.global
                                            , exception = model.state.exception
                                            }
                                      }
                                    , Cmd.none
                                    )

                        -- error from decoder
                        Err string ->
                            ( { model
                                | state =
                                    { local = Local.Error string
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
                              }
                            , Cmd.none
                            )

                -- JS sending exception to catch
                JsMsg.Exception string ->
                    ( { model
                        | state =
                            { local = model.state.local
                            , global = model.state.global
                            , exception = Exception.Open string
                            }
                      }
                    , Cmd.none
                    )

                -- JS sending error to raise
                JsMsg.Error string ->
                    ( { model
                        | state =
                            { local = Local.Error string
                            , global = model.state.global
                            , exception = model.state.exception
                            }
                      }
                    , Cmd.none
                    )

        Global fromGlobal ->
            ( { model
                | state =
                    { local = model.state.local
                    , global = Global.Connecting
                    , exception = model.state.exception
                    }
              }
            , sender <| Sender.encode0 <| Sender.Global fromGlobal
            )

        CloseExceptionModal ->
            ( { model
                | state =
                    { local = model.state.local
                    , global = model.state.global
                    , exception = Exception.Closed
                    }
              }
            , Cmd.none
            )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        hero =
            View.Hero.view model.state.exception model.state.global

        html =
            case model.state.local of
                Local.Create creator ->
                    hero <| View.Create.Create.body creator

                Local.Collect collector ->
                    hero <| View.Collect.Collect.body model.state.global collector

                Local.Error error ->
                    hero <| View.Error.Error.body error
    in
    { title = "dap.cool"
    , body =
        [ html
        ]
    }
