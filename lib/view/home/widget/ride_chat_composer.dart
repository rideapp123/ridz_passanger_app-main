import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../services/ride_chat_service.dart';

class RideChatComposer extends StatefulWidget {
  const RideChatComposer(
      {super.key,
      required this.rideId,
      required this.chat,
      required this.send,
      required this.typing,
      this.enabled = true,
      required this.foreground});
  final bool enabled;
  final String rideId;
  final RideChatService chat;
  final Future<bool> Function(String) send;
  final void Function(bool) typing;
  final Color foreground;

  @override
  State<RideChatComposer> createState() => _RideChatComposerState();
}

class _RideChatComposerState extends State<RideChatComposer> {
  final _controller = TextEditingController();
  Timer? _typingStop;
  bool _restoring = true;
  bool _draftFailed = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore({bool replace = false}) async {
    try {
      final draft = await widget.chat.pendingDraft(widget.rideId);
      if (mounted && (_controller.text.isEmpty || replace) && draft != null) {
        _controller.text = draft;
      }
      if (mounted) setState(() => _draftFailed = false);
    } catch (_) {
      if (mounted) setState(() => _draftFailed = true);
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  void dispose() {
    _typingStop?.cancel();
    widget.typing(false);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (!widget.enabled ||
        text.trim().isEmpty ||
        widget.chat.sending.value ||
        widget.chat.retryAfterSeconds.value > 0) {
      return;
    }
    final confirmed = await widget.send(text);
    if (mounted && confirmed && _controller.text == text) {
      _controller.clear();
      _typingStop?.cancel();
      widget.typing(false);
    }
  }

  @override
  Widget build(BuildContext context) => Observer(builder: (_) {
        final busy = widget.chat.sending.value;
        final retrySeconds = widget.chat.retryAfterSeconds.value;
        final error = retrySeconds > 0
            ? 'Try again in ${retrySeconds}s. Your draft is saved.'
            : widget.chat.sendError.value;
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (_draftFailed)
              Row(children: [
                Expanded(
                    child: Text('Draft could not be restored.',
                        style: TextStyle(color: widget.foreground))),
                IconButton(
                    tooltip: 'Retry draft recovery',
                    onPressed: _restore,
                    icon: const Icon(Icons.refresh)),
              ]),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Expanded(
                      child: Text(error,
                          style: TextStyle(color: widget.foreground))),
                  IconButton(
                      tooltip: 'Restore unconfirmed draft',
                      onPressed: busy ? null : () => _restore(replace: true),
                      color: widget.foreground,
                      icon: const Icon(Icons.restore)),
                ]),
              ),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: TextField(
                controller: _controller,
                enabled:
                    widget.enabled && !busy && !_restoring && !_draftFailed,
                minLines: 1,
                maxLines: 3,
                maxLength: 2000,
                style: TextStyle(color: widget.foreground),
                onChanged: (text) {
                  widget.typing(text.isNotEmpty);
                  _typingStop?.cancel();
                  _typingStop = Timer(
                      const Duration(seconds: 2), () => widget.typing(false));
                },
                decoration: InputDecoration(
                  hintText: widget.enabled ? 'Message' : 'Chat closed',
                  counterText: '',
                  hintStyle: TextStyle(
                      color: widget.foreground.withValues(alpha: .65)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              )),
              const SizedBox(width: 8),
              SizedBox(
                  width: 48,
                  height: 48,
                  child: busy || _restoring
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          tooltip: 'Send message',
                          onPressed: _draftFailed ||
                                  !widget.enabled ||
                                  retrySeconds > 0
                              ? null
                              : _send,
                          color: widget.foreground,
                          icon: const Icon(Icons.send))),
            ]),
          ]),
        );
      });
}

class RideChatHistoryStatus extends StatelessWidget {
  const RideChatHistoryStatus(
      {super.key,
      required this.chat,
      required this.loading,
      required this.reload,
      required this.older,
      required this.foreground});
  final RideChatService chat;
  final bool loading;
  final VoidCallback reload;
  final VoidCallback older;
  final Color foreground;
  @override
  Widget build(BuildContext context) => Observer(builder: (_) {
        final error = chat.historyError.value;
        final cursor = chat.nextCursor.value;
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              Expanded(
                  child: Text(error ?? 'Messages',
                      style: TextStyle(color: foreground))),
              IconButton(
                  tooltip: 'Refresh chat',
                  onPressed: loading ? null : reload,
                  color: foreground,
                  icon: const Icon(Icons.refresh)),
              if (cursor != null)
                IconButton(
                    tooltip: error != null
                        ? 'Retry earlier messages'
                        : 'Load earlier messages',
                    onPressed: loading ? null : older,
                    color: foreground,
                    icon: Icon(
                        error != null ? Icons.refresh : Icons.expand_less)),
            ]));
      });
}
