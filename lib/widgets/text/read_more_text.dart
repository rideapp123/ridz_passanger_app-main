import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ReadMoreText extends StatefulWidget {
  const ReadMoreText({
    super.key,
    required this.text,
    this.trimLength = 100,
    this.style,
    this.moreStyle,
    this.lessStyle,
  });

  final String text;
  final int trimLength;
  final TextStyle? style;
  final TextStyle? moreStyle;
  final TextStyle? lessStyle;

  @override
  State<ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<ReadMoreText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final trimLength = widget.trimLength;

    return Text.rich(
      TextSpan(
        style: widget.style,
        children: <TextSpan>[
          TextSpan(
            text: _isExpanded || text.length <= trimLength
                ? text
                : '${text.substring(0, trimLength)}...',
          ),
          if (text.length > trimLength)
            TextSpan(
              text: _isExpanded ? ' Read Less' : ' Read More',
              style: _isExpanded ? widget.lessStyle : widget.moreStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
            ),
        ],
      ),
    );
  }
}
