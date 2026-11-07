import 'package:flutter/material.dart';
import '../../models/banking_models.dart';

class ReceiptDialog extends StatelessWidget {
  final TransactionModel txn;
  final String? accountHolderName;

  const ReceiptDialog({
    super.key,
    required this.txn,
    this.accountHolderName,
  });

  static void show(BuildContext context, TransactionModel txn, [String? name]) {
    showDialog(
      context: context,
      builder: (_) => ReceiptDialog(txn: txn, accountHolderName: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.type == 'CREDIT';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(20),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text(
                'SFMS BHARAT FINANCE',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
              const Text(
                'Metro Central Branch • IFSC: SFMS0001001',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                color: Colors.black,
                child: const Text(
                  'CUSTOMER TRANSACTION SLIP',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.black, thickness: 1),

              // Details
              _row('TXN NO:', txn.txnNumber),
              _row('DATE/TIME:', txn.timestamp),
              _row('CHANNEL:', txn.channel),
              const Divider(color: Colors.black, thickness: 1),

              _row('ACCOUNT:', txn.accountNumber),
              if (accountHolderName != null) _row('NAME:', accountHolderName!),
              _row(
                'TXN TYPE:',
                '${txn.type} (${txn.category})',
                valueColor: isCredit ? Colors.green.shade800 : Colors.red.shade800,
              ),
              _row('REFERENCE:', txn.reference),
              _row('NARRATION:', txn.narration),

              const Divider(color: Colors.black, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL AMOUNT:',
                      style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      '₹${txn.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isCredit ? Colors.green.shade900 : Colors.red.shade900,
                      ),
                    ),
                  ],
                ),
              ),
              _row('AVAIL BALANCE:', '₹${txn.balanceAfter.toStringAsFixed(2)}'),
              const Divider(color: Colors.black, thickness: 1),

              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      SizedBox(width: 100, child: Divider(color: Colors.black)),
                      Text('CUSTOMER SIGN', style: TextStyle(fontFamily: 'Courier', fontSize: 8)),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(width: 100, child: Divider(color: Colors.black)),
                      Text('AUTHORIZED SIGN', style: TextStyle(fontFamily: 'Courier', fontSize: 8)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                '*** Thank You for Banking with SFMS ***\nToll Free Helpline: 1800-200-SFMS',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Courier', fontSize: 9, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Courier', fontSize: 11, color: Colors.grey)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
