module Model.Collector.WithCollection exposing (Global(..), WithCollection, decode)

import Json.Decode as Decode
import Model.Collection as Collection exposing (Collection)
import Model.State.Global.HasWallet as HasWallet exposing (HasWallet)
import Model.State.Global.HasWalletAndHandle as HasWalletAndHandle exposing (HasWalletAndHandle)
import Util.Decode as Util


type alias WithCollection =
    { collection : Collection
    , global : Global
    }


type Global
    = HasWallet HasWallet
    | HasWalletAndHandle HasWalletAndHandle


decode : String -> Result String WithCollection
decode string =
    Util.decode string decoder identity


decoder : Decode.Decoder WithCollection
decoder =
    Decode.map2 WithCollection
        (Decode.field "collection" Collection.decoder)
        (Decode.field "global" globalDecoder)


globalDecoder : Decode.Decoder Global
globalDecoder =
    Decode.oneOf
        [ Decode.map
            (\g -> HasWalletAndHandle g)
            HasWalletAndHandle.decoder
        , Decode.map
            (\g -> HasWallet g)
            HasWallet.decoder
        ]
