# 🆔 ZK Age Verification

[![EthGlobal](https://img.shields.io/badge/EthGlobal-Cannes-blue)](https://ethglobal.com/events/cannes)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)](https://flutter.dev)
[![Circom](https://img.shields.io/badge/Circom-ZK--SNARKs-green)](https://circom.io)
[![Arbitrum](https://img.shields.io/badge/Arbitrum-Sepolia-orange)](https://arbitrum.io)

> **Zero-Knowledge Age Verification for Privacy-Preserving Identity**  
> Built for EthGlobal Cannes 2025 🇫🇷

## 🎯 Overview

MoProXSelf is a privacy-preserving age verification system that uses Zero-Knowledge proofs to verify age without revealing personal information. Users can prove they meet age requirements (18+, 21+, etc.) without exposing their actual age or identity.

## ✨ Features

- **🔐 Zero-Knowledge Proofs**: Verify age without revealing actual age
- **📱 Mobile-First**: Flutter app for iOS and Android
- **⚡ Fast Verification**: Groth16 proofs for efficient verification
- **🌐 On-Chain**: Smart contract verification on Arbitrum Sepolia
- **🎫 QR Code Integration**: Generate and scan age verification proofs
- **🔒 Privacy-Preserving**: No personal data stored or transmitted

## 🏗️ Architecture

### Core Components

1. **🔗 Circom Circuit** (`circuits/test_age_verification.circom`)
   - Zero-knowledge circuit for age verification
   - Constraint: `userAge >= minAge`
   - Public signals: `[minAge, userAge]`

2. **📱 Flutter App** (`lib/`)
   - User interface for proof generation
   - QR code generation and scanning
   - Integration with MoPro Flutter plugin

3. **⚖️ Smart Contract** (`blockchain/contracts/AgeVerifier.sol`)
   - Groth16 verifier contract
   - Deployed on Arbitrum Sepolia: `0x9B14F909E21007f1426dc0AeD5c1A484E624555F`
   - Verified on Arbiscan ✅

4. **🔧 MoPro Integration**
   - Mobile proof generation using MoPro Flutter plugin
   - Circom circuit compilation and trusted setup

## 🚀 Quick Start

### Prerequisites

```bash
# Install Flutter
flutter --version

# Install Node.js dependencies
npm install -g snarkjs circom

# Install Circom
git clone https://github.com/iden3/circom.git
cd circom && cargo build --release
```

### Setup

1. **Clone the repository**
```bash
git clone https://github.com/your-username/MoProXSelf-EthGlobal-Cannes.git
cd MoProXSelf-EthGlobal-Cannes
```

2. **Install Flutter dependencies**
```bash
flutter pub get
```

3. **Circuit Setup** (Already done)
```bash
cd circuits/
# Circuit is already compiled and setup is complete
# Files: test_age_verification_final.zkey, test_age_verification.wasm
```

4. **Run the app**
```bash
flutter run
```

## 📋 Use Cases

- **🍺 Alcohol Purchase**: Verify 18+ age
- **🚗 Driving License**: Verify 16+ age  
- **🗳️ Voting**: Verify 18+ age
- **⚖️ Legal Contracts**: Verify 18+ age

## 🔧 Technical Details

### Circuit Constraints

```javascript
// Main constraint: userAge >= minAge
component geq = GreaterEqualThan(8);
geq.in[0] <== userAge;
geq.in[1] <== minAge;
geq.out === 1;

// Public outputs
minAge <== minAge;
userAge <== userAge;
```

### Smart Contract

- **Network**: Arbitrum Sepolia
- **Contract**: `0x9B14F909E21007f1426dc0AeD5c1A484E624555F`
- **Verification**: Groth16 proof verification
- **Gas Cost**: ~300k gas per verification

### Proof Generation

```dart
// Generate proof with MoPro
final proofResult = await _mopro.generateCircomProof(
  'assets/test_age_verification_final.zkey',
  inputsJson,
  ProofLib.arkworks,
);
```

## 🛠️ Development

### Project Structure

```
├── lib/                    # Flutter app source
│   ├── screens/           # UI screens
│   ├── services/          # Business logic
│   └── core/             # Constants and utilities
├── circuits/              # Zero-knowledge circuits
├── blockchain/            # Smart contracts
├── assets/               # App assets (.zkey, .wasm)
└── mopro_flutter_plugin/ # MoPro integration
```

### Key Files

- `circuits/test_age_verification.circom` - Main ZK circuit
- `blockchain/contracts/AgeVerifier.sol` - Verifier contract
- `lib/screens/generate_proof_screen.dart` - Proof generation UI
- `lib/services/blockchain_service.dart` - Contract interaction

### Testing

```bash
# Run Flutter tests
flutter test

# Test circuit locally
cd circuits/
node test_circuit.js

# Test contract
cd blockchain/
npx hardhat test
```

## 🌐 Deployment

### Contract Deployment

```bash
cd blockchain/
npx hardhat run scripts/deploy.js --network arbitrum-sepolia
```

### Circuit Compilation

```bash
cd circuits/
circom test_age_verification.circom --r1cs --wasm --sym
```

### Trusted Setup

```bash
# Powers of Tau ceremony
snarkjs powersoftau new bn128 12 pot12_0000.ptau
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau

# Circuit-specific setup
snarkjs groth16 setup test_age_verification.r1cs pot12_final.ptau test_age_verification_0000.zkey
snarkjs zkey contribute test_age_verification_0000.zkey test_age_verification_final.zkey
```

## 📊 Live Demo

### Contract Information

- **Address**: `0x9B14F909E21007f1426dc0AeD5c1A484E624555F`
- **Network**: Arbitrum Sepolia
- **Explorer**: [View on Arbiscan](https://sepolia.arbiscan.io/address/0x9B14F909E21007f1426dc0AeD5c1A484E624555F)
- **Verified**: ✅ Source code verified

### App Features

1. **Generate Proof**: Input age and use case
2. **QR Code**: Display proof as QR code
3. **Verify**: Scan QR code to verify proof
4. **On-Chain**: Submit proof to smart contract


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **EthGlobal** for organizing Cannes 2025
- **MoPro** for mobile ZK proof generation
- **Arbitrum** for L2 infrastructure
- **Circom** for ZK circuit framework
- **iden3** for snarkjs tools

---

**Built with ❤️ for EthGlobal Cannes 2025**  
*Privacy-preserving identity verification for the decentralized future*
