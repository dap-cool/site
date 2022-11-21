module Main exposing (main)

-- MAIN

import Browser
import Browser.Navigation as Nav
import Json.Decode as Decode
import Model.AlmostExistingCollection as AlmostExistingCollection
import Model.Collection as Collection
import Model.Collector.Collector as Collector
import Model.Collector.WithCollections as WithCollections
import Model.Creator.Creator as Creator
import Model.Creator.Existing.Existing as ExistingCreator
import Model.Creator.Existing.HandleFormStatus as ExistingHandleFormStatus
import Model.Creator.Existing.NewCollection as NewCollection
import Model.Creator.New.New as NewCreator
import Model.Handle as Handle
import Model.Model as Model exposing (Model)
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
import Util.Decode as Util
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
                            }
                        , url = url
                    }
            in
            case local of
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

                Local.Create (Creator.MaybeExisting handle) ->
                    ( bump
                    , Cmd.batch
                        [ sender <|
                            Sender.encode <|
                                { sender =
                                    Sender.Create <|
                                        FromCreator.Existing <|
                                            FromExistingCreator.ConfirmHandle handle
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
                                            }
                                      }
                                    , sender <|
                                        Sender.encode <|
                                            { sender = Sender.Create from
                                            , more = Handle.encode handle
                                            }
                                    )

                FromCreator.Existing existing ->
                    case existing of
                        FromExistingCreator.ConfirmHandle handle ->
                            ( { model
                                | state =
                                    { local =
                                        Local.Create <|
                                            Creator.Existing <|
                                                ExistingCreator.AuthorizingFromUrl
                                                    ExistingHandleFormStatus.WaitingForHandleConfirmation
                                    , global = model.state.global
                                    }
                              }
                            , sender <|
                                Sender.encode <|
                                    { sender = Sender.Create from
                                    , more = Handle.encode handle
                                    }
                            )

                        FromExistingCreator.StartCreatingNewCollection ->
                            ( { model
                                | state =
                                    { local =
                                        Local.Create <|
                                            Creator.Existing <|
                                                ExistingCreator.CreatingNewCollection <|
                                                    NewCollection.Input
                                                        NewCollection.default
                                                        False
                                    , global = model.state.global
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
                                                    Creator.Existing <|
                                                        ExistingCreator.CreatingNewCollection <|
                                                            NewCollection.Input
                                                                bumpNewCollection
                                                                False
                                            , global = model.state.global
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
                                                    Creator.Existing <|
                                                        ExistingCreator.CreatingNewCollection <|
                                                            NewCollection.Input
                                                                bumpNewCollection
                                                                False
                                            , global = model.state.global
                                            }
                                      }
                                    , Cmd.none
                                    )

                                NewCollectionForm.Image ->
                                    ( model
                                    , sender <| Sender.encode0 <| Sender.Create from
                                      -- prepare image form events
                                    )

                        FromExistingCreator.CreateNewCollection form ->
                            ( { model
                                | state =
                                    { local =
                                        Local.Create <|
                                            Creator.Existing <|
                                                ExistingCreator.CreatingNewCollection <|
                                                    NewCollection.Input
                                                        form
                                                        True
                                    , global = model.state.global
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
                                    { local =
                                        Local.Create <|
                                            Creator.Existing <|
                                                ExistingCreator.CreatingNewCollection <|
                                                    NewCollection.WaitingForMarkNft collection
                                    , global = model.state.global
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
                                            Creator.Existing <|
                                                ExistingCreator.SelectedCollection
                                                    collection
                                    , global = model.state.global
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
                                    }
                              }
                            , Cmd.none
                            )

                        Handle.Confirm string ->
                            ( { model
                                | state =
                                    { local = Local.Collect <| Collector.WaitingForHandleConfirmation
                                    , global = model.state.global
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
                    , Cmd.none
                    )

                FromCollector.PurchaseCollection handle int ->
                    ( { model
                        | state =
                            { local = Local.Collect <| Collector.WaitingForPurchase
                            , global = model.state.global
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
                                                                                            Creator.Existing <|
                                                                                                ExistingCreator.Top
                                                                                    , global =
                                                                                        Global.HasWalletAndHandle
                                                                                            hasWalletAndHandle
                                                                                    }
                                                                            }
                                                                    in
                                                                    Listener.decode model json HasWalletAndHandle.decode f

                                                        ToCreator.Existing existing ->
                                                            case existing of
                                                                ToExistingCreator.HandleForm handleFormStatus ->
                                                                    case handleFormStatus of
                                                                        ToExistingCreator.Invalid ->
                                                                            let
                                                                                f handle =
                                                                                    { model
                                                                                        | state =
                                                                                            { local =
                                                                                                Local.Create <|
                                                                                                    Creator.Existing <|
                                                                                                        ExistingCreator.AuthorizingFromUrl <|
                                                                                                            ExistingHandleFormStatus.HandleInvalid
                                                                                                                handle
                                                                                            , global = model.state.global
                                                                                            }
                                                                                    }
                                                                            in
                                                                            Listener.decode model json Handle.decode f

                                                                        ToExistingCreator.DoesNotExist ->
                                                                            let
                                                                                f handle =
                                                                                    { model
                                                                                        | state =
                                                                                            { local =
                                                                                                Local.Create <|
                                                                                                    Creator.Existing <|
                                                                                                        ExistingCreator.AuthorizingFromUrl <|
                                                                                                            ExistingHandleFormStatus.HandleDoesNotExist
                                                                                                                handle
                                                                                            , global = model.state.global
                                                                                            }
                                                                                    }
                                                                            in
                                                                            Listener.decode model json Handle.decode f

                                                                        ToExistingCreator.UnAuthorized ->
                                                                            let
                                                                                f hasWalletAndHandle =
                                                                                    { model
                                                                                        | state =
                                                                                            { local =
                                                                                                Local.Create <|
                                                                                                    Creator.Existing <|
                                                                                                        ExistingCreator.AuthorizingFromUrl <|
                                                                                                            ExistingHandleFormStatus.UnAuthorized
                                                                                            , global =
                                                                                                Global.HasWalletAndHandle
                                                                                                    hasWalletAndHandle
                                                                                            }
                                                                                    }
                                                                            in
                                                                            Listener.decode model json HasWalletAndHandle.decode f

                                                                ToExistingCreator.CreatedNewCollection ->
                                                                    let
                                                                        f collection =
                                                                            { model
                                                                                | state =
                                                                                    { local =
                                                                                        Local.Create <|
                                                                                            Creator.Existing <|
                                                                                                ExistingCreator.CreatingNewCollection <|
                                                                                                    NewCollection.HasCreateNft
                                                                                                        collection
                                                                                    , global = model.state.global
                                                                                    }
                                                                            }
                                                                    in
                                                                    Listener.decode model json Collection.decode f

                                                                ToExistingCreator.MarkedNewCollection ->
                                                                    let
                                                                        f collection =
                                                                            { model
                                                                                | state =
                                                                                    { local =
                                                                                        Local.Create <|
                                                                                            Creator.Existing <|
                                                                                                ExistingCreator.CreatingNewCollection <|
                                                                                                    NewCollection.Done
                                                                                                        collection
                                                                                    , global = model.state.global
                                                                                    }
                                                                            }
                                                                    in
                                                                    Listener.decode model json Collection.decode f

                                                                ToExistingCreator.Authorized ->
                                                                    let
                                                                        f hasWalletAndHandle =
                                                                            { model
                                                                                | state =
                                                                                    { local =
                                                                                        Local.Create <|
                                                                                            Creator.Existing <|
                                                                                                ExistingCreator.Top
                                                                                    , global =
                                                                                        Global.HasWalletAndHandle
                                                                                            hasWalletAndHandle
                                                                                    }
                                                                            }
                                                                    in
                                                                    Listener.decode model json HasWalletAndHandle.decode f

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
                                                                            }
                                                                    }
                                                            in
                                                            Listener.decode model json Handle.decode f

                                                        ToCollector.HandleFound ->
                                                            let
                                                                f withCollections =
                                                                    { model
                                                                        | state =
                                                                            { local =
                                                                                Local.Collect <|
                                                                                    Collector.SelectedCreator
                                                                                        withCollections
                                                                            , global = model.state.global
                                                                            }
                                                                    }
                                                            in
                                                            Listener.decode model json WithCollections.decode f

                                                        ToCollector.CollectionSelected ->
                                                            let
                                                                f collection =
                                                                    { model
                                                                        | state =
                                                                            { local =
                                                                                Local.Collect <|
                                                                                    Collector.SelectedCollection
                                                                                        collection
                                                                            , global = model.state.global
                                                                            }
                                                                    }
                                                            in
                                                            Listener.decode model json Collection.decode f

                                                        ToCollector.CollectionPurchased ->
                                                            let
                                                                f typeAlias =
                                                                    { model
                                                                        | state =
                                                                            { local =
                                                                                Local.Collect <|
                                                                                    Collector.PurchaseSuccess
                                                                                        typeAlias.purchased
                                                                            , global =
                                                                                Global.HasWalletAndHandle
                                                                                    typeAlias.global
                                                                            }
                                                                    }

                                                                decoder =
                                                                    Decode.map2
                                                                        (\collection hasWalletAndHandle ->
                                                                            { purchased = collection
                                                                            , global = hasWalletAndHandle
                                                                            }
                                                                        )
                                                                        (Decode.field "purchased" Collection.decoder)
                                                                        (Decode.field "global" HasWalletAndHandle.decoder)

                                                                decode string =
                                                                    Util.decode string decoder identity
                                                            in
                                                            Listener.decode model json decode f

                                        -- found msg for global update
                                        Listener.Global toGlobal ->
                                            case toGlobal of
                                                ToGlobal.DisconnectWallet ->
                                                    ( { model
                                                        | state =
                                                            { local = model.state.local
                                                            , global = Global.NoWalletYet
                                                            }
                                                      }
                                                    , Cmd.none
                                                    )

                                                ToGlobal.FoundMissingWalletPlugin ->
                                                    ( { model
                                                        | state =
                                                            { local = model.state.local
                                                            , global = Global.WalletMissing
                                                            }
                                                      }
                                                    , Cmd.none
                                                    )

                                                ToGlobal.FoundWallet ->
                                                    let
                                                        f hasWallet =
                                                            { model
                                                                | state =
                                                                    { local = model.state.local
                                                                    , global = Global.HasWallet hasWallet
                                                                    }
                                                            }
                                                    in
                                                    Listener.decode model json HasWallet.decode f

                                                ToGlobal.FoundWalletAndHandle ->
                                                    let
                                                        f hasWalletAndHandle =
                                                            { model
                                                                | state =
                                                                    { local = model.state.local
                                                                    , global =
                                                                        Global.HasWalletAndHandle
                                                                            hasWalletAndHandle
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
                            }
                      }
                    , Cmd.none
                    )

        Global fromGlobal ->
            ( { model
                | state =
                    { local = model.state.local
                    , global = Global.Connecting
                    }
              }
            , sender <| Sender.encode0 <| Sender.Global fromGlobal
            )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        hero =
            View.Hero.view model.state.global

        html =
            case model.state.local of
                Local.Create creator ->
                    hero <| View.Create.Create.body model.state.global creator

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
