module Model.Datum exposing (Datum, File, Src(..), decode, decode2, decoder, encode, toSrc)

import Json.Decode as Decode
import Json.Encode as Encode
import Model.Collection as Collection exposing (Collection)
import Model.Mint exposing (Mint)
import Util.Decode as Util


type alias Datum =
    { mint : Mint
    , uploader : Mint
    , index : Int
    , filtered : Bool
    , shadow : Shadow
    , metadata : Metadata
    }


type alias WithCollection =
    { collection : Collection
    , datum : List Datum
    }


type alias Shadow =
    { account : Mint
    , url : String
    }


type alias Metadata =
    { title : String
    , zip : Zip
    }


type alias Zip =
    { count : Int
    , types : List String
    , files : List File
    }


type alias File =
    { base64 : Base64
    , type_ : String
    }


type alias Base64 =
    String


type Src
    = Img DataUri
    | Audio DataUri
    | Video DataUri
    | NotSupported


type alias DataUri =
    String


toSrc : File -> Src
toSrc file =
    let
        uri type_ =
            String.concat
                [ "data:"
                , type_
                , "/"
                , file.type_ -- subtype
                , ";base64,"
                , file.base64
                ]

        img =
            Img <| uri "image"

        audio =
            Audio <| uri "audio"

        video =
            Video <| uri "video"

        imgList =
            [ "apng"
            , "gif"
            , "ico"
            , "cur"
            , "jpg"
            , "jpeg"
            , "jfif"
            , "pjpeg"
            , "pjp"
            , "png"
            , "svg"
            ]

        audioList =
            [ "mp3"
            , "wav"
            , "ogg"
            ]

        videoList =
            [ "mp4"
            , "webm"
            , "ogg"
            ]
    in
    case List.member file.type_ imgList of
        True ->
            img

        False ->
            case List.member file.type_ audioList of
                True ->
                    audio

                False ->
                    case List.member file.type_ videoList of
                        True ->
                            video

                        False ->
                            NotSupported


encode : Collection -> Datum -> List Datum -> String
encode collection datum uploaded =
    Encode.encode 0 <|
        Encode.object
            [ ( "collection", Collection.encoder collection )
            , ( "datum", encoder datum )
            , ( "uploaded", Encode.list encoder uploaded )
            ]


encoder : Datum -> Encode.Value
encoder datum =
    Encode.object
        [ ( "mint", Encode.string datum.mint )
        , ( "uploader", Encode.string datum.uploader )
        , ( "index", Encode.int datum.index )
        , ( "filtered", Encode.bool datum.filtered )
        , ( "shadow"
          , Encode.object
                [ ( "account", Encode.string datum.shadow.account )
                , ( "url", Encode.string datum.shadow.url )
                ]
          )
        , ( "metadata"
          , Encode.object
                [ ( "title", Encode.string datum.metadata.title )
                , ( "zip"
                  , Encode.object
                        [ ( "count", Encode.int datum.metadata.zip.count )
                        , ( "types", Encode.list Encode.string datum.metadata.zip.types )
                        , ( "files"
                          , Encode.list
                                (\f ->
                                    Encode.object
                                        [ ( "base64", Encode.string f.base64 )
                                        , ( "type_", Encode.string f.type_ )
                                        ]
                                )
                                datum.metadata.zip.files
                          )
                        ]
                  )
                ]
          )
        ]


decode : String -> Result String { collection : Collection, datum : Datum, uploaded : List Datum }
decode string =
    Util.decode string decoder_ identity


decode2 : String -> Result String WithCollection
decode2 string =
    Util.decode string decoder2_ identity


decoder : Decode.Decoder Datum
decoder =
    Decode.map6 Datum
        (Decode.field "mint" Decode.string)
        (Decode.field "uploader" Decode.string)
        (Decode.field "index" Decode.int)
        (Decode.field "filtered" Decode.bool)
        (Decode.field "shadow" <|
            Decode.map2 Shadow
                (Decode.field "account" Decode.string)
                (Decode.field "url" Decode.string)
        )
        (Decode.field "metadata" <|
            Decode.map2 Metadata
                (Decode.field "title" Decode.string)
                (Decode.field "zip" <|
                    Decode.map3 Zip
                        (Decode.field "count" Decode.int)
                        (Decode.field "types" <| Decode.list Decode.string)
                        (Decode.field "files" <|
                            Decode.list <|
                                Decode.map2 File
                                    (Decode.field "base64" Decode.string)
                                    (Decode.field "type_" Decode.string)
                        )
                )
        )


decoder_ : Decode.Decoder { collection : Collection, datum : Datum, uploaded : List Datum }
decoder_ =
    Decode.map3 (\c d u -> { collection = c, datum = d, uploaded = u })
        (Decode.field "collection" Collection.decoder)
        (Decode.field "datum" decoder)
        (Decode.field "uploaded" <| Decode.list decoder)


decoder2_ : Decode.Decoder WithCollection
decoder2_ =
    Decode.map2 WithCollection
        (Decode.field "collection" Collection.decoder)
        (Decode.field "datum" <| Decode.list decoder)
