module Model.Global.HasWallet exposing (HasWallet, decoder, encoder)

import Json.Decode as Decode
import Json.Encode as Encode
import Model.Collection as Collection exposing (Collection)
import Model.Wallet exposing (Wallet)


type alias HasWallet =
    { wallet : Wallet
    , collections : List Collection
    }


decoder : Decode.Decoder HasWallet
decoder =
    Decode.map2 HasWallet
        (Decode.field "wallet" Decode.string)
        (Decode.field "collections" <| Decode.list Collection.decoder)


encoder : HasWallet -> Encode.Value
encoder hasWallet =
    Encode.object
        [ ( "wallet", Encode.string hasWallet.wallet )
        , ( "collections", Encode.list Collection.encoder hasWallet.collections )
        ]
