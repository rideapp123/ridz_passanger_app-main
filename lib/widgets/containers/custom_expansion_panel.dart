import 'package:flutter/material.dart';

import '../../../core/theme/styles.dart';
import 'svg_icon.dart';

class CustomExpansionPanel extends StatefulWidget {
  const CustomExpansionPanel({
    super.key,
    this.bodyHeight = 81,
    required this.expandOnChanged,
    required this.title,
    required this.bodyText,
    required this.leadingIcon,
    this.minimumVisits,
  });
  final String title;
  final List<String> bodyText;
  final double bodyHeight;
  final List<String> leadingIcon;
  final VoidCallback expandOnChanged;
  final int? minimumVisits;

  @override
  State<CustomExpansionPanel> createState() => _CustomExpansionPanelState();
}

class _CustomExpansionPanelState extends State<CustomExpansionPanel> {
  bool isExpanded = false;
  double height = 80;

  List<Widget> getBody() {
    List<Widget> tmp = [];
    for (int i = 0; i < widget.bodyText.length; i++) {
      tmp.add(Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Styles.COLOR_PRIMARY_ORANGE, width: 0.5),
        ),
        child: Row(
          children: [
            SvgIcon(icon: widget.leadingIcon[i]),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Text(
                widget.bodyText[i],
                // widget.minimumVisits == null || widget.minimumVisits == 0
                //     ? widget.bodyText[i]
                //     : '${widget.bodyText[i]} onwards ${widget.minimumVisits} ${widget.minimumVisits == 1 ? 'visit' : 'visits'}',
                overflow: TextOverflow.clip,
                maxLines: 2,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ));
    }
    return tmp;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // this is the header with GestureDetector enabling maximum design flexibility
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
              height = isExpanded ? widget.bodyHeight : 0;
              widget.expandOnChanged();
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.black12,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      child: Column(
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Styles.COLOR_PRIMARY_ORANGE,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (widget.minimumVisits != null &&
                              widget.minimumVisits != 0)
                            Text(
                              '${widget.minimumVisits} visits onwards',
                              style: const TextStyle(
                                color: Styles.COLOR_PRIMARY_ORANGE,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.black12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // this is the body which expands and collapses by height change
        AnimatedContainer(
          height: height * (widget.bodyText.length),
          width: double.infinity,
          curve: Curves.fastOutSlowIn,
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: getBody(),
            ),
          ),
        ),
      ],
    );
  }
}
