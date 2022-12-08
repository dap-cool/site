module Model.Collection exposing (Collection, decode, decodeList, decoder, encode, encoder, find, intersection, isEmpty)

import Json.Decode as Decode
import Json.Encode as Encode
import Model.Mint exposing (Mint)
import Set
import Util.Decode as Util


type alias Collection =
    { meta : Meta
    , accounts : Accounts
    }


type alias Meta =
    { handle : String
    , index : Int
    , name : String
    , symbol : String
    , uri : String
    , numMinted : Int -- encoded as big-int
    }


type alias Accounts =
    { pda : Mint
    , mint : Mint
    , ata : Maybe Ata
    }



{- associated token account -}


type alias Ata =
    { balance : Int
    }


encode : Collection -> String
encode collection =
    Encode.encode 0 <|
        encoder collection


encoder : Collection -> Encode.Value
encoder collection =
    let
        ataEncoder =
            case collection.accounts.ata of
                Just ata ->
                    Encode.object
                        [ ( "balance", Encode.int ata.balance )
                        ]

                Nothing ->
                    Encode.null
    in
    Encode.object
        [ ( "meta"
          , Encode.object
                [ ( "handle", Encode.string collection.meta.handle )
                , ( "index", Encode.int collection.meta.index )
                , ( "name", Encode.string collection.meta.name )
                , ( "symbol", Encode.string collection.meta.symbol )
                , ( "uri", Encode.string collection.meta.uri )
                , ( "numMinted", Encode.int collection.meta.numMinted )
                ]
          )
        , ( "accounts"
          , Encode.object
                [ ( "pda", Encode.string collection.accounts.pda )
                , ( "mint", Encode.string collection.accounts.mint )
                , ( "ata", ataEncoder )
                ]
          )
        ]


decode : String -> Result String Collection
decode string =
    Util.decode string decoder identity


decodeList : String -> Result String (List Collection)
decodeList string =
    Util.decode string (Decode.list decoder) identity


decoder : Decode.Decoder Collection
decoder =
    Decode.map2 Collection
        (Decode.field "meta" <|
            Decode.map6 Meta
                (Decode.field "handle" Decode.string)
                (Decode.field "index" Decode.int)
                (Decode.field "name" Decode.string)
                (Decode.field "symbol" Decode.string)
                (Decode.field "uri" Decode.string)
                (Decode.field "numMinted" Decode.int)
        )
        (Decode.field "accounts" <|
            Decode.map3 Accounts
                (Decode.field "pda" Decode.string)
                (Decode.field "mint" Decode.string)
                (Decode.maybe <|
                    Decode.field "ata" <|
                        Decode.map Ata
                            (Decode.field "balance" Decode.int)
                )
        )


isEmpty : Collection -> Bool
isEmpty collection =
    case collection.accounts.ata of
        Just ata ->
            ata.balance == 0

        Nothing ->
            True


intersection : List Collection -> List Collection -> List Collection
intersection left right =
    let
        leftMintAddresses : Set.Set Mint
        leftMintAddresses =
            List.map (\c -> c.accounts.mint) left
                |> Set.fromList

        intersection_ =
            List.filter
                (\c ->
                    Set.member ((\c_ -> c_.accounts.mint) c) leftMintAddresses
                )
                right
    in
    intersection_


find : Collection -> List Collection -> Maybe Collection
find collection list =
    List.filter
        (\c ->
            c.accounts.mint == collection.accounts.mint
        )
        list
        |> List.head
