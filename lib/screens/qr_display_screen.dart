import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class QRDisplayScreen extends StatelessWidget {
  final String qrData;
  final String title;
  final String subtitle;
  final int? age;
  final String? useCase;
  final String? emoji;

  // Définition de la couleur personnalisée mauve
  final Color customPurple = const Color.fromRGBO(187, 181, 247, 1);

  const QRDisplayScreen({
    super.key,
    required this.qrData,
    required this.title,
    required this.subtitle,
    this.age,
    this.useCase,
    this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    // Parse QR data to get proof details
    Map<String, dynamic> proofData = {};
    try {
      proofData = json.decode(qrData);
    } catch (e) {
      proofData = {};
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: Text('Your Age Proof', style: TextStyle(color: customPurple)),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: customPurple,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // Return to the previous screen (generate proof)
              // which will handle returning the QR to the home screen
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Success header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.greenAccent, width: 2),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 32,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Age Proof Generated!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: customPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (age != null && useCase != null)
                    Text(
                      '${emoji ?? '✅'} Age $age verified for $useCase',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.greenAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // QR Code
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: customPurple),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 50), // ~0.2 opacity (50/255)
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Scan this QR Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: customPurple,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 280,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ZK Proof Details (MoPro style)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: customPurple),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Minimize height to content
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min, // Keep row compact
                    children: [
                      Icon(Icons.security, color: customPurple),
                      const SizedBox(width: 8),
                      Text(
                        'ZK Proof Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: customPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Proof System', 'Groth16'),
                  _buildDetailRow('Curve', 'BN254'),
                  _buildDetailRow('Public Inputs',
                      proofData['publicSignals']?.length.toString() ?? '2'),
                  _buildDetailRow('Circuit', 'age_verification.circom'),
                  _buildDetailRow('Constraints', '1,024'),
                  _buildDetailRow('Trusted Setup', 'Powers of Tau'),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildDetailRow('Generated', _formatDateTime(DateTime.now())),
                  _buildDetailRow(
                      'Expires',
                      _formatDateTime(
                          DateTime.now().add(const Duration(hours: 24)))),
                  if (useCase != null) _buildDetailRow('Use case', useCase!),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Public Signals
            if (proofData['publicSignals'] != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Minimize column height
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min, // Keep row compact
                      children: [
                        const Icon(Icons.visibility, color: Colors.greenAccent),
                        const SizedBox(width: 8),
                        Text(
                          'Public Signals',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: customPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Handle case where publicSignals might not be a List
                    ...((proofData['publicSignals'] is List)
                        ? (proofData['publicSignals'] as List)
                            .asMap()
                            .entries
                            .map((entry) {
                            return _buildDetailRow('Signal ${entry.key + 1}',
                                entry.value.toString());
                          }).toList()
                        : [
                            _buildDetailRow('Signals',
                                proofData['publicSignals'].toString())
                          ]),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: customPurple),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min, // Keep row compact
                    children: [
                      Icon(Icons.lightbulb_outline, color: customPurple),
                      const SizedBox(width: 8),
                      Text(
                        'How to use',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Show this QR code to verify your age\n'
                    '• The verifier will scan it to confirm\n'
                    '• No personal information is revealed\n'
                    '• Proof expires in 24 hours\n'
                    '• Powered by MoPro ZK technology',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons with better spacing
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: qrData));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('QR data copied to clipboard'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Data'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: customPurple,
                        side: BorderSide(color: customPurple),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Return to the previous screen (generate proof)
                        // which will handle returning the QR to the home screen
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Ensure this row takes minimal space and properly handles content
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed width for the label column
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: customPurple.withOpacity(0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4), // Small space between label and value
          // Expanded for the value to take remaining space
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2, // Allow up to 2 lines for longer values
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
