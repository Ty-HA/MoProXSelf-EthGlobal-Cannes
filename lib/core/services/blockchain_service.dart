import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../constants/blockchain_constants.dart';

/// Service for interacting with the AgeVerifier contract on Arbitrum Sepolia
///
/// This service provides methods to verify ZK proofs on-chain using the
/// deployed AgeVerifier contract.
class BlockchainService {
  late Web3Client _client;
  late DeployedContract _contract;
  late ContractFunction _verifyProofFunction;

  /// Initialize the blockchain service
  Future<void> initialize() async {
    // Initialize Web3 client
    _client = Web3Client(
      BlockchainConstants.rpcUrl,
      http.Client(),
    );

    // Load contract ABI and create contract instance
    _contract = DeployedContract(
      ContractAbi.fromJson(
        jsonEncode(BlockchainConstants.contractAbi),
        BlockchainConstants.contractName,
      ),
      EthereumAddress.fromHex(BlockchainConstants.groth16VerifierAddress),
    );

    // Get the verifyProof function
    _verifyProofFunction = _contract.function('verifyProof');
  }

  /// Verify a ZK proof on-chain
  ///
  /// [proofA] - Point A of the proof
  /// [proofB] - Point B of the proof (2x2 array)
  /// [proofC] - Point C of the proof
  /// [publicSignals] - Public signals (age verification result)
  ///
  /// Returns true if the proof is valid, false otherwise
  Future<bool> verifyProof({
    required List<String> proofA,
    required List<List<String>> proofB,
    required List<String> proofC,
    required List<String> publicSignals,
  }) async {
    try {
      if (BlockchainConstants.enableLogging) {
        print('🔍 Verifying ZK proof on ${BlockchainConstants.networkName}...');
        print('📍 Contract: ${BlockchainConstants.groth16VerifierAddress}');
        print('📊 Public signals: $publicSignals');
        print('🔑 Proof points:');
        print('   - A: $proofA');
        print('   - B: $proofB');
        print('   - C: $proofC');
      }

      // Validate inputs first
      if (proofA.length != 2) {
        print(
            '❌ Error: proofA must have exactly 2 elements, got ${proofA.length}');
        return false;
      }
      if (proofB.length != 2 ||
          proofB[0].length != 2 ||
          proofB[1].length != 2) {
        print('❌ Error: proofB must be a 2x2 array');
        return false;
      }
      if (proofC.length != 2) {
        print(
            '❌ Error: proofC must have exactly 2 elements, got ${proofC.length}');
        return false;
      }
      if (publicSignals.length != 2) {
        print(
            '❌ Error: publicSignals must have exactly 2 elements (minAge, userAge), got ${publicSignals.length}');
        return false;
      }

      // Convert string inputs to BigInt
      try {
        final pA = proofA.map((e) => BigInt.parse(e)).toList();
        final pB = proofB
            .map((row) => row.map((e) => BigInt.parse(e)).toList())
            .toList();
        final pC = proofC.map((e) => BigInt.parse(e)).toList();
        final pubSignals = publicSignals.map((e) => BigInt.parse(e)).toList();

        if (BlockchainConstants.enableLogging) {
          print('✅ Parsed all proof elements to BigInt successfully');
        }

        // Call the contract
        print('🔄 Calling contract verify function...');
        final result = await _client.call(
          contract: _contract,
          function: _verifyProofFunction,
          params: [pA, pB, pC, pubSignals],
        );

        final isValid = result.first as bool;

        if (BlockchainConstants.enableLogging) {
          if (isValid) {
            print('✅ PROOF VERIFICATION SUCCESSFUL');
            print('✓ The proof was accepted by the contract');
            print('✓ The age verification is valid on-chain');
          } else {
            print('❌ PROOF VERIFICATION FAILED');
            print('✗ The contract rejected the proof');
            print('✗ This may be because:');
            print('  - The proof is invalid');
            print(
                '  - The public signals don\'t match the circuit constraints');
            print(
                '  - The circuit used to generate the proof doesn\'t match the verifier contract');
          }
        }
        return isValid;
      } catch (e) {
        if (BlockchainConstants.enableLogging) {
          print('❌ ERROR DURING VERIFICATION: $e');
          print('⚠️ This may indicate:');
          print(
              '  - The contract address is incorrect or the contract is not deployed');
          print('  - The network connection failed');
          print(
              '  - The proof format doesn\'t match what the contract expects');
          print(
              '  - One of the proof components is too large or in an invalid format');
          String errorMsg = e.toString().toLowerCase();
          if (errorMsg.contains('revert')) {
            print(
                '📌 Contract reverted the transaction: this usually means the proof is invalid');
          } else if (errorMsg.contains('gas') ||
              errorMsg.contains('exceeded')) {
            print(
                '📌 Gas estimation or limit issue: the proof might be too complex');
          } else if (errorMsg.contains('format') || errorMsg.contains('type')) {
            print(
                '📌 Format error: the proof structure doesn\'t match the contract expectations');
          } else if (errorMsg.contains('network') ||
              errorMsg.contains('connect')) {
            print(
                '📌 Network issue: check your internet connection or RPC endpoint');
          }
        }
        // Return false instead of rethrowing to avoid crashing the app
        return false;
      }
    } catch (e) {
      // Outer catch for input validation
      if (BlockchainConstants.enableLogging) {
        print('❌ ERROR DURING INPUT VALIDATION: $e');
      }
      return false;
    }
  }

  /// Checks if the contract is valid by attempting to call the verifyProof function
  /// with mock parameters to make sure it exists (we don't actually need it to return true)
  Future<bool> isContractValid() async {
    try {
      // Create mock parameters that should at least not cause a contract method not found error
      final mockProofA = [BigInt.from(1), BigInt.from(2)];
      final mockProofB = [
        [BigInt.from(3), BigInt.from(4)],
        [BigInt.from(5), BigInt.from(6)]
      ];
      final mockProofC = [BigInt.from(7), BigInt.from(8)];
      final mockPublicSignals = [BigInt.from(9), BigInt.from(10)];

      // Try to call the function (we don't care if it returns false, just that it exists)
      await _client.call(
        contract: _contract,
        function: _verifyProofFunction,
        params: [mockProofA, mockProofB, mockProofC, mockPublicSignals],
      );

      // If we got this far, the function exists
      return true;
    } catch (e) {
      if (BlockchainConstants.enableLogging) {
        print('❌ Error checking contract validity: $e');
      }

      // Check if it's just a regular revert (expected) vs a method not found error
      final errorString = e.toString().toLowerCase();
      if (errorString.contains("revert") ||
          errorString.contains("invalid proof")) {
        // If it's a revert or invalid proof error, the method exists but our mock data is invalid
        return true;
      }

      return false;
    }
  }

  /// Get the contract address
  String get contractAddress => BlockchainConstants.groth16VerifierAddress;

  /// Get the network name
  String get networkName => BlockchainConstants.networkName;

  /// Get the chain ID
  int get chainId => BlockchainConstants.chainId;

  /// Check if the contract is verified
  bool get isContractVerified => BlockchainConstants.isVerified;

  /// Get the Arbiscan URL for the contract
  String get contractExplorerUrl => BlockchainConstants.contractUrl;

  /// Get transaction URL for a given hash
  String getTransactionUrl(String txHash) {
    return BlockchainConstants.transactionUrl(txHash);
  }

  /// Get estimated gas for proof verification
  int get estimatedGas => BlockchainConstants.estimatedGasForVerification;

  /// Dispose resources
  void dispose() {
    _client.dispose();
  }

  /// Get network configuration for wallet connection
  Map<String, dynamic> get networkConfig => BlockchainConstants.networkConfig;
}

/// Extension for easier proof formatting
extension ProofFormatter on Map<String, dynamic> {
  /// Convert Mopro proof format to contract format
  List<String> get formattedProofA {
    final proof = this['proof'] as Map<String, dynamic>;
    final a = proof['a'] as List<dynamic>;
    return [a[0].toString(), a[1].toString()];
  }

  List<List<String>> get formattedProofB {
    final proof = this['proof'] as Map<String, dynamic>;
    final b = proof['b'] as List<dynamic>;
    return [
      [b[0][0].toString(), b[0][1].toString()],
      [b[1][0].toString(), b[1][1].toString()],
    ];
  }

  List<String> get formattedProofC {
    final proof = this['proof'] as Map<String, dynamic>;
    final c = proof['c'] as List<dynamic>;
    return [c[0].toString(), c[1].toString()];
  }

  List<String> get formattedPublicSignals {
    final signals = this['publicSignals'] as List<dynamic>;
    return signals.map((e) => e.toString()).toList();
  }
}
