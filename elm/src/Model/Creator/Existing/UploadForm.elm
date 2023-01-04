module Model.Creator.Existing.UploadForm exposing (UploadForm, decode, decodeFiles, encode, files, init, title)

import Json.Decode as Decode
import Json.Encode as Encode
import Model.Collection as Collection exposing (Collection)
import Model.Mint exposing (Mint)
import Util.Decode as Util


type alias UploadForm =
    { step : Int
    , retries : Int
    , files : Files
    , title : String
    , shadow : Maybe Mint
    , litArgs : Maybe LitArgs
    }


type alias LitArgs =
    { method : String
    , mint : String
    , returnValueTest :
        { key : String
        , comparator : String
        , value : String
        }
    }


type alias Files =
    { count : Int
    , files : List File
    }


type alias File =
    { name : String
    , dataUrl : String
    }


init : UploadForm
init =
    { step = 0
    , retries = 0
    , title = ""
    , files =
        { count = 0
        , files = []
        }
    , shadow = Nothing
    , litArgs = Nothing
    }


title : String -> UploadForm -> UploadForm
title string form =
    { form | title = string }


files : Files -> UploadForm -> UploadForm
files files_ form =
    { form | files = files_ }


encode : Collection -> UploadForm -> String
encode collection form =
    let
        maybeShadow =
            case form.shadow of
                Just shadow ->
                    Encode.string shadow

                Nothing ->
                    Encode.null

        maybeLitArgs =
            case form.litArgs of
                Just litArgs ->
                    Encode.object
                        [ ( "method", Encode.string litArgs.method )
                        , ( "mint", Encode.string litArgs.mint )
                        , ( "returnValueTest"
                          , Encode.object
                                [ ( "key", Encode.string litArgs.returnValueTest.key )
                                , ( "comparator", Encode.string litArgs.returnValueTest.comparator )
                                , ( "value", Encode.string litArgs.returnValueTest.value )
                                ]
                          )
                        ]

                Nothing ->
                    Encode.null
    in
    Encode.encode 0 <|
        Encode.object
            [ ( "collection", Collection.encoder collection )
            , ( "form"
              , Encode.object
                    [ ( "step", Encode.int form.step )
                    , ( "retries", Encode.int form.retries )
                    , ( "files"
                      , Encode.object
                            [ ( "count", Encode.int form.files.count )
                            , ( "files"
                              , Encode.list
                                    (\file ->
                                        Encode.object
                                            [ ( "name", Encode.string file.name )
                                            , ( "dataUrl", Encode.string file.dataUrl )
                                            ]
                                    )
                                    form.files.files
                              )
                            ]
                      )
                    , ( "title", Encode.string form.title )
                    , ( "shadow", maybeShadow )
                    , ( "litArgs", maybeLitArgs )
                    ]
              )
            ]


decode : String -> Result String { collection : Collection, form : UploadForm, recursive : Bool }
decode string =
    Util.decode string decoder identity


decoder =
    Decode.map3 (\c f r -> { collection = c, form = f, recursive = r })
        (Decode.field "collection" Collection.decoder)
        (Decode.field "form" <|
            Decode.map6 UploadForm
                (Decode.field "step" Decode.int)
                (Decode.field "retries" Decode.int)
                (Decode.field "files" filesDecoder)
                (Decode.field "title" Decode.string)
                (Decode.maybe <| Decode.field "shadow" Decode.string)
                (Decode.maybe <|
                    Decode.field "litArgs" <|
                        Decode.map3 LitArgs
                            (Decode.field "method" Decode.string)
                            (Decode.field "mint" Decode.string)
                            (Decode.field "returnValueTest" <|
                                Decode.map3 (\k c v -> { key = k, comparator = c, value = v })
                                    (Decode.field "key" Decode.string)
                                    (Decode.field "comparator" Decode.string)
                                    (Decode.field "value" Decode.string)
                            )
                )
        )
        (Decode.field "recursive" Decode.bool)


decodeFiles : String -> Result String Files
decodeFiles string =
    Util.decode string filesDecoder identity


filesDecoder : Decode.Decoder Files
filesDecoder =
    Decode.map2 Files
        (Decode.field "count" Decode.int)
        (Decode.field "files" <|
            Decode.list <|
                Decode.map2 File
                    (Decode.field "name" Decode.string)
                    (Decode.field "dataUrl" Decode.string)
        )
