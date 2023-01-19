module Model.Datum exposing (Datum, File, Src(..), decode, decode2, decoder, encode, insert, toSrc)

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
    , timestamp : Int
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


encode : Datum -> String
encode datum =
    Encode.encode 0 <|
        encoder datum


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
                , ( "timestamp", Encode.int datum.metadata.timestamp )
                ]
          )
        ]


decode : String -> Result String Datum
decode string =
    Util.decode string decoder identity


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
            Decode.map3 Metadata
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
                (Decode.field "timestamp" Decode.int)
        )


decoder2_ : Decode.Decoder WithCollection
decoder2_ =
    Decode.map2 WithCollection
        (Decode.field "collection" Collection.decoder)
        (Decode.field "datum" <| Decode.list decoder)


insert : Datum -> List Datum -> List Datum
insert datum list =
    List.map
        (\d ->
            case datum.index == d.index of
                True ->
                    datum

                False ->
                    d
        )
        list
