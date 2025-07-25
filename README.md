# Legendra Mystical Token Sanctuary 

A Clarity smart contract for creating, trading, and managing mystical dragon NFTs on the Stacks blockchain.

## Overview

The Legendra Mystical Token Sanctuary is a fantasy-themed NFT marketplace contract that allows users to:
- Summon (mint) mystical dragon NFTs with custom heritage descriptions
- List dragons for sale in the marketplace
- Trade dragons with other users
- Track dragon ownership and history

## Features

###  Dragon NFTs
- **Unique Tokens**: Each dragon is a unique NFT with sequential token IDs
- **Heritage System**: Dragons have custom heritage descriptions (up to 256 characters)
- **Ownership Tracking**: Complete ownership history from summoner to current owner
- **Pricing**: Summon price tracking for each dragon

###  Marketplace
- **Listing System**: Dragon owners can list their NFTs for sale
- **Direct Trading**: Peer-to-peer STX payments for dragon purchases
- **Price Validation**: Market price must be greater than 0
- **Automatic Cleanup**: Listings automatically removed after purchase

###  Governance
- **Supreme Overlord**: Contract administrator with special privileges
- **Succession**: Overlord can transfer authority to a new principal
- **Authority Checks**: Protected functions require overlord permissions

## Contract Functions

### Public Functions

#### `summon-dragon (heritage summon-price)`
Mint a new mystical dragon NFT.
- **Parameters**:
  - `heritage`: String description (1-256 characters)
  - `summon-price`: Price in microSTX (max 1000)
- **Returns**: Token ID of the newly summoned dragon
- **Requirements**: Heritage cannot be empty, price ≤ 1000

#### `list-for-sale (dragon-token market-price)`
List a dragon for sale in the marketplace.
- **Parameters**:
  - `dragon-token`: ID of the dragon to list
  - `market-price`: Sale price in microSTX
- **Requirements**: Must own the dragon, price > 0

#### `remove-listing (dragon-token)`
Remove a dragon from the marketplace.
- **Parameters**:
  - `dragon-token`: ID of the dragon to remove
- **Requirements**: Must be the seller of the listing

#### `purchase-dragon (dragon-token)`
Buy a dragon from the marketplace.
- **Parameters**:
  - `dragon-token`: ID of the dragon to purchase
- **Effects**: Transfers STX to seller, transfers NFT to buyer
- **Requirements**: Dragon must be listed, cannot buy your own dragon

#### `crown-successor (new-ruler)`
Transfer overlord authority (overlord only).
- **Parameters**:
  - `new-ruler`: Principal to become the new overlord
- **Requirements**: Must be current overlord, new ruler must be different

### Read-Only Functions

#### `get-dragon-info (dragon-token)`
Get complete information about a dragon.
- **Returns**: `{owner, summoner, heritage, summon-price}` or `none`

#### `get-listing-info (dragon-token)`
Get marketplace listing information.
- **Returns**: `{market-price, seller}` or `none`

#### `get-total-dragons ()`
Get the total number of dragons summoned.
- **Returns**: Total count of dragons in existence

#### `show-overlord ()`
Get the current supreme overlord's principal.
- **Returns**: Current overlord principal

## Error Codes

| Code | Name | Description |
|------|------|-------------|
| u100 | `error-unauthorized-overlord` | Caller is not the supreme overlord |
| u101 | `error-wrong-owner` | Caller doesn't own the specified dragon |
| u102 | `error-no-listing` | Dragon is not listed for sale |
| u103 | `error-invalid-price` | Price must be greater than 0 |
| u104 | `error-nonexistent-token` | Dragon token doesn't exist |
| u105 | `error-empty-heritage` | Heritage description cannot be empty |
| u106 | `error-price-too-high` | Summon price exceeds maximum (1000) |

## Usage Examples

### Summoning a Dragon
```clarity
(contract-call? .legendra-sanctuary summon-dragon "Ancient Fire Dragon of the Northern Peaks" u100)
```

### Listing for Sale
```clarity
(contract-call? .legendra-sanctuary list-for-sale u1 u500)
```

### Purchasing a Dragon
```clarity
(contract-call? .legendra-sanctuary purchase-dragon u1)
```

### Checking Dragon Info
```clarity
(contract-call? .legendra-sanctuary get-dragon-info u1)
```

## Data Structures

### Dragon Chronicles (`realm-chronicles`)
Stores comprehensive dragon information:
```clarity
{
  owner: principal,        ; Current owner
  summoner: principal,     ; Original creator
  heritage: string-ascii,  ; Dragon description
  summon-price: uint       ; Original summon price
}
```

### Marketplace Listings (`marketplace-listings`)
Tracks active sales:
```clarity
{
  market-price: uint,      ; Sale price
  seller: principal        ; Dragon seller
}
```

## Security Features

- **Ownership Validation**: All functions verify proper ownership before execution
- **Price Limits**: Summon prices capped at 1000 microSTX
- **Token Existence**: Comprehensive checks for valid token IDs
- **Authority Controls**: Protected administrative functions
- **Transfer Safety**: Atomic STX and NFT transfers in purchases

## Deployment

1. Deploy the contract to the Stacks blockchain
2. The deployer becomes the initial supreme overlord
3. Dragons can be immediately summoned by any user
4. Marketplace functionality is available from deployment
