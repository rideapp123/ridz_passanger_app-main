import '../exports/common_exports.dart';

abstract class AppTextStyles {
  AppTextStyles._();
  static final context = NavigationService.navigatorKey.currentContext!;
  static TextStyle appBar = TextStyle(
    fontSize: 16,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );

  static TextStyle title = TextStyle(
    fontSize: 24,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );

  static TextStyle subtitle = TextStyle(
    fontSize: 16,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );

  static TextStyle body = TextStyle(
    fontSize: 14,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle caption = TextStyle(
    fontSize: 12,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle button = TextStyle(
    fontSize: 16,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );

  static TextStyle input = TextStyle(
    fontSize: 16,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle error = TextStyle(
    fontSize: 12,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle hint = TextStyle(
    fontSize: 12,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle label = TextStyle(
    fontSize: 12,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle link = TextStyle(
    fontSize: 12,
    color: Theme.of(context).colorScheme.primary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );

  static TextStyle subtitle2 = TextStyle(
    fontSize: 14,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );

  static TextStyle style29white = TextStyle(
    color: Theme.of(context).colorScheme.tertiary,
    fontSize: 29,
    fontWeight: FontWeight.w600,
  );

  static TextStyle style15white = TextStyle(
    color: Theme.of(context).colorScheme.tertiary,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );
  static TextStyle style15w400 = TextStyle(
    fontSize: 15,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w400,
  );
  static TextStyle style15W700 = TextStyle(
    fontSize: 15,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w700,
  );
  static TextStyle style12w400 = TextStyle(
    fontSize: 12,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle style23W600 = TextStyle(
    fontSize: 22,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );
  static TextStyle style28W600 = TextStyle(
    fontSize: 28,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );
  static TextStyle style23W500 = TextStyle(
    fontSize: 23,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );

  static TextStyle style12W600 = TextStyle(
    fontSize: 12,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );
  static TextStyle style15W600 = TextStyle(
    fontSize: 15,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );
  static TextStyle style16W600 = TextStyle(
    fontSize: 15,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );
  static TextStyle style19W600 = TextStyle(
    fontSize: 19,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w600,
  );
  static TextStyle style18W500 = TextStyle(
    fontSize: 18,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle style12W500 = TextStyle(
    fontSize: 12,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle style64W700 = TextStyle(
    fontSize: 64,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w700,
  );

  static TextStyle style10W400 = TextStyle(
    fontSize: 10,
    color: Theme.of(context).colorScheme.tertiary,
    fontWeight: FontWeight.w400,
  );
}
