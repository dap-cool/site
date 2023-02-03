module Model.State.Global.HasWallet exposing (HasWallet, decode, decoder)

import Json.Decode as Decode
import Model.Collection as Collection exposing (Collection)
import Model.State.Global.FeaturedCreators as FeaturedCreators exposing (FeaturedCreators)
import Model.Wallet exposing (Wallet)
import Util.Decode as Util


type alias HasWallet =
    { wallet : Wallet
    , collected : List Collection
    , featuredCreators : FeaturedCreators
    }


decode : String -> Result String HasWallet
decode string =
    Util.decode string decoder identity


decoder : Decode.Decoder HasWallet
decoder =
    Decode.map3 HasWallet
        (Decode.field "wallet" Decode.string)
        (Decode.field "collected" <| Decode.list Collection.decoder)
        (Decode.field "featuredCreators" <| FeaturedCreators.decoder)
