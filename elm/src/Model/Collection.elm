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
    , numMinted : Int -- encoded as big-int
    }


type alias Accounts =
    { pda : Mint
    , mint : Mint
    , collection : Maybe Mint
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
        collectionEncoder =
            case collection.accounts.collection of
                Just mint ->
                    Encode.string mint

                Nothing ->
                    Encode.null

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
                , ( "numMinted", Encode.int collection.meta.numMinted )
                ]
          )
        , ( "accounts"
          , Encode.object
                [ ( "pda", Encode.string collection.accounts.pda )
                , ( "mint", Encode.string collection.accounts.mint )
                , ( "collection", collectionEncoder )
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
            Decode.map5 Meta
                (Decode.field "handle" Decode.string)
                (Decode.field "index" Decode.int)
                (Decode.field "name" Decode.string)
                (Decode.field "symbol" Decode.string)
                (Decode.field "numMinted" Decode.int)
        )
        (Decode.field "accounts" <|
            Decode.map4 Accounts
                (Decode.field "pda" Decode.string)
                (Decode.field "mint" Decode.string)
                (Decode.maybe <| Decode.field "collection" Decode.string)
                (Decode.maybe <|
                    Decode.field "ata" <|
                        Decode.map Ata
                            (Decode.field "balance" Decode.int)
                )
        )


isEmpty : Collection -> Bool
isEmpty collection =
    case collection.accounts.collection of
        Just id ->
            id == empty

        Nothing ->
            True


empty : String
empty =
    "11111111111111111111111111111111"


intersection : List Collection -> List Collection -> List Collection
intersection left right =
    let
        leftMintAddresses : Set.Set Mint
        leftMintAddresses =
            List.map (\c -> c.accounts.pda) left
                |> Set.fromList

        intersection_ =
            List.filter
                (\c ->
                    Set.member ((\c_ -> c_.accounts.pda) c) leftMintAddresses
                )
                right
    in
    intersection_


find : Collection -> List Collection -> Maybe Collection
find collection list =
    List.filter
        (\c ->
            c.accounts.pda == collection.accounts.pda
        )
        list
        |> List.head
