// pin_button.dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PinButton extends StatefulWidget {
  const PinButton({super.key});

  @override
  State<PinButton> createState() => _PinButtonState();
}

class _PinButtonState extends State<PinButton> {
  bool _isAlwaysOnTop = false;

  Future<void> _toggleAlwaysOnTop() async {
    if (kIsWeb) return;

    setState(() {
      _isAlwaysOnTop = !_isAlwaysOnTop;
    });
    await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
  }

  @override
  Widget build(BuildContext context) {
    return !kIsWeb
        ? Positioned(
            top: 0,
            right: 0, // Position at the top-right corner
            child: IconButton(
              iconSize: 16, // Half the size of the default icon
              icon: Icon(_isAlwaysOnTop ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: _toggleAlwaysOnTop,
            ),
          )
        : const SizedBox.shrink();
  }
}