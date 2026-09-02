import 'package:bot_toast/bot_toast.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';

/// Helper service for working with Toasts across Widgets & MobX Stores.
///
///
/// Displaying toast from a MobX Store.
///
/// ```dart
/// ...
/// @action
/// Future<void> someAsyncAction() async {
///   try {
///     final res = await ApiService.get();
///     ...
///   } catch (err) {
///     if (error is TimeoutException) {
///       ToastService.show('Request timed out');
///     }
///   }
/// }
/// ...
/// ```
abstract class ToastService {
  static void show(String text) {
    final ctx = NavigationService.navigatorKey.currentContext;
    BotToast.showText(
      text: text,
      enableKeyboardSafeArea: true,
      contentColor: ctx != null
          ? Theme.of(ctx).colorScheme.primary
          : const Color(0xFF6200EE),
      textStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
