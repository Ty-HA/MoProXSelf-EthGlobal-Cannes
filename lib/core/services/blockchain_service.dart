import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import '../constants/blockchain_constants.dart';

/// Service for interacting with the Groth16Verifier contract on Arbitrum Sepolia
///
/// This service provides methods to verify ZK proofs on-chain using the
/// deployed Groth16Verifier contract.
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
        print('🔍 Verifying ZK proof on Arbitrum Sepolia...');
        print('📍 Contract: ${BlockchainConstants.groth16VerifierAddress}');
      }

      // Convert string inputs to BigInt
      final pA = proofA.map((e) => BigInt.parse(e)).toList();
      final pB = proofB
          .map((row) => row.map((e) => BigInt.parse(e)).toList())
          .toList();
      final pC = proofC.map((e) => BigInt.parse(e)).toList();
      final pubSignals = publicSignals.map((e) => BigInt.parse(e)).toList();

      // Call the contract
      final result = await _client.call(
        contract: _contract,
        function: _verifyProofFunction,
        params: [pA, pB, pC, pubSignals],
      );

      final isValid = result.first as bool;

      if (BlockchainConstants.enableLogging) {
        print('✅ Proof verification result: $isValid');
      }

      return isValid;
    } catch (e) {
      if (BlockchainConstants.enableLogging) {
        print('❌ Error verifying proof: $e');
      }
      rethrow;
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
