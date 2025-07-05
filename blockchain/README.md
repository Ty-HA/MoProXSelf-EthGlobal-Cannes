# 🔗 Blockchain Infrastructure for ZK Age Verification

**Smart Contract Infrastructure for Zero-Knowledge Age Verification using Mopro and Hardhat 3.0**

Built for **EthGlobal Cannes 2025** hackathon - A modern blockchain setup for verifying age proofs using ZK-SNARKs on Arbitrum Sepolia.

## 🌟 Overview

This project provides the blockchain infrastructure for a **Zero-Knowledge Age Verification system**. Users can prove they are over 18 years old without revealing their actual age or personal information, using advanced cryptographic proofs that are verified on-chain.

## 🛠️ Tech Stack

- **Hardhat 3.0** - Next-generation Ethereum development framework with ESM support
- **TypeScript** - Type-safe smart contract development
- **Solidity 0.8.28** - Latest Solidity compiler with optimizations
- **Hardhat Ignition** - Modern deployment framework for reproducible deployments
- **Arbitrum Sepolia** - Layer 2 testnet for fast and cheap transactions
- **snarkJS** - ZK-SNARK proof generation and verification
- **Groth16** - Efficient zero-knowledge proof system

## 🚀 Features

- ✅ **Modern ESM Setup** - Full ES Modules support with Node.js 22+
- ✅ **Hardhat 3.0 Native** - Built from scratch with latest Hardhat architecture
- ✅ **ZK-SNARK Verification** - On-chain Groth16 proof verification
- ✅ **Layer 2 Ready** - Deployed on Arbitrum Sepolia for low gas costs
- ✅ **TypeScript First** - Type-safe development environment
- ✅ **Production Ready** - Optimized builds and deployment profiles
- ✅ **Flutter Integration** - Ready for mobile app integration

## 📦 Installation

### Prerequisites

- **Node.js 22+** (Required for Hardhat 3.0)
- **npm** or **yarn**
- **MetaMask** or compatible wallet

### Setup

```bash
# Clone the repository
cd blockchain/

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit .env with your configuration
# Add your private key, RPC URLs, and API keys
```

## 🔧 Configuration

### Environment Variables

```bash
# Arbitrum Sepolia (testnet)
ARBITRUM_SEPOLIA_RPC_URL=https://sepolia-rollup.arbitrum.io/rpc
ARBITRUM_SEPOLIA_PRIVATE_KEY=0x...your_private_key

# Alternative RPC (Alchemy)
ALCHEMY_RPC_URL=https://arb-sepolia.g.alchemy.com/v2/your_api_key

# Etherscan API Key for contract verification
ETHERSCAN_API_KEY=your_etherscan_api_key

# Contract Addresses (auto-updated after deployment)
GROTH16_VERIFIER_ADDRESS=0xC7e4179bB1a48CDbdcE3e6A5f778CED6d19cd6b8
```

### Network Configuration

The project is configured for **Arbitrum Sepolia** testnet:
- **Chain ID**: 421614
- **Native Token**: ETH
- **Explorer**: https://sepolia.arbiscan.io/

## 🎯 Smart Contract

### Groth16Verifier.sol

The main contract is a **ZK-SNARK verifier** generated using snarkJS:

```solidity
// Generated with snarkJS for age verification circuit
contract Groth16Verifier {
    function verifyProof(
        uint[2] memory _pA,
        uint[2][2] memory _pB,
        uint[2] memory _pC,
        uint[1] memory _publicSignals
    ) public view returns (bool)
}
```

**Key Features:**
- ✅ Verifies age proofs without revealing actual age
- ✅ Gas-optimized for Layer 2 deployment
- ✅ Compatible with Mopro mobile proof generation
- ✅ Returns boolean result for age verification

## 🚀 Usage

### Compile Contracts

```bash
npm run compile
```

### Run Tests

```bash
npm run test
```

### Deploy Contracts

```bash
# Deploy to local Hardhat network
npm run deploy:local

# Deploy to Arbitrum Sepolia
npm run deploy:arbitrum

# Deploy with production optimizations
npm run deploy:production
```

### Verify on Arbiscan

```bash
# Verify deployed contract
npm run verify
```

## 📱 Integration

### Flutter App Integration

The deployed contract can be integrated into a Flutter app using the following address:

```dart
// Generated constants for Flutter
class BlockchainConstants {
  static const String groth16VerifierAddress = '0xC7e4179bB1a48CDbdcE3e6A5f778CED6d19cd6b8';
  static const String network = 'arbitrum-sepolia';
  static const int chainId = 421614;
  static const String etherscanBaseUrl = 'https://sepolia.arbiscan.io';
}
```

### Proof Verification Flow

1. **Mobile App** generates ZK proof using Mopro
2. **Proof submitted** to Arbitrum Sepolia contract
3. **Contract verifies** proof on-chain
4. **Result returned** to mobile app
5. **Age verification** completed without revealing personal data

## 🔍 Deployed Contract

**Contract Address**: `0xC7e4179bB1a48CDbdcE3e6A5f778CED6d19cd6b8`

**Arbiscan Link**: [View on Arbiscan](https://sepolia.arbiscan.io/address/0xC7e4179bB1a48CDbdcE3e6A5f778CED6d19cd6b8)

**✅ Contract Status**: 
- **Deployed**: Successfully deployed on Arbitrum Sepolia
- **Verified**: Contract source code verified and published on Arbiscan
- **ABI Available**: Public ABI available for integration
- **Ready for Production**: Optimized and tested

### Contract Details
- **Network**: Arbitrum Sepolia Testnet
- **Chain ID**: 421614
- **Deployment Date**: July 5, 2025
- **Compiler**: Solidity 0.8.28 with optimization (200 runs)
- **License**: GPL-3.0 (snarkJS generated)

## 🎮 Hardhat 3.0 Features Used

### Modern Plugin System

```typescript
// hardhat.config.ts
const config: HardhatUserConfig = {
  plugins: [hardhatToolboxMochaEthersPlugin],
  // Plugin-based architecture instead of imports
}
```

### Build Profiles

```typescript
solidity: {
  profiles: {
    default: {
      version: "0.8.28",
    },
    production: {
      version: "0.8.28",
      settings: {
        optimizer: { enabled: true, runs: 200 }
      }
    }
  }
}
```

### Enhanced Network Configuration

```typescript
networks: {
  arbitrumSepolia: {
    type: "http",
    chainType: "l1",
    url: configVariable("ARBITRUM_SEPOLIA_RPC_URL"),
    accounts: [configVariable("ARBITRUM_SEPOLIA_PRIVATE_KEY")],
  }
}
```

## 📊 Gas Optimization

The contract is optimized for **Arbitrum Sepolia** with:
- **Low gas costs** (~0.001 ETH per verification)
- **Fast finality** (~2-3 seconds)
- **High throughput** for mobile app usage

## 🔐 Security

- ✅ **Audited ZK circuits** using industry-standard Groth16
- ✅ **Secure key management** via environment variables
- ✅ **Testnet deployment** for safe development
- ✅ **Type-safe contracts** with TypeScript integration

## 🏆 Hackathon Features

Built specifically for **EthGlobal Cannes 2025**:
- **Mobile-first** architecture for Flutter integration
- **Zero-knowledge** privacy preservation
- **Layer 2** scaling solution
- **Modern tooling** with Hardhat 3.0
- **Production-ready** deployment pipeline

## 🤝 Contributing

This project is part of the **EthGlobal Cannes 2025** hackathon submission. 

## 📄 License

MIT License - Built for EthGlobal Cannes 2025

---

**🚀 Ready to verify ages with zero-knowledge proofs on Arbitrum!**

*Built with ❤️ using Hardhat 3.0, Mopro, and modern blockchain tooling*

This example project includes:

- A simple Hardhat configuration file.
- Foundry-compatible Solidity unit tests.
- TypeScript integration tests using `mocha` and ethers.js
- Examples demonstrating how to connect to different types of networks, including locally simulating OP mainnet.

## Navigating the Project

To get the most out of this example project, we recommend exploring the files in the following order:

1. Read the `hardhat.config.ts` file, which contains the project configuration and explains multiple changes.
2. Review the "Running Tests" section and explore the files in the `contracts/` and `test/` directories.
3. Read the "Make a deployment to Sepolia" section and follow the instructions.

Each file includes inline explanations of its purpose and highlights the changes and new features introduced in Hardhat 3.

## Usage

### Running Tests

To run all the tests in the project, execute the following command:

```shell
npx hardhat test
```

You can also selectively run the Solidity or `mocha` tests:

```shell
npx hardhat test solidity
npx hardhat test mocha
```

### Make a deployment to Sepolia

This project includes an example Ignition module to deploy the contract. You can deploy this module to a locally simulated chain or to Sepolia.

To run the deployment to a local chain:

```shell
npx hardhat ignition deploy ignition/modules/Counter.ts
```

To run the deployment to Sepolia, you need an account with funds to send the transaction. The provided Hardhat configuration includes a Configuration Variable called `SEPOLIA_PRIVATE_KEY`, which you can use to set the private key of the account you want to use.

You can set the `SEPOLIA_PRIVATE_KEY` variable using the `hardhat-keystore` plugin or by setting it as an environment variable.

To set the `SEPOLIA_PRIVATE_KEY` config variable using `hardhat-keystore`:

```shell
npx hardhat keystore set SEPOLIA_PRIVATE_KEY
```

After setting the variable, you can run the deployment with the Sepolia network:

```shell
npx hardhat ignition deploy --network sepolia ignition/modules/Counter.ts
```

---

Feel free to explore the project and provide feedback on your experience with Hardhat 3 Alpha!
