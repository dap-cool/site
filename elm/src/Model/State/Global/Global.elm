module Model.State.Global.Global exposing (Global(..), getFeaturedCreators)

import Model.State.Global.FeaturedCreators exposing (FeaturedCreators)
import Model.State.Global.HasWallet exposing (HasWallet)
import Model.State.Global.HasWalletAndHandle exposing (HasWalletAndHandle)


type Global
    = NoWalletYet FeaturedCreators
    | WalletMissing FeaturedCreators -- no browser extension found
    | HasWallet HasWallet
    | HasWalletAndHandle HasWalletAndHandle


getFeaturedCreators : Global -> FeaturedCreators
getFeaturedCreators global =
    case global of
        NoWalletYet featuredCreators ->
            featuredCreators

        WalletMissing featuredCreators ->
            featuredCreators

        HasWallet hasWallet ->
            hasWallet.featuredCreators

        HasWalletAndHandle hasWalletAndHandle ->
            hasWalletAndHandle.featuredCreators
