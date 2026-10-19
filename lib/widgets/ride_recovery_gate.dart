import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../core/services/ride_recovery.dart';

class RideRecoveryGate extends StatelessWidget {
  const RideRecoveryGate(
      {super.key,
      required this.recovery,
      required this.child,
      required this.onLogout});
  final RideRecovery recovery;
  final Widget child;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => Observer(builder: (_) {
        final blocked = !recovery.ready.value || recovery.loading.value;
        final error = recovery.error.value;
        return Stack(children: [
          ExcludeSemantics(
              excluding: blocked,
              child: AbsorbPointer(absorbing: blocked, child: child)),
          if (blocked)
            Positioned.fill(
                child: Material(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                  child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                    width: 320,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      if (error == null) const LinearProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(error ?? 'Checking ride status...',
                          textAlign: TextAlign.center),
                      if (error != null) ...[
                        const SizedBox(height: 16),
                        FilledButton.icon(
                            onPressed: recovery.refresh,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry')),
                        TextButton(
                            onPressed: onLogout, child: const Text('Sign out')),
                      ],
                    ])),
              )),
            )),
        ]);
      });
}
