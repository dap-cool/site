module Model.WithCollection exposing (WithCollection, decode)

import Json.Decode as Decode
import Model.Collection as Collection exposing (Collection)
import Model.State.Global.HasWalletAndHandle as HasWalletAndHandle exposing (HasWalletAndHandle)
import Util.Decode as Util

type alias WithCollection =
    { collection: Collection
    , global: HasWalletAndHandle
    }


decode: String -> Result String WithCollection
decode string =
    Util.decode string decoder identity


decoder : Decode.Decoder WithCollection
decoder =
    Decode.map2 WithCollection
        (Decode.field "collection" Collection.decoder)
        (Decode.field "global" HasWalletAndHandle.decoder)
