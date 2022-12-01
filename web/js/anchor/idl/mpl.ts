export type MplTokenMetadata = {
    "version": "1.6.2",
    "name": "mpl_token_metadata",
    "instructions": [],
    "accounts": [
        {
            "name": "Metadata",
            "type": {
                "kind": "struct",
                "fields": [
                    {
                        "name": "key",
                        "type": {
                            "defined": "Key"
                        }
                    },
                    {
                        "name": "updateAuthority",
                        "type": "publicKey"
                    },
                    {
                        "name": "mint",
                        "type": "publicKey"
                    },
                    {
                        "name": "data",
                        "type": {
                            "defined": "Data"
                        }
                    },
                    {
                        "name": "primarySaleHappened",
                        "type": "bool"
                    },
                    {
                        "name": "isMutable",
                        "type": "bool"
                    },
                    {
                        "name": "editionNonce",
                        "type": {
                            "option": "u8"
                        }
                    },
                    {
                        "name": "tokenStandard",
                        "type": {
                            "option": {
                                "defined": "TokenStandard"
                            }
                        }
                    },
                    {
                        "name": "collection",
                        "type": {
                            "option": {
                                "defined": "Collection"
                            }
                        }
                    },
                    {
                        "name": "uses",
                        "type": {
                            "option": {
                                "defined": "Uses"
                            }
                        }
                    },
                    {
                        "name": "collectionDetails",
                        "type": {
                            "option": {
                                "defined": "CollectionDetails"
                            }
                        }
                    }
                ]
            }
        }
    ],
    "types": [
        {
            "name": "Collection",
            "type": {
                "kind": "struct",
                "fields": [
                    {
                        "name": "verified",
                        "type": "bool"
                    },
                    {
                        "name": "key",
                        "type": "publicKey"
                    }
                ]
            }
        },
        {
            "name": "Creator",
            "type": {
                "kind": "struct",
                "fields": [
                    {
                        "name": "address",
                        "type": "publicKey"
                    },
                    {
                        "name": "verified",
                        "type": "bool"
                    },
                    {
                        "name": "share",
                        "type": "u8"
                    }
                ]
            }
        },
        {
            "name": "Data",
            "type": {
                "kind": "struct",
                "fields": [
                    {
                        "name": "name",
                        "type": "string"
                    },
                    {
                        "name": "symbol",
                        "type": "string"
                    },
                    {
                        "name": "uri",
                        "type": "string"
                    },
                    {
                        "name": "sellerFeeBasisPoints",
                        "type": "u16"
                    },
                    {
                        "name": "creators",
                        "type": {
                            "option": {
                                "vec": {
                                    "defined": "Creator"
                                }
                            }
                        }
                    }
                ]
            }
        },
        {
            "name": "Uses",
            "type": {
                "kind": "struct",
                "fields": [
                    {
                        "name": "useMethod",
                        "type": {
                            "defined": "UseMethod"
                        }
                    },
                    {
                        "name": "remaining",
                        "type": "u64"
                    },
                    {
                        "name": "total",
                        "type": "u64"
                    }
                ]
            }
        },
        {
            "name": "TokenStandard",
            "type": {
                "kind": "enum",
                "variants": [
                    {
                        "name": "NonFungible"
                    },
                    {
                        "name": "FungibleAsset"
                    },
                    {
                        "name": "Fungible"
                    },
                    {
                        "name": "NonFungibleEdition"
                    }
                ]
            }
        },
        {
            "name": "Key",
            "type": {
                "kind": "enum",
                "variants": [
                    {
                        "name": "Uninitialized"
                    },
                    {
                        "name": "EditionV1"
                    },
                    {
                        "name": "MasterEditionV1"
                    },
                    {
                        "name": "ReservationListV1"
                    },
                    {
                        "name": "MetadataV1"
                    },
                    {
                        "name": "ReservationListV2"
                    },
                    {
                        "name": "MasterEditionV2"
                    },
                    {
                        "name": "EditionMarker"
                    },
                    {
                        "name": "UseAuthorityRecord"
                    },
                    {
                        "name": "CollectionAuthorityRecord"
                    },
                    {
                        "name": "TokenOwnedEscrow"
                    }
                ]
            }
        },
        {
            "name": "CollectionDetails",
            "type": {
                "kind": "enum",
                "variants": [
                    {
                        "name": "V1",
                        "fields": [
                            {
                                "name": "size",
                                "type": "u64"
                            }
                        ]
                    }
                ]
            }
        },
        {
            "name": "UseMethod",
            "type": {
                "kind": "enum",
                "variants": [
                    {
                        "name": "Burn"
                    },
                    {
                        "name": "Multiple"
                    },
                    {
                        "name": "Single"
                    }
                ]
            }
        }
    ],
    "errors": [],
    "metadata": {
        "origin": "shank",
        "address": "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s",
        "binaryVersion": "0.0.11",
        "libVersion": "0.0.11"
    }
};

export const MPL_IDL: MplTokenMetadata = {
    "version": "1.6.2",
    "name": "mpl_token_metadata",
    "instructions": [],
    "accounts": [
        {
            "name": "Metadata",
            "type": {
                "kind": "struct",
                "fields": [
                    {
                        "name": "key",
                        "type": {
                            "defined": "Key"
                        }
                    },
                    {
                        "name": "updateAuthority",
                        "type": "publicKey"
                    },
                    {
                        "name": "mint",
                        "type": "publicKey"
                    },
                    {
                        "name": "data",
                        "type": {
                            "defined": "Data"
                        }
                    },
                    {
                        "name": "primarySaleHappened",
                        "type": "bool"
                    },
                    {
                        "name": "isMutable",
                        "type": "bool"
                    },
                    {
                        "name": "editionNonce",
                        "type": {
                            "option": "u8"
                        }
                    },
                    {
                        "name": "tokenStandard",
                        "type": {
                            "option": {
                                "defined": "TokenStandard"
                            }
                        }
                    },
                    {
                        "name": "collection",
                        "type": {
                            "option": {
                                "defined": "Collection"
                            }
                        }
                    },
                    {
                        "name": "uses",
                        "type": {
                            "option": {
                                "defined": "Uses"
                            }
                        }
                    },
                    {
                        "name": "collectionDetails",
                        "type": {
                            "option": {
                                "defined": "CollectionDetails"
                            }
                        }
                    }
                ]
            }
        }
    ],
    "types": [
        {
            "name": "Collection",
            "type": {
                "kind": "struct",
                "fields": [
                    {
                        "name": "verified",
                        "type": "bool"
                    },
                    {
                        "name": "key",
                        "type": "publicKey"
                    }
                ]
            }
        },
        {
            "name": "Creator",
            "type": {
                "kind": "struct",
                "fields": [
                    {
                        "name": "address",
                        "type": "publicKey"
                    },
                    {
                        "name": "verified",
                        "type": "bool"
                    },
                    {
                        "name": "share",
                        "type": "u8"
                    }
                ]
            }
        },
        {
            "name": "Data",
            "type": {
                "kind": "struct",
                "fields": [
                    {
                        "name": "name",
                        "type": "string"
                    },
                    {
                        "name": "symbol",
                        "type": "string"
                    },
                    {
                        "name": "uri",
                        "type": "string"
                    },
                    {
                        "name": "sellerFeeBasisPoints",
                        "type": "u16"
                    },
                    {
                        "name": "creators",
                        "type": {
                            "option": {
                                "vec": {
                                    "defined": "Creator"
                                }
                            }
                        }
                    }
                ]
            }
        },
        {
            "name": "Uses",
            "type": {
                "kind": "struct",
                "fields": [
                    {
                        "name": "useMethod",
                        "type": {
                            "defined": "UseMethod"
                        }
                    },
                    {
                        "name": "remaining",
                        "type": "u64"
                    },
                    {
                        "name": "total",
                        "type": "u64"
                    }
                ]
            }
        },
        {
            "name": "TokenStandard",
            "type": {
                "kind": "enum",
                "variants": [
                    {
                        "name": "NonFungible"
                    },
                    {
                        "name": "FungibleAsset"
                    },
                    {
                        "name": "Fungible"
                    },
                    {
                        "name": "NonFungibleEdition"
                    }
                ]
            }
        },
        {
            "name": "Key",
            "type": {
                "kind": "enum",
                "variants": [
                    {
                        "name": "Uninitialized"
                    },
                    {
                        "name": "EditionV1"
                    },
                    {
                        "name": "MasterEditionV1"
                    },
                    {
                        "name": "ReservationListV1"
                    },
                    {
                        "name": "MetadataV1"
                    },
                    {
                        "name": "ReservationListV2"
                    },
                    {
                        "name": "MasterEditionV2"
                    },
                    {
                        "name": "EditionMarker"
                    },
                    {
                        "name": "UseAuthorityRecord"
                    },
                    {
                        "name": "CollectionAuthorityRecord"
                    },
                    {
                        "name": "TokenOwnedEscrow"
                    }
                ]
            }
        },
        {
            "name": "CollectionDetails",
            "type": {
                "kind": "enum",
                "variants": [
                    {
                        "name": "V1",
                        "fields": [
                            {
                                "name": "size",
                                "type": "u64"
                            }
                        ]
                    }
                ]
            }
        },
        {
            "name": "UseMethod",
            "type": {
                "kind": "enum",
                "variants": [
                    {
                        "name": "Burn"
                    },
                    {
                        "name": "Multiple"
                    },
                    {
                        "name": "Single"
                    }
                ]
            }
        }
    ],
    "errors": [],
    "metadata": {
        "origin": "shank",
        "address": "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s",
        "binaryVersion": "0.0.11",
        "libVersion": "0.0.11"
    }
};
