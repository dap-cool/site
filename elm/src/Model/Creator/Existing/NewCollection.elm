module Model.Creator.Existing.NewCollection exposing (MaybeMetaForm, MetaForm, NewCollection(..), Submitted(..), decode, decodeLogo, default, encode)

import Json.Decode as Decode
import Json.Encode as Encode
import Model.Collection exposing (Collection)
import Model.Mint exposing (Mint)
import Model.State.Global.HasWalletAndHandle as HasWalletAndHandle exposing (HasWalletAndHandle)
import Util.Decode as Util


type NewCollection
    = Input Submitted
    | Done Collection


type Submitted
    = Yes Form -- needs to be in same div as input for DOM preservation
    | No MaybeMetaForm


type alias Form =
    { step : Int
    , retries : Int
    , meta : MetaForm
    , shdw : Maybe ShdwForm
    }


type alias WithGlobal =
    { global : HasWalletAndHandle
    , form : Form
    }


type alias MaybeMetaForm =
    { logo : Maybe Logo
    , name : Maybe String
    , symbol : Maybe String
    , totalSupply : Maybe Int
    , creatorDistribution : Maybe Int
    , price : Maybe Float
    , fee : Maybe Float
    }


type alias Logo =
    { name : String
    , base64 : String
    }


type alias MetaForm =
    { logo : Logo
    , name : String
    , symbol : String
    , totalSupply : Int
    , creatorDistribution : Int
    , price : Float
    , fee : Float
    }


type alias ShdwForm =
    { account : Mint
    }


default : MaybeMetaForm
default =
    { logo = Nothing
    , name = Nothing
    , symbol = Nothing
    , totalSupply = Nothing
    , creatorDistribution = Nothing
    , price = Nothing
    , fee = Nothing
    }


encode : Form -> String
encode form =
    let
        shdwEncoder =
            case form.shdw of
                Just shdw ->
                    Encode.string shdw.account

                Nothing ->
                    Encode.null

        encoder =
            Encode.object
                [ ( "step", Encode.int form.step )
                , ( "retries", Encode.int form.retries )
                , ( "meta"
                  , Encode.object
                        [ ( "logo"
                          , Encode.object
                                [ ( "name", Encode.string form.meta.logo.name )
                                , ( "base64", Encode.string form.meta.logo.base64 )
                                ]
                          )
                        , ( "name", Encode.string form.meta.name )
                        , ( "symbol", Encode.string form.meta.symbol )
                        , ( "totalSupply", Encode.int form.meta.totalSupply )
                        , ( "creatorDistribution", Encode.int form.meta.creatorDistribution )
                        , ( "price", Encode.float form.meta.price )
                        , ( "fee", Encode.float form.meta.fee )
                        ]
                  )
                , ( "shdw"
                  , Encode.object
                        [ ( "account", shdwEncoder )
                        ]
                  )
                ]
    in
    Encode.encode 0 encoder


decode : String -> Result String WithGlobal
decode string =
    Util.decode string decoder identity


decoder : Decode.Decoder WithGlobal
decoder =
    Decode.map2 WithGlobal
        (Decode.field "global" HasWalletAndHandle.decoder)
        (Decode.field "form" <|
            Decode.map4 Form
                (Decode.field "step" Decode.int)
                (Decode.field "retries" Decode.int)
                (Decode.field "meta" <|
                    Decode.map7 MetaForm
                        (Decode.field "logo" logoDecoder)
                        (Decode.field "name" Decode.string)
                        (Decode.field "symbol" Decode.string)
                        (Decode.field "totalSupply" Decode.int)
                        (Decode.field "creatorDistribution" Decode.int)
                        (Decode.field "price" Decode.float)
                        (Decode.field "fee" Decode.float)
                )
                (Decode.maybe <|
                    Decode.field "shdw" <|
                        Decode.map ShdwForm
                            (Decode.field "account" Decode.string)
                )
        )


decodeLogo : String -> Result String Logo
decodeLogo string =
    Util.decode string logoDecoder identity


logoDecoder : Decode.Decoder Logo
logoDecoder =
    Decode.map2 Logo
        (Decode.field "name" Decode.string)
        (Decode.field "base64" Decode.string)
