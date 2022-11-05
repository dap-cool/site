export type SomosCrowd = {
  "version": "1.0.0",
  "name": "somos_crowd",
  "instructions": [
    {
      "name": "initNewCreator",
      "accounts": [
        {
          "name": "creator",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "payer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "handle",
          "type": "string"
        }
      ]
    },
    {
      "name": "createNft",
      "accounts": [
        {
          "name": "creator",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "authority",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "mint",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "metadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "masterEdition",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "masterEditionAta",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "payer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "associatedTokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "metadataProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
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
          "name": "size",
          "type": "u64"
        }
      ]
    },
    {
      "name": "createCollection",
      "accounts": [
        {
          "name": "creator",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "authority",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "mint",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collection",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "collectionMetadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collectionMasterEdition",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collectionMasterEditionAta",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "payer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "associatedTokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "metadataProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": []
    },
    {
      "name": "mintNewCopy",
      "accounts": [
        {
          "name": "creator",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "authority",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "mint",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "metadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "masterEdition",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "masterEditionAta",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "newMint",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "newMetadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "newEdition",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "newEditionMark",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "newEditionAta",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "payer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "associatedTokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "metadataProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "n",
          "type": "u8"
        }
      ]
    },
    {
      "name": "addNewCopyToCollection",
      "accounts": [
        {
          "name": "creator",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "authority",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "mint",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collection",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collectionMetadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collectionMasterEdition",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "newMint",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "newMetadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "payer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "metadataProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "n",
          "type": "u8"
        }
      ]
    }
  ],
  "accounts": [
    {
      "name": "authority",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "mint",
            "type": "publicKey"
          },
          {
            "name": "collection",
            "type": "publicKey"
          },
          {
            "name": "numMinted",
            "type": "u64"
          },
          {
            "name": "totalSupply",
            "type": "u64"
          },
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
          }
        ]
      }
    },
    {
      "name": "creator",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "handle",
            "type": "string"
          },
          {
            "name": "authority",
            "type": "publicKey"
          },
          {
            "name": "numCollections",
            "type": "u8"
          },
          {
            "name": "pinned",
            "type": {
              "defined": "Pinned"
            }
          }
        ]
      }
    }
  ],
  "types": [
    {
      "name": "Pinned",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "collections",
            "type": {
              "array": [
                "u8",
                10
              ]
            }
          }
        ]
      }
    }
  ],
  "errors": [
    {
      "code": 6000,
      "name": "HandleTooLong",
      "msg": "Max handle length is 16 bytes."
    }
  ]
};

export const IDL: SomosCrowd = {
  "version": "1.0.0",
  "name": "somos_crowd",
  "instructions": [
    {
      "name": "initNewCreator",
      "accounts": [
        {
          "name": "creator",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "payer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "handle",
          "type": "string"
        }
      ]
    },
    {
      "name": "createNft",
      "accounts": [
        {
          "name": "creator",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "authority",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "mint",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "metadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "masterEdition",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "masterEditionAta",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "payer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "associatedTokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "metadataProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
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
          "name": "size",
          "type": "u64"
        }
      ]
    },
    {
      "name": "createCollection",
      "accounts": [
        {
          "name": "creator",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "authority",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "mint",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collection",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "collectionMetadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collectionMasterEdition",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collectionMasterEditionAta",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "payer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "associatedTokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "metadataProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": []
    },
    {
      "name": "mintNewCopy",
      "accounts": [
        {
          "name": "creator",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "authority",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "mint",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "metadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "masterEdition",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "masterEditionAta",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "newMint",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "newMetadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "newEdition",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "newEditionMark",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "newEditionAta",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "payer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "associatedTokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "metadataProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "n",
          "type": "u8"
        }
      ]
    },
    {
      "name": "addNewCopyToCollection",
      "accounts": [
        {
          "name": "creator",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "authority",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "mint",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collection",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collectionMetadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collectionMasterEdition",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "newMint",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "newMetadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "payer",
          "isMut": true,
          "isSigner": true
        },
        {
          "name": "tokenProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "metadataProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "systemProgram",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "rent",
          "isMut": false,
          "isSigner": false
        }
      ],
      "args": [
        {
          "name": "n",
          "type": "u8"
        }
      ]
    }
  ],
  "accounts": [
    {
      "name": "authority",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "mint",
            "type": "publicKey"
          },
          {
            "name": "collection",
            "type": "publicKey"
          },
          {
            "name": "numMinted",
            "type": "u64"
          },
          {
            "name": "totalSupply",
            "type": "u64"
          },
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
          }
        ]
      }
    },
    {
      "name": "creator",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "handle",
            "type": "string"
          },
          {
            "name": "authority",
            "type": "publicKey"
          },
          {
            "name": "numCollections",
            "type": "u8"
          },
          {
            "name": "pinned",
            "type": {
              "defined": "Pinned"
            }
          }
        ]
      }
    }
  ],
  "types": [
    {
      "name": "Pinned",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "collections",
            "type": {
              "array": [
                "u8",
                10
              ]
            }
          }
        ]
      }
    }
  ],
  "errors": [
    {
      "code": 6000,
      "name": "HandleTooLong",
      "msg": "Max handle length is 16 bytes."
    }
  ]
};
