import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RideContactButton extends StatelessWidget {
  const RideContactButton({super.key, required this.uri, this.launcher});
  final Uri? uri;
  final Future<bool> Function(Uri)? launcher;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton.filled(
        tooltip: uri == null ? 'Phone unavailable' : 'Call',
        onPressed: uri == null
            ? null
            : () async {
                var launched = false;
                try {
                  launched = await (launcher ?? launchUrl)(uri!);
                } catch (_) {
                  launched = false;
                }
                if (!launched && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unable to open phone app')),
                  );
                }
              },
        icon: const Icon(Icons.phone_outlined),
      ),
    );
  }
}
