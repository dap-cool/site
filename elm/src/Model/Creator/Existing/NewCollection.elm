module Model.Creator.Existing.NewCollection exposing (MetaForm, NewCollection(..), decode, default, encode)

import Json.Decode as Decode
import Json.Encode as Encode
import Model.Collection exposing (Collection)
import Model.Mint exposing (Mint)
import Model.State.Global.HasWalletAndHandle as HasWalletAndHandle exposing (HasWalletAndHandle)
import Util.Decode as Util


type NewCollection
    = Input MetaForm Submitted
      -- create nft
      -- | WaitingForProvision -- waiting for step 1 to finish
      -- | HasProvision Form -- ready step 2
      -- | WaitingForUpload -- waiting for step 2 to finish
      -- | HasUpload Form -- ready for step 3
      -- | WaitingForCreateNft -- waiting for step 3 to finish
    | HasCreateNft Collection
      -- mark nft
    | WaitingForMarkNft Collection
    | Done Collection



{- needs to be in same div as input for DOM preservation -}


type alias Submitted =
    Bool


type alias Form =
    { step : Int
    , meta : MetaForm
    , shdw : Maybe ShdwForm
    }


type alias WithGlobal =
    { global : HasWalletAndHandle
    , form : Form
    }


type alias MetaForm =
    { name : String
    , symbol : String
    }


type alias ShdwForm =
    { account : Mint
    }


default : MetaForm
default =
    { name = ""
    , symbol = ""
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
                , ( "meta"
                  , Encode.object
                        [ ( "name", Encode.string form.meta.name )
                        , ( "symbol", Encode.string form.meta.symbol )
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
            Decode.map3 Form
                (Decode.field "step" Decode.int)
                (Decode.field "meta" <|
                    Decode.map2 MetaForm
                        (Decode.field "name" Decode.string)
                        (Decode.field "symbol" Decode.string)
                )
                (Decode.maybe <|
                    Decode.field "shdw" <|
                        Decode.map ShdwForm
                            (Decode.field "account" Decode.string)
                )
        )
