import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  /// Set to true the moment we commit to popping — prevents any further
  /// onDetect events from triggering a second pop on an already-popped route.
  bool _hasPopped = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Scan Barcode'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) async {
              // Drop all events after the first accepted scan.
              if (_hasPopped) return;

              try {
                final barcode = capture.barcodes.firstOrNull;
                final raw = barcode?.rawValue;

                debugPrint(
                    '[BarcodeScanner] detected raw=$raw  type=${raw?.runtimeType}');

                if (raw == null || raw.trim().isEmpty) {
                  debugPrint('[BarcodeScanner] raw is null/empty — ignoring');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not read barcode. Try again.'),
                      ),
                    );
                  }
                  return;
                }

                // Commit: no more scan events will be processed.
                _hasPopped = true;
                final result = raw.trim();
                debugPrint('[BarcodeScanner] popping with barcode=$result');

                if (mounted) {
                  Navigator.of(context).pop(result);
                }
              } catch (e, st) {
                debugPrint('[BarcodeScanner ERROR] $e');
                debugPrint('[BarcodeScanner STACK] $st');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Scanner error: $e')),
                  );
                }
              }
            },
          ),

          // Scan window overlay
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Point camera at a barcode',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
