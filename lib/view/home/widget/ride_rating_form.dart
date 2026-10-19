import '../../legal/ride_documents_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../services/ride_rating_service.dart';
import '../../../widgets/buttons/custom_button.dart';

class RideRatingForm extends StatefulWidget {
  const RideRatingForm(
      {super.key,
      required this.rideId,
      required this.participant,
      required this.service,
      required this.submit,
      required this.foreground,
      required this.background,
      this.photoUrl});
  final String rideId, participant;
  final String? photoUrl;
  final RideRatingService service;
  final Future<void> Function(int, String) submit;
  final Color foreground, background;
  @override
  State<RideRatingForm> createState() => _RideRatingFormState();
}

class _RideRatingFormState extends State<RideRatingForm>
    with WidgetsBindingObserver {
  final _comment = TextEditingController();
  int _stars = 0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restore();
  }

  @override
  void didChangeMetrics() {
    if (mounted) setState(() {});
  }

  Future<void> _restore() async {
    final saved = await widget.service.load(widget.rideId);
    if (!mounted || saved == null) return;
    _comment.text = saved.feedback;
    setState(() => _stars = saved.stars);
  }

  Future<void> _submit() async {
    if (_submitting || _stars == 0) return;
    setState(() => _submitting = true);
    try {
      await widget.submit(_stars, _comment.text);
      final saved = widget.service.record.value;
      if (mounted && saved != null && saved.rideId == widget.rideId) {
        _comment.text = saved.feedback;
        setState(() => _stars = saved.stars);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Observer(builder: (_) {
        final saved = widget.service.record.value;
        final busy = _submitting ||
            widget.service.saving.value ||
            widget.service.loading.value;
        final loadError = widget.service.loadError.value;
        final error = widget.service.error.value;
        final color = widget.foreground;
        // Scaffold removes keyboard insets from its body MediaQuery.
        final viewport = MediaQueryData.fromView(View.of(context));
        return ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: (viewport.size.height -
                            viewport.viewInsets.bottom -
                            viewport.padding.vertical -
                            kToolbarHeight)
                        .clamp(0.0, double.infinity) *
                    .9),
            child: ColoredBox(
                color: widget.background,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Ride completed',
                            style: TextStyle(
                                color: color,
                                fontSize: 20,
                                fontWeight: FontWeight.w600)),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: RideDocumentsButton(rideId: widget.rideId)),
                        const SizedBox(height: 16),
                        Row(children: [
                          ClipOval(
                              child: SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: widget.photoUrl?.isNotEmpty == true
                                      ? Image.network(widget.photoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, error, stack) =>
                                              Icon(Icons.person, color: color))
                                      : ColoredBox(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          child: const Icon(Icons.person,
                                              color: Colors.white)))),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(widget.participant,
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600))),
                        ]),
                        const SizedBox(height: 20),
                        Text(
                            saved != null ? 'Your saved rating' : 'Your rating',
                            style: TextStyle(color: color, fontSize: 14)),
                        const SizedBox(height: 8),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: KeyedSubtree(
                                key: ValueKey(saved?.id ?? 'draft'),
                                child: RatingBar.builder(
                                  initialRating:
                                      (saved?.stars ?? _stars).toDouble(),
                                  itemSize: 44,
                                  itemCount: 5,
                                  itemPadding:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  minRating: 1,
                                  allowHalfRating: false,
                                  glow: false,
                                  ignoreGestures: busy ||
                                      saved != null ||
                                      loadError != null,
                                  itemBuilder: (_, index) => const Icon(
                                      Icons.star,
                                      color: Color(0xffF4C700)),
                                  onRatingUpdate: (value) =>
                                      setState(() => _stars = value.toInt()),
                                ))),
                        const SizedBox(height: 16),
                        TextField(
                            controller: _comment,
                            minLines: 2,
                            maxLines: 4,
                            maxLength: 2000,
                            readOnly: saved != null,
                            enabled: !busy && loadError == null,
                            style: TextStyle(color: color),
                            decoration: InputDecoration(
                                labelText: 'Feedback (optional)',
                                labelStyle: TextStyle(
                                    color: color.withValues(alpha: .7)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)))),
                        if (loadError != null)
                          Row(children: [
                            Expanded(
                                child: Text(loadError,
                                    style: TextStyle(color: color))),
                            IconButton(
                                tooltip: 'Retry rating lookup',
                                onPressed: busy ? null : _restore,
                                color: color,
                                icon: const Icon(Icons.refresh)),
                          ]),
                        if (error != null)
                          Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child:
                                  Text(error, style: TextStyle(color: color))),
                        CustomButton(
                            text: saved == null ? 'Submit rating' : 'Done',
                            isLoading: busy,
                            onTap: busy || loadError != null || _stars == 0
                                ? null
                                : _submit),
                      ]),
                )));
      });
}
