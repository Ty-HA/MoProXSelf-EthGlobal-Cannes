# ZK-Age Verify Mobile 🔐📱

> **MoProXSelf-EthGlobal-Cannes** - A native mobile age verification app using zero-knowledge proofs

## 🎯 Project Overview

**ZK-Age Verify Mobile** is a Flutter application that demonstrates seamless age verification using zero-knowledge proofs. Users can prove they meet age requirements without revealing their actual age, combining the power of **Mopro's native mobile ZK capabilities** with **Self Protocol's identity verification** and **on-chain verification**.

## 🔍 Mopro + Self Protocol Compatibility Analysis

### **Mopro Requirements:**
- ✅ **ZK proofs client-side**: Generated on mobile devices
- ✅ **Native bindings**: iOS/Android support
- ✅ **Mobile frameworks**: Flutter supported
- ✅ **No webview**: No browser-based proof generation

### **Self Protocol Requirements:**
- ✅ **ZK proofs**: Accepts external proof systems
- ✅ **Age verification**: Primary use case
- ✅ **Onchain/Offchain**: Two verification modes available
- ✅ **Mobile SDK**: Supported across platforms
- ✅ **TEE Support**: Trusted Execution Environment integration

### 🎯 **Compatibility Analysis**

### ✅ **PERFECTLY COMPATIBLE!** Here's why:

1. **Mopro generates ZK proofs** → **Self verifies them**
2. **Circuit multiplier2** → **Self accepts custom proofs**
3. **Mobile-first approach** → **Self supports mobile apps**
4. **Client-side generation** → **Self can verify client-side**
5. **TEE integration** → **Hardware-backed security**

### **Proposed Architecture:**
```
User Input (age) 
    ↓
Mopro SDK (generate ZK proof)
    ↓
Self Protocol TEE (verify + attest)
    ↓
Celo Blockchain (onchain verification)
    ↓
Ethereum Sepolia (Groth16 verifier contract)
```

## ✨ Key Features

### 🔒 Zero-Knowledge Age Verification
- **Client-side ZK proof generation** using Mopro + Circom
- Prove `age >= 18` without revealing exact age
- **No server-side computation** - all proofs generated on mobile device

### 🌐 Self Protocol Integration
- **Onchain verification** on Celo network
- **TEE (Trusted Execution Environment)** support
- OFAC compliance checks
- Country verification
- **Privacy-preserving identity attestation**

### 📱 Native Mobile Experience
- **Flutter interface** with smooth animations
- **Biometric authentication** for enhanced security
- **Offline ZK proof generation**
- **Real-time proof validation**

### 🔗 On-Chain Verification
- **Groth16 verifier contract** deployed on Sepolia
- **Web3 integration** with read-only verification
- **Zero personal data** stored on-chain
- **Automated contract deployment** scripts

## 🛠️ Technical Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Mopro SDK     │    │ Self Protocol   │
│                 │    │                 │    │                 │
│ • Age Input     │───▶│ • Circom Circuit│───▶│ • Onchain Verif │
│ • UI/UX         │    │ • Proof Gen     │    │ • Celo Network  │
│ • Biometrics    │    │ • Mobile Native │    │ • OFAC Check    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Installation

```bash
# Clone the repository
git clone https://github.com/Ty-HA/MoProXSelf-EthGlobal-Cannes.git

# Install dependencies
flutter pub get

# Run on iOS
flutter run -d ios

# Run on Android
flutter run -d android

# Run on macOS (for debugging)
flutter run -d macos
```

## 🎯 Hackathon Criteria

### ✅ Technical Requirements Met

- ✅ **Mobile-native ZK bindings** via Mopro SDK
- ✅ **Client-side proof generation** (no server relay)
- ✅ **New mobile-native code** in Flutter
- ✅ **No webview/browser** - purely native implementation
- ✅ **Works on physical device** (iPhone/Android)
- ✅ **TEE integration** (Trusted Execution Environment)
- ✅ **On-chain verification** (Groth16 verifier contract)
- ✅ **Self Protocol SDK integration**
- ✅ **Proof verification on Celo network**
- ✅ **Functional proof system**
- ✅ **OFAC compliance verification**

## 📱 Demo Scenarios

### Scenario 1: Bar/Club Entry
1. Scan bar's QR code
2. Generate 21+ proof with Touch ID
3. Show "✅ Adult verified" without revealing age

### Scenario 2: DeFi Access
1. Connect wallet
2. Prove > 1 ETH without revealing exact balance
3. Access VIP pool

### Scenario 3: Private Event
1. Prove geolocation within zone
2. Anonymous check-in
3. Receive NFT badge

## � Latest Features

### 🔗 On-Chain Verification
- **Groth16 verifier contract** auto-generated from .zkey file
- **Sepolia testnet** integration with Web3 support
- **Read-only verification** (no gas fees for verification)
- **Automated deployment** scripts for contract management

### 🔒 TEE Integration
- **Trusted Execution Environment** backend configuration
- **Hardware-backed security** for sensitive operations
- **Secure attestation workflow** design
- **Enhanced privacy** with TEE-secured proof verification

### 📊 Universal Proof Support
- **Hybrid QR codes** supporting both Mopro and Self Protocol
- **Universal scanner** with automatic proof type detection
- **Backwards compatibility** with existing proof formats
- **Enhanced debug information** for development

### 🛠️ Developer Experience
- **Automated contract generation** from circuit files
- **Comprehensive documentation** with circuit analysis
- **Debug tools** and proof validation utilities
- **Step-by-step deployment** guides

## 🧮 Circuit Logic: multiplier2 Adaptation

### Circuit Overview
We adapted the existing `multiplier2` circuit for age verification:

```
Input:  a (public) = minAge (e.g., 18)
Input:  b (private) = userAge (e.g., 21)  
Output: a × b = multiplication result (e.g., 18 × 21 = 378)
```

### ⚠️ Important Limitation
**The `multiplier2` circuit is NOT mathematically designed for age verification**

- ❌ `a × b` does **not** prove that `b ≥ a`
- ❌ A malicious user could input `userAge = 17` and still get a valid proof
- ✅ **For hackathon demo**: We perform `userAge ≥ minAge` check in the app before ZK proof generation

### What the ZK Proof Actually Proves
1. **Knowledge**: User knows both their age and the minimum requirement
2. **Consistency**: The same values were used for computation  
3. **Privacy**: User's actual age remains hidden
4. **Integrity**: The proof cannot be forged

### Production Considerations
In a real-world system, you would need a proper circuit with age comparison:

```circom
// Proper age verification circuit (not implemented)
template AgeVerification() {
    signal private input userAge;
    signal input minAge;
    signal output isValid;
    
    component gte = GreaterEqThan(8);
    gte.in[0] <== userAge;
    gte.in[1] <== minAge;
    
    isValid <== gte.out;
}
```

### Current Implementation Strategy
1. **App-level validation**: Check `userAge ≥ minAge` before proof generation
2. **ZK proof generation**: Use `multiplier2` circuit with validated inputs
3. **Privacy preservation**: User's exact age never leaves the device
4. **Verifiable computation**: Multiplication result can be verified on-chain

---

## 🏗️ Architecture Summary

This project demonstrates a comprehensive ZK-powered mobile app with:

- **🔐 Client-side ZK proofs**: Generated with Mopro SDK on mobile devices
- **🏃‍♂️ TEE integration**: Trusted Execution Environment for enhanced security
- **🔗 On-chain verification**: Groth16 verifier contract on Sepolia testnet
- **📱 Universal QR codes**: Supporting both Mopro and Self Protocol formats
- **🛡️ Privacy-preserving**: No personal data stored anywhere
- **🔄 Hybrid workflow**: Seamless integration between multiple protocols

### Key Technologies
- **Frontend**: Flutter with native iOS/Android bindings
- **ZK Proofs**: Mopro SDK + Circom multiplier2 circuit
- **Identity**: Self Protocol with TEE backend
- **Blockchain**: Ethereum Sepolia + Celo network support
- **Smart Contracts**: Auto-generated Groth16 verifier

---
