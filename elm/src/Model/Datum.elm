module Model.Datum exposing (Datum, decode, decode2, decoder, encode)

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
    { src : String
    , type_ : String
    }


encode : Collection -> Datum -> String
encode collection datum =
    Encode.encode 0 <|
        Encode.object
            [ ( "collection", Collection.encoder collection )
            , ( "datum"
              , Encode.object
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
                    ]
              )
            ]


decode : String -> Result String { collection : Collection, datum : Datum }
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
                                    (Decode.field "src" Decode.string)
                                    (Decode.field "type_" Decode.string)
                        )
                )
        )


decoder_ : Decode.Decoder { collection : Collection, datum : Datum }
decoder_ =
    Decode.map2 (\c d -> { collection = c, datum = d })
        (Decode.field "collection" Collection.decoder)
        (Decode.field "datum" decoder)


decoder2_ : Decode.Decoder WithCollection
decoder2_ =
    Decode.map2 WithCollection
        (Decode.field "collection" Collection.decoder)
        (Decode.field "datum" <| Decode.list decoder)
