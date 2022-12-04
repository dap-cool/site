export type DapCool = {
  "version": "1.0.0",
  "name": "dap_cool",
  "instructions": [
    {
      "name": "initNewCreator",
      "accounts": [
        {
          "name": "handlePda",
          "isMut": true,
          "isSigner": false
        },
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
          "name": "handle",
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
          "name": "handle",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "authority",
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
      "args": [
        {
          "name": "n",
          "type": "u8"
        }
      ]
    },
    {
      "name": "mintNewCopy",
      "accounts": [
        {
          "name": "collector",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collectionPda",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "handle",
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
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "metadata",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "masterEdition",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "masterEditionAta",
          "isMut": false,
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
          "name": "collector",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collectionPda",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "handle",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "authority",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collection",
          "isMut": false,
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
            "name": "handle",
            "type": "string"
          },
          {
            "name": "index",
            "type": "u8"
          },
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
      "name": "collector",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "numCollected",
            "type": "u8"
          },
          {
            "name": "latestMarked",
            "type": "bool"
          }
        ]
      }
    },
    {
      "name": "collection",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "mint",
            "type": "publicKey"
          },
          {
            "name": "marked",
            "type": "bool"
          },
          {
            "name": "handle",
            "type": "string"
          },
          {
            "name": "index",
            "type": "u8"
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
            "name": "authority",
            "type": "publicKey"
          },
          {
            "name": "handle",
            "type": "publicKey"
          }
        ]
      }
    },
    {
      "name": "handle",
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
            "type": "bytes"
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
    },
    {
      "code": 6001,
      "name": "EveryCollectionMustBeMarked",
      "msg": "Your previous collection must be marked before purchasing another."
    }
  ]
};

export const IDL: DapCool = {
  "version": "1.0.0",
  "name": "dap_cool",
  "instructions": [
    {
      "name": "initNewCreator",
      "accounts": [
        {
          "name": "handlePda",
          "isMut": true,
          "isSigner": false
        },
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
          "name": "handle",
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
          "name": "handle",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "authority",
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
      "args": [
        {
          "name": "n",
          "type": "u8"
        }
      ]
    },
    {
      "name": "mintNewCopy",
      "accounts": [
        {
          "name": "collector",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collectionPda",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "handle",
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
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "metadata",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "masterEdition",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "masterEditionAta",
          "isMut": false,
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
          "name": "collector",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collectionPda",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "handle",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "authority",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "collection",
          "isMut": false,
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
            "name": "handle",
            "type": "string"
          },
          {
            "name": "index",
            "type": "u8"
          },
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
      "name": "collector",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "numCollected",
            "type": "u8"
          },
          {
            "name": "latestMarked",
            "type": "bool"
          }
        ]
      }
    },
    {
      "name": "collection",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "mint",
            "type": "publicKey"
          },
          {
            "name": "marked",
            "type": "bool"
          },
          {
            "name": "handle",
            "type": "string"
          },
          {
            "name": "index",
            "type": "u8"
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
            "name": "authority",
            "type": "publicKey"
          },
          {
            "name": "handle",
            "type": "publicKey"
          }
        ]
      }
    },
    {
      "name": "handle",
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
            "type": "bytes"
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
    },
    {
      "code": 6001,
      "name": "EveryCollectionMustBeMarked",
      "msg": "Your previous collection must be marked before purchasing another."
    }
  ]
};
