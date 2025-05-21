# 🐕 Monad Puppy Farm

A DeFi game built on the Monad testnet where users can stake MONAD tokens to earn $BONES, mint and level up virtual puppies.

## Features

- Stake MONAD tokens to earn $BONES
- Mint puppies for 1 MONAD each
- Feed puppies with $BONES to level them up
- Each puppy level increases your $BONES earning rate
- Dynamic feed costs that increase with each level
- Modern React frontend with dark mode UI

## Contract Details

Latest deployment: `0xD56ddc88E1D8718371C089B77F32499604193E28`

### Tokenomics

- Base rate: 100,000 $BONES per 10 MONAD staked per day
- Each puppy level adds a 1x multiplier to earnings
- Feed costs increase by 1.5x after each level up
- Initial feed cost: 20,000 $BONES

## Development

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build
```

## Technologies Used

- Solidity
- React
- TypeScript
- Vite
- ethers.js
- Monad testnet

## License

MIT 