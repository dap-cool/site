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
import Model.Creator.Existing.UploadForm as UploadForm
import Model.Creator.Existing.WithCollection as WithCollectionForCreator
import Model.Creator.New.New as NewCreator
import Model.Datum as Datum
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
                                            { local = model.state.local
                                            , global = model.state.global
                                            , exception = Exception.Waiting
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

                        FromExistingCreator.CreateNewNft metaForm ->
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

                        FromExistingCreator.SelectCollection collection ->
                            ( { model
                                | state =
                                    { local =
                                        Local.Create <|
                                            Creator.Existing hasWalletAndHandle <|
                                                ExistingCreator.WaitingForUploaded
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
                              }
                            , sender <|
                                Sender.encode <|
                                    { sender = Sender.Create from
                                    , more = Collection.encode collection
                                    }
                            )

                        FromExistingCreator.StartUploading collection ->
                            ( { model
                                | state =
                                    { local =
                                        Local.Create <|
                                            Creator.Existing hasWalletAndHandle <|
                                                ExistingCreator.Uploading
                                                    collection
                                                    UploadForm.init
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
                              }
                            , Cmd.none
                            )

                        FromExistingCreator.TypingUploadTitle collection title ->
                            ( { model
                                | state =
                                    { local =
                                        Local.Create <|
                                            Creator.Existing hasWalletAndHandle <|
                                                ExistingCreator.Uploading
                                                    collection
                                                    (UploadForm.title title)
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
                              }
                            , Cmd.none
                            )

                        FromExistingCreator.Upload collection form ->
                            let
                                bump =
                                    { form | step = 1 }
                            in
                            ( { model
                                | state =
                                    { local =
                                        Local.Create <|
                                            Creator.Existing hasWalletAndHandle <|
                                                ExistingCreator.Uploading
                                                    collection
                                                    bump
                                    , global = model.state.global
                                    , exception = model.state.exception
                                    }
                              }
                            , sender <|
                                Sender.encode <|
                                    { sender = Sender.Create from
                                    , more = UploadForm.encode collection bump
                                    }
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

                FromCollector.SelectCollection handle index ->
                    ( model
                    , sender <|
                        Sender.encode <|
                            { sender = Sender.Collect from
                            , more = AlmostExistingCollection.encode { handle = handle, index = index }
                            }
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

                FromCollector.UnlockDatum collection datum uploaded ->
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
                            , more = Datum.encode collection datum uploaded
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
                                                                                    , exception = Exception.Closed
                                                                                    }
                                                                            }
                                                                    in
                                                                    Listener.decode model json HasWalletAndHandle.decode f

                                                        ToCreator.Existing existing ->
                                                            case existing of
                                                                ToExistingCreator.CreatingNewNft ->
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
                                                                                                (FromExistingCreator.CreateNewNft decoded.form.meta)
                                                                                    , more = NewCollection.encode decoded.form
                                                                                    }
                                                                            )
                                                                    in
                                                                    Listener.decode2 model json NewCollection.decode f

                                                                ToExistingCreator.CreatedNewNft ->
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
                                                                                    , exception = model.state.exception
                                                                                    }
                                                                            }
                                                                    in
                                                                    Listener.decode model json WithCollectionForCreator.decode f

                                                                ToExistingCreator.SelectedCollection ->
                                                                    let
                                                                        f uploads =
                                                                            case model.state.global of
                                                                                Global.HasWalletAndHandle hasWalletAndHandle ->
                                                                                    { model
                                                                                        | state =
                                                                                            { local =
                                                                                                Local.Create <|
                                                                                                    Creator.Existing hasWalletAndHandle <|
                                                                                                        ExistingCreator.SelectedCollection
                                                                                                            uploads.collection
                                                                                                            uploads.datum
                                                                                            , global = model.state.global
                                                                                            , exception = model.state.exception
                                                                                            }
                                                                                    }

                                                                                _ ->
                                                                                    model
                                                                    in
                                                                    Listener.decode model json Datum.decode2 f

                                                                ToExistingCreator.StillUploading ->
                                                                    let
                                                                        f withCollection =
                                                                            case model.state.global of
                                                                                Global.HasWalletAndHandle hasWalletAndHandle ->
                                                                                    let
                                                                                        bump =
                                                                                            { model
                                                                                                | state =
                                                                                                    { local =
                                                                                                        Local.Create <|
                                                                                                            Creator.Existing hasWalletAndHandle <|
                                                                                                                ExistingCreator.Uploading
                                                                                                                    withCollection.collection
                                                                                                                    withCollection.form
                                                                                                    , global = model.state.global
                                                                                                    , exception = model.state.exception
                                                                                                    }
                                                                                            }
                                                                                    in
                                                                                    case ( withCollection.recursive, withCollection.form.retries < 5 ) of
                                                                                        ( True, True ) ->
                                                                                            ( bump
                                                                                            , sender <|
                                                                                                Sender.encode <|
                                                                                                    { sender =
                                                                                                        Sender.Create <|
                                                                                                            FromCreator.Existing hasWalletAndHandle <|
                                                                                                                FromExistingCreator.Upload
                                                                                                                    withCollection.collection
                                                                                                                    withCollection.form
                                                                                                    , more =
                                                                                                        UploadForm.encode
                                                                                                            withCollection.collection
                                                                                                            withCollection.form
                                                                                                    }
                                                                                            )

                                                                                        _ ->
                                                                                            ( bump
                                                                                            , Cmd.none
                                                                                            )

                                                                                _ ->
                                                                                    ( model
                                                                                    , Cmd.none
                                                                                    )
                                                                    in
                                                                    Listener.decode2 model json UploadForm.decode f

                                                                ToExistingCreator.UploadSuccessful ->
                                                                    let
                                                                        f collection =
                                                                            case model.state.global of
                                                                                Global.HasWalletAndHandle hasWalletAndHandle ->
                                                                                    { model
                                                                                        | state =
                                                                                            { local =
                                                                                                Local.Create <|
                                                                                                    Creator.Existing hasWalletAndHandle <|
                                                                                                        ExistingCreator.UploadSuccessful
                                                                                                            collection
                                                                                            , global = model.state.global
                                                                                            , exception = model.state.exception
                                                                                            }
                                                                                    }

                                                                                _ ->
                                                                                    model
                                                                    in
                                                                    Listener.decode model json Collection.decode f

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
                                                                                hasWalletAndHandle.collected
                                                                                collections

                                                                        Global.HasWallet hasWallet ->
                                                                            Collection.intersection
                                                                                hasWallet.collected
                                                                                collections

                                                                        _ ->
                                                                            ( [], collections )

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
                                                                ata collection =
                                                                    case Collection.isEmpty collection of
                                                                        True ->
                                                                            Collector.Zero

                                                                        False ->
                                                                            Collector.Positive

                                                                maybeCollected collection =
                                                                    case model.state.global of
                                                                        Global.HasWalletAndHandle g ->
                                                                            case Collection.find collection g.collected of
                                                                                Just found ->
                                                                                    Collector.LoggedIn
                                                                                        (Collector.Yes found)
                                                                                        (ata collection)

                                                                                Nothing ->
                                                                                    Collector.LoggedIn
                                                                                        Collector.No
                                                                                        (ata collection)

                                                                        Global.HasWallet g ->
                                                                            case Collection.find collection g.collected of
                                                                                Just found ->
                                                                                    Collector.LoggedIn
                                                                                        (Collector.Yes found)
                                                                                        (ata collection)

                                                                                Nothing ->
                                                                                    Collector.LoggedIn
                                                                                        Collector.No
                                                                                        (ata collection)

                                                                        _ ->
                                                                            Collector.NotLoggedInYet

                                                                f wc =
                                                                    { model
                                                                        | state =
                                                                            { local =
                                                                                Local.Collect <|
                                                                                    Collector.SelectedCollection
                                                                                        (maybeCollected wc.collection)
                                                                                        wc.collection
                                                                                        wc.datum
                                                                            , global = model.state.global
                                                                            , exception = Exception.Closed
                                                                            }
                                                                    }
                                                            in
                                                            Listener.decode model json Datum.decode2 f

                                                        ToCollector.CollectionPrinted ->
                                                            let
                                                                update_ master copied datum global =
                                                                    { model
                                                                        | state =
                                                                            { local =
                                                                                Local.Collect <|
                                                                                    Collector.SelectedCollection
                                                                                        (Collector.LoggedIn
                                                                                            (Collector.Yes copied)
                                                                                            Collector.Positive
                                                                                        )
                                                                                        master
                                                                                        datum
                                                                            , global = global
                                                                            , exception = Exception.Closed
                                                                            }
                                                                    }

                                                                f withCollection =
                                                                    case withCollection.global of
                                                                        WithCollectionForCollector.HasWallet hasWallet ->
                                                                            update_
                                                                                withCollection.master
                                                                                withCollection.copied
                                                                                withCollection.datum
                                                                                (Global.HasWallet hasWallet)

                                                                        WithCollectionForCollector.HasWalletAndHandle hasWalletAndHandle ->
                                                                            update_
                                                                                withCollection.master
                                                                                withCollection.copied
                                                                                withCollection.datum
                                                                                (Global.HasWalletAndHandle hasWalletAndHandle)
                                                            in
                                                            Listener.decode model json WithCollectionForCollector.decode f

                                                        ToCollector.DatumUnlocked ->
                                                            let
                                                                f wc =
                                                                    { model
                                                                        | state =
                                                                            { local =
                                                                                Local.Collect <|
                                                                                    Collector.UnlockedDatum
                                                                                        wc.collection
                                                                                        wc.datum
                                                                                        wc.uploaded
                                                                            , global = model.state.global
                                                                            , exception = Exception.Closed
                                                                            }
                                                                    }
                                                            in
                                                            Listener.decode model json Datum.decode f

                                        -- found msg for global update
                                        Listener.Global toGlobal ->
                                            case toGlobal of
                                                ToGlobal.DisconnectWallet ->
                                                    let
                                                        local =
                                                            case model.state.local of
                                                                Local.Create _ ->
                                                                    Local.Create <| Creator.New <| NewCreator.Top

                                                                Local.Collect (Collector.SelectedCreator _ withCollections) ->
                                                                    Local.Collect <|
                                                                        Collector.SelectedCreator
                                                                            ( [], withCollections.collections )
                                                                            -- no intersection
                                                                            withCollections

                                                                Local.Collect (Collector.SelectedCollection _ selected uploaded) ->
                                                                    Local.Collect <|
                                                                        Collector.SelectedCollection
                                                                            Collector.NotLoggedInYet
                                                                            selected
                                                                            uploaded

                                                                Local.Collect (Collector.UnlockedDatum collected _ uploaded) ->
                                                                    Local.Collect <|
                                                                        Collector.SelectedCollection
                                                                            Collector.NotLoggedInYet
                                                                            collected
                                                                            uploaded

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

                                                -- TODO; open exception modal
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
                                                        state =
                                                            model.state

                                                        bumpedState hasWallet waiting =
                                                            let
                                                                global =
                                                                    Global.HasWallet
                                                                        hasWallet
                                                            in
                                                            case waiting of
                                                                True ->
                                                                    { state
                                                                        | global = global
                                                                        , exception = Exception.Waiting
                                                                    }

                                                                False ->
                                                                    { state
                                                                        | global = global
                                                                        , exception = model.state.exception
                                                                    }

                                                        bumpedLocal hasWallet local waiting =
                                                            let
                                                                bumpedState_ =
                                                                    bumpedState hasWallet waiting
                                                            in
                                                            { bumpedState_
                                                                | local = local
                                                            }

                                                        f hasWallet =
                                                            case model.state.local of
                                                                Local.Create _ ->
                                                                    ( { model
                                                                        | state =
                                                                            bumpedLocal
                                                                                hasWallet
                                                                                (Local.Create <|
                                                                                    Creator.New <|
                                                                                        NewCreator.Top
                                                                                )
                                                                                False
                                                                      }
                                                                    , Cmd.none
                                                                    )

                                                                -- compute intersection from new global state
                                                                Local.Collect (Collector.SelectedCreator _ withCollections) ->
                                                                    ( { model
                                                                        | state =
                                                                            bumpedLocal
                                                                                hasWallet
                                                                                (Local.Collect <|
                                                                                    Collector.SelectedCreator
                                                                                        (Collection.intersection
                                                                                            hasWallet.collected
                                                                                            withCollections.collections
                                                                                        )
                                                                                        withCollections
                                                                                )
                                                                                False
                                                                      }
                                                                    , Cmd.none
                                                                    )

                                                                -- go back to js for ata balance
                                                                -- because at this point we have the wallet's collected array
                                                                -- but the selected not being collected by the wallet
                                                                -- doesn't imply that the ata has a non-zero balance
                                                                -- in fact, this is what happens when a wallet buys in 2nd markets
                                                                Local.Collect (Collector.SelectedCollection _ selected _) ->
                                                                    ( { model
                                                                        | state = bumpedState hasWallet True
                                                                      }
                                                                    , sender <|
                                                                        Sender.encode <|
                                                                            { sender =
                                                                                Sender.Collect <|
                                                                                    FromCollector.SelectCollection
                                                                                        selected.meta.handle
                                                                                        selected.meta.index
                                                                            , more =
                                                                                AlmostExistingCollection.encode
                                                                                    { handle = selected.meta.handle
                                                                                    , index = selected.meta.index
                                                                                    }
                                                                            }
                                                                    )

                                                                -- go back to js for ata balance
                                                                Local.Collect (Collector.UnlockedDatum collected _ _) ->
                                                                    ( { model
                                                                        | state = bumpedState hasWallet True
                                                                      }
                                                                    , sender <|
                                                                        Sender.encode <|
                                                                            { sender =
                                                                                Sender.Collect <|
                                                                                    FromCollector.SelectCollection
                                                                                        collected.meta.handle
                                                                                        collected.meta.index
                                                                            , more =
                                                                                AlmostExistingCollection.encode
                                                                                    { handle = collected.meta.handle
                                                                                    , index = collected.meta.index
                                                                                    }
                                                                            }
                                                                    )

                                                                -- update global & move on
                                                                _ ->
                                                                    ( { model | state = bumpedState hasWallet False }
                                                                    , Cmd.none
                                                                    )
                                                    in
                                                    Listener.decode2 model json HasWallet.decode f

                                                ToGlobal.FoundWalletAndHandle ->
                                                    let
                                                        state =
                                                            model.state

                                                        bumpedState hasWalletAndHandle waiting =
                                                            let
                                                                global =
                                                                    Global.HasWalletAndHandle
                                                                        hasWalletAndHandle
                                                            in
                                                            case waiting of
                                                                True ->
                                                                    { state
                                                                        | global = global
                                                                        , exception = Exception.Waiting
                                                                    }

                                                                False ->
                                                                    { state
                                                                        | global = global
                                                                        , exception = model.state.exception
                                                                    }

                                                        bumpedLocal hasWalletAndHandle local waiting =
                                                            let
                                                                bumpedState_ =
                                                                    bumpedState hasWalletAndHandle waiting
                                                            in
                                                            { bumpedState_
                                                                | local = local
                                                            }

                                                        f hasWalletAndHandle =
                                                            case model.state.local of
                                                                Local.Create _ ->
                                                                    ( { model
                                                                        | state =
                                                                            bumpedLocal
                                                                                hasWalletAndHandle
                                                                                (Local.Create <|
                                                                                    Creator.Existing hasWalletAndHandle <|
                                                                                        ExistingCreator.Top
                                                                                )
                                                                                False
                                                                      }
                                                                    , Cmd.none
                                                                    )

                                                                -- compute intersection from new global state
                                                                Local.Collect (Collector.SelectedCreator _ withCollections) ->
                                                                    ( { model
                                                                        | state =
                                                                            bumpedLocal
                                                                                hasWalletAndHandle
                                                                                (Local.Collect <|
                                                                                    Collector.SelectedCreator
                                                                                        (Collection.intersection
                                                                                            hasWalletAndHandle.collected
                                                                                            withCollections.collections
                                                                                        )
                                                                                        withCollections
                                                                                )
                                                                                False
                                                                      }
                                                                    , Cmd.none
                                                                    )

                                                                -- go back to js for ata balance
                                                                -- because at this point we have the wallet's collected array
                                                                -- but the selected not being collected by the wallet
                                                                -- doesn't imply that the ata has a non-zero balance
                                                                -- in fact, this is what happens when a wallet buys in 2nd markets
                                                                Local.Collect (Collector.SelectedCollection _ selected _) ->
                                                                    ( { model
                                                                        | state = bumpedState hasWalletAndHandle True
                                                                      }
                                                                    , sender <|
                                                                        Sender.encode <|
                                                                            { sender =
                                                                                Sender.Collect <|
                                                                                    FromCollector.SelectCollection
                                                                                        selected.meta.handle
                                                                                        selected.meta.index
                                                                            , more =
                                                                                AlmostExistingCollection.encode
                                                                                    { handle = selected.meta.handle
                                                                                    , index = selected.meta.index
                                                                                    }
                                                                            }
                                                                    )

                                                                -- go back to js for ata balance
                                                                Local.Collect (Collector.UnlockedDatum collected _ _) ->
                                                                    ( { model
                                                                        | state = bumpedState hasWalletAndHandle True
                                                                      }
                                                                    , sender <|
                                                                        Sender.encode <|
                                                                            { sender =
                                                                                Sender.Collect <|
                                                                                    FromCollector.SelectCollection
                                                                                        collected.meta.handle
                                                                                        collected.meta.index
                                                                            , more =
                                                                                AlmostExistingCollection.encode
                                                                                    { handle = collected.meta.handle
                                                                                    , index = collected.meta.index
                                                                                    }
                                                                            }
                                                                    )

                                                                -- update global & move on
                                                                _ ->
                                                                    ( { model
                                                                        | state = bumpedState hasWalletAndHandle False
                                                                      }
                                                                    , Cmd.none
                                                                    )
                                                    in
                                                    Listener.decode2 model json HasWalletAndHandle.decode f

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
                    case Exception.decode string of
                        Ok exception ->
                            ( { model
                                | state =
                                    { local = model.state.local
                                    , global = model.state.global
                                    , exception = Exception.Open exception.message exception.href
                                    }
                              }
                            , Cmd.none
                            )

                        Err jsonError ->
                            ( { model
                                | state =
                                    { local = Local.Error jsonError
                                    , global = model.state.global
                                    , exception = model.state.exception
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
                    hero <| View.Collect.Collect.body collector

                Local.Error error ->
                    hero <| View.Error.Error.body error
    in
    { title = "dap.cool"
    , body =
        [ html
        ]
    }
