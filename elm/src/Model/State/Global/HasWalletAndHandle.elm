module Model.State.Global.HasWalletAndHandle exposing (HasWalletAndHandle, decode)

import Json.Decode as Decode
import Model.Handle exposing (Handle)
import Model.Wallet exposing (Wallet)
import Util.Decode as Util


type alias HasWalletAndHandle =
    { wallet : Wallet
    , handle : Handle
    }


decode : String -> Result String HasWalletAndHandle
decode string =
    Util.decode string decoder identity


decoder : Decode.Decoder HasWalletAndHandle
decoder =
    Decode.map2 HasWalletAndHandle
        (Decode.field "handle" Decode.string)
        (Decode.field "wallet" Decode.string)
