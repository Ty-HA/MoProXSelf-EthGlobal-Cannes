# ZK-Age Verify Mobile 🔐📱

> **MoProXSelf-EthGlobal-Cannes** - A native mobile age verification app using zero-knowledge proofs

## 🎯 Project Overview

**ZK-Age Verify Mobile** is a Flutter application that demonstrates seamless age verification using zero-knowledge proofs. Users can prove they meet age requirements without revealing their actual age, combining the power of **Mopro's native mobile ZK capabilities** with **Self Protocol's identity verification**.

### 🏆 Hackathon Goals
- **Mopro Prize**: $5,000 (Best use of ZK on Mopro)
- **Self Protocol Prize**: $10,000 (Best Self onchain SDK Integration)

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

### 🎯 **Compatibility Analysis**

### ✅ **PERFECTLY COMPATIBLE!** Here's why:

1. **Mopro generates ZK proofs** → **Self verifies them**
2. **Circuit multiplier2** → **Self accepts custom proofs**
3. **Mobile-first approach** → **Self supports mobile apps**
4. **Client-side generation** → **Self can verify client-side**

### **Proposed Architecture:**
```
User Input (age) 
    ↓
Mopro SDK (generate ZK proof)
    ↓
Self Protocol (verify + attest)
    ↓
Celo Blockchain (onchain verification)
```

## ✨ Key Features

### 🔒 Zero-Knowledge Age Verification
- **Client-side ZK proof generation** using Mopro + Circom
- Prove `age >= 18` without revealing exact age
- **No server-side computation** - all proofs generated on mobile device

### 🌐 Self Protocol Integration
- **Onchain verification** on Celo network
- OFAC compliance checks
- Country verification
- **Privacy-preserving identity attestation**

### 📱 Native Mobile Experience
- **Flutter interface** with smooth animations
- **Biometric authentication** for enhanced security
- **Offline ZK proof generation**
- **Real-time proof validation**

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

### ✅ Mopro Requirements Met
- ✅ **Mobile-native ZK bindings** via Mopro SDK
- ✅ **Client-side proof generation** (no server relay)
- ✅ **New mobile-native code** in Flutter
- ✅ **No webview/browser** - purely native implementation
- ✅ **Works on physical device** (iPhone/Android)

### ✅ Self Protocol Requirements Met
- ✅ **Self onchain SDK integration**
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

## 🏆 Prize Strategy

With this implementation, we can target **2 major prizes simultaneously**:

### **1. Mopro Prize ($5,000)** ✅
- **Client-side ZK proofs**: Generated with Mopro SDK
- **Native mobile**: Flutter + Mopro bindings
- **ZK circuits**: multiplier2 circuit

### **2. Self Protocol Prize ($9,000)** ✅
- **Onchain verification**: Celo blockchain
- **Age attestation**: Primary use case
- **ZK integration**: Mopro proofs → Self Protocol

**Total potential: $14,000** 🎯

---

**Team**: 1 developer  
**Duration**: 48h hackathon  
**Goal**: 🥇 Best use of ZK on Mopro + Self Protocol Integration
