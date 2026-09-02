import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/theme/size_config.dart';

class CustomAccordion extends HookWidget {
  const CustomAccordion({
    super.key,
    required this.title,
    required this.builder,
    this.leading,
    this.subtitle,
    this.onChanged,
    this.expandedCrossAxisAlignment,
  });

  final Widget title;
  final Widget? leading;
  final Widget? subtitle;
  final CrossAxisAlignment? expandedCrossAxisAlignment;
  final void Function(bool)? onChanged;
  final List<Widget> Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        expandedAlignment: Alignment.topLeft,
        childrenPadding: EdgeInsets.symmetric(
          horizontal: 4 * SizeConfig.safeBlockHorizontal,
          vertical: SizeConfig.safeBlockVertical,
        ),
        expandedCrossAxisAlignment:
            expandedCrossAxisAlignment ?? CrossAxisAlignment.start,
        leading: leading,
        title: title,
        subtitle: subtitle,
        onExpansionChanged: (expanded) {
          isExpanded.value = expanded;

          if (onChanged != null) {
            onChanged!(expanded);
          }
        },
        trailing: const SizedBox.shrink(),
        // trailing: Icon(
        //   isExpanded.value
        //       ? Icons.expand_less_rounded
        //       : Icons.expand_more_rounded,
        // ),
        children: builder(context),
      ),
    );
  }
}
