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
      "name": "initCreatorMetadata",
      "accounts": [
        {
          "name": "handle",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "payer",
          "isMut": false,
          "isSigner": true
        }
      ],
      "args": [
        {
          "name": "metadata",
          "type": "publicKey"
        }
      ]
    },
    {
      "name": "createNft",
      "accounts": [
        {
          "name": "boss",
          "isMut": false,
          "isSigner": false
        },
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
          "name": "mintAta",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "metadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "usdc",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "usdcAta",
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
          "name": "bumps",
          "type": {
            "defined": "CreateNftBumps"
          }
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
        },
        {
          "name": "image",
          "type": "u8"
        },
        {
          "name": "size",
          "type": "u64"
        },
        {
          "name": "creatorDistribution",
          "type": "u64"
        },
        {
          "name": "price",
          "type": "u64"
        },
        {
          "name": "fee",
          "type": "u16"
        }
      ]
    },
    {
      "name": "mintNewCopy",
      "accounts": [
        {
          "name": "boss",
          "isMut": false,
          "isSigner": false
        },
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
          "name": "collected",
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
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "mintAta",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "usdc",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "usdcAtaSrc",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "usdcAtaDstHandle",
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
          "name": "bumps",
          "type": {
            "defined": "MintNewCopyBumps"
          }
        },
        {
          "name": "n",
          "type": "u8"
        }
      ]
    },
    {
      "name": "initBoss",
      "accounts": [
        {
          "name": "boss",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "usdc",
          "isMut": false,
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
      "args": []
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
            "name": "image",
            "type": "u8"
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
            "name": "price",
            "type": "u64"
          },
          {
            "name": "fee",
            "type": "u16"
          }
        ]
      }
    },
    {
      "name": "boss",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "authority",
            "type": "publicKey"
          },
          {
            "name": "usdc",
            "type": "publicKey"
          },
          {
            "name": "fee",
            "type": "u64"
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
      "name": "collected",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "collected",
            "type": "bool"
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
            "name": "metadata",
            "type": {
              "option": "publicKey"
            }
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
      "name": "CreateNftBumps",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "boss",
            "type": "u8"
          },
          {
            "name": "handle",
            "type": "u8"
          },
          {
            "name": "authority",
            "type": "u8"
          },
          {
            "name": "metadata",
            "type": "u8"
          }
        ]
      }
    },
    {
      "name": "MintNewCopyBumps",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "boss",
            "type": "u8"
          },
          {
            "name": "handle",
            "type": "u8"
          },
          {
            "name": "authority",
            "type": "u8"
          }
        ]
      }
    },
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
      "name": "CreatorMetadataAlreadyProvisioned",
      "msg": "Creator metadata has already been provisioned. Edit, instead."
    },
    {
      "code": 6002,
      "name": "CreatorDistributionTooLarge",
      "msg": "Creator distribution must be smaller than total supply."
    },
    {
      "code": 6003,
      "name": "SoldOut",
      "msg": "Primary sale is sold out. Check secondary markets."
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
      "name": "initCreatorMetadata",
      "accounts": [
        {
          "name": "handle",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "payer",
          "isMut": false,
          "isSigner": true
        }
      ],
      "args": [
        {
          "name": "metadata",
          "type": "publicKey"
        }
      ]
    },
    {
      "name": "createNft",
      "accounts": [
        {
          "name": "boss",
          "isMut": false,
          "isSigner": false
        },
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
          "name": "mintAta",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "metadata",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "usdc",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "usdcAta",
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
          "name": "bumps",
          "type": {
            "defined": "CreateNftBumps"
          }
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
        },
        {
          "name": "image",
          "type": "u8"
        },
        {
          "name": "size",
          "type": "u64"
        },
        {
          "name": "creatorDistribution",
          "type": "u64"
        },
        {
          "name": "price",
          "type": "u64"
        },
        {
          "name": "fee",
          "type": "u16"
        }
      ]
    },
    {
      "name": "mintNewCopy",
      "accounts": [
        {
          "name": "boss",
          "isMut": false,
          "isSigner": false
        },
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
          "name": "collected",
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
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "mintAta",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "usdc",
          "isMut": false,
          "isSigner": false
        },
        {
          "name": "usdcAtaSrc",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "usdcAtaDstHandle",
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
          "name": "bumps",
          "type": {
            "defined": "MintNewCopyBumps"
          }
        },
        {
          "name": "n",
          "type": "u8"
        }
      ]
    },
    {
      "name": "initBoss",
      "accounts": [
        {
          "name": "boss",
          "isMut": true,
          "isSigner": false
        },
        {
          "name": "usdc",
          "isMut": false,
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
      "args": []
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
            "name": "image",
            "type": "u8"
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
            "name": "price",
            "type": "u64"
          },
          {
            "name": "fee",
            "type": "u16"
          }
        ]
      }
    },
    {
      "name": "boss",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "authority",
            "type": "publicKey"
          },
          {
            "name": "usdc",
            "type": "publicKey"
          },
          {
            "name": "fee",
            "type": "u64"
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
      "name": "collected",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "collected",
            "type": "bool"
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
            "name": "metadata",
            "type": {
              "option": "publicKey"
            }
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
      "name": "CreateNftBumps",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "boss",
            "type": "u8"
          },
          {
            "name": "handle",
            "type": "u8"
          },
          {
            "name": "authority",
            "type": "u8"
          },
          {
            "name": "metadata",
            "type": "u8"
          }
        ]
      }
    },
    {
      "name": "MintNewCopyBumps",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "boss",
            "type": "u8"
          },
          {
            "name": "handle",
            "type": "u8"
          },
          {
            "name": "authority",
            "type": "u8"
          }
        ]
      }
    },
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
      "name": "CreatorMetadataAlreadyProvisioned",
      "msg": "Creator metadata has already been provisioned. Edit, instead."
    },
    {
      "code": 6002,
      "name": "CreatorDistributionTooLarge",
      "msg": "Creator distribution must be smaller than total supply."
    },
    {
      "code": 6003,
      "name": "SoldOut",
      "msg": "Primary sale is sold out. Check secondary markets."
    }
  ]
};
