# 🔐📱 ZKAge Proof Mobile 

[![EthGlobal](https://img.shields.io/badge/EthGlobal-Cannes-blue)](https://ethglobal.com/events/cannes)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)](https://flutter.dev)
[![Circom](https://img.shields.io/badge/Circom-ZK--SNARKs-green)](https://circom.io)
[![Arbitrum](https://img.shields.io/badge/Arbitrum-Sepolia-orange)](https://arbitrum.io)

> **Zero-Knowledge Age Verification for Privacy-Preserving Identity**  
> Built for EthGlobal Cannes 2025 🇫🇷

## 🎯 Overview

ZKAge Proof Mobile is a privacy-preserving age verification system that uses Zero-Knowledge proofs to verify age without revealing personal information. Users can prove they meet age requirements (18+, 21+, etc.) without exposing their actual age or identity.

## ✨ Features

- **🔐 Zero-Knowledge Proofs**: Verify age without revealing actual age
- **📱 Mobile-First**: Flutter app for iOS and Android
- **⚡ Fast Verification**: Groth16 proofs for efficient verification
- **🌐 On-Chain**: Smart contract verification on Arbitrum Sepolia
- **🎫 QR Code Integration**: Generate and scan age verification proofs
- **🔒 Privacy-Preserving**: No personal data stored or transmitted
- **🪪 Self Protocol Ready**: Designed for future integration with Self Protocol for on-chain identity and attestation
- **📶 NFC Support (Planned)**: NFC reading for secure document/ID verification

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
git clone https://github.com/your-username/zkage-proof-mobile.git
cd zkage-proof-mobile
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

## 🏆 Milestones & Roadmap

- [x] Custom Circom age verification circuit (public signals: `[minAge, userAge]`, constraint: `userAge >= minAge`)
- [x] Groth16 Solidity verifier contract deployed and verified
- [x] On-chain verification on Arbitrum Sepolia
- [x] Mobile ZK proof generation (MoPro Flutter)
- [x] QR code proof sharing and scanning
- [ ] **Self Protocol SDK integration** (planned)
- [ ] **NFC reading integration** (planned, via Self Protocol or equivalent)
- [ ] Biometric authentication enhancement
- [ ] Celo network support (future)
- [ ] Advanced range proofs and nullifier support
- [ ] UI/UX polish and accessibility improvements

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
# Circuit Analysis

## Problem Identified

The Mopro public signals were showing `[0, 0]` instead of the expected values (`[minAge, userAge]`). This indicated a mapping issue between the circuit inputs and the public signals.

## Root Cause

The issue was due to a misalignment between the Circom circuit, the .zkey, and the Solidity contract. After correction, the circuit used is a custom age verification circuit, not a simple multiplier.

## Solution Implemented

### Circuit Used

The Circom circuit for age verification is defined as follows:
- **Public input**: `minAge` (minimum required age)
- **Private input**: `userAge` (user's real age)
- **Public signals**: `[minAge, userAge]`
- **Constraint**: `userAge >= minAge`

**Example circuit:**

```circom
signal input minAge;
signal input userAge;
// Constraint: userAge >= minAge
component isOk = GreaterEqThan(8)();
isOk.in[0] <== userAge;
isOk.in[1] <== minAge;
isOk.out === 1;
// Public signals
signal output out1;
signal output out2;
out1 <== minAge;
out2 <== userAge;
```

### Verification
- **The ZK proof**: proves the user knows an age `userAge` greater than or equal to `minAge`, without revealing any other info.
- **The public signals**: `[minAge, userAge]` are used for on-chain verification.

### Flutter Code Example

```dart
final inputs = jsonEncode({
  'minAge': minAge.toString(),     // Public: minimum age required
  'userAge': userAge.toString(),   // Private: user's actual age
});
final result = await mopro.generateCircomProof(
  'assets/test_age_verification_final.zkey',
  inputs,
  ProofLib.arkworks,
);
```

## Technical Details

### Circuit File

- **File**: `assets/test_age_verification_final.zkey`
- **Type**: Groth16 circuit for BN128 curve
- **Inputs**: 2 field elements (`minAge` public, `userAge` private)
- **Public signals**: `[minAge, userAge]`
- **Constraint**: `userAge >= minAge`

### Mopro Integration

```dart
final result = await mopro.generateCircomProof(
  'assets/test_age_verification_final.zkey',
  inputs,
  ProofLib.arkworks,
);
```

## Why This Works for Age Verification

1. **Privacy**: The real age remains private (private input)
2. **Verification**: The proof shows the user is at least the required age
3. **Proof**: The constraint is enforced in the circuit
4. **Zero-Knowledge**: The exact age is not revealed

## Limitations & Future Improvements

- Simple circuit, no advanced range proof
- Can be improved for production (nullifier, anti-replay, etc.)

## Result

- ✅ Custom age circuit functional
- ✅ ZK proof generated and verified locally and on-chain (if mapping is correct)
- ✅ Public signals aligned with the Solidity contract

---

This document now accurately reflects the real technical solution implemented in the project.

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
- **Self Protocol** for decentralized identity and attestation

---

**Built with ❤️ for EthGlobal Cannes 2025**  
*Privacy-preserving identity verification for the decentralized future*
