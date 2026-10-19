import 'package:flutter/material.dart';
import 'package:ridzs_passenger_app/services/service_area_service.dart';
import '../../../services/regional_disclosure_service.dart';
import '../../legal/regional_information_screen.dart';

class ServiceAreaNotice extends StatefulWidget {
  final double latitude, longitude;
  final ServiceAreaService? service;
  final RegionalDisclosureService Function()? documentServiceFactory;
  const ServiceAreaNotice(
      {super.key,
      required this.latitude,
      required this.longitude,
      this.service,
      this.documentServiceFactory});
  @override
  State<ServiceAreaNotice> createState() => _ServiceAreaNoticeState();
}

class _ServiceAreaNoticeState extends State<ServiceAreaNotice> {
  ServiceArea? area;
  bool loading = true;
  String? error;
  int revision = 0;
  final _contextRevision = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ServiceAreaNotice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _load();
    }
  }

  Future<void> _load() async {
    final request = ++revision;
    _contextRevision.value = request;
    setState(() {
      loading = true;
      error = null;
      area = null;
    });
    try {
      final result = await (widget.service ?? ServiceAreaService())
          .check(widget.latitude, widget.longitude);
      if (mounted && request == revision) setState(() => area = result);
    } catch (_) {
      if (mounted && request == revision) {
        setState(() => error = 'Unable to check this pickup area.');
      }
    } finally {
      if (mounted && request == revision) setState(() => loading = false);
    }
  }

  void _open(RegionalSection section) {
    final marketId = area?.marketId;
    if (area?.available != true || marketId == null) return;
    final request = revision;
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => RegionalInformationScreen(
            initialSection: section,
            pickupMarketId: marketId,
            contextChanges: _contextRevision,
            contextIsCurrent: () =>
                mounted && revision == request && area?.marketId == marketId,
            serviceFactory: widget.documentServiceFactory)));
  }

  @override
  void dispose() {
    _contextRevision.value = ++revision;
    _contextRevision.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (loading) const LinearProgressIndicator(),
          Row(children: [
            Icon(
                area?.available == true
                    ? Icons.location_on_outlined
                    : Icons.info_outline,
                size: 20),
            const SizedBox(width: 8),
            Expanded(
                child: Text(loading
                    ? 'Checking pickup area'
                    : error ??
                        (area?.available == true
                            ? area!.name
                            : area?.reason ?? 'Pickup unavailable'))),
            if (error != null)
              IconButton(
                  tooltip: 'Retry service-area check',
                  onPressed: _load,
                  icon: const Icon(Icons.refresh))
          ]),
          if (area?.available == true && area?.marketId != null)
            Wrap(spacing: 8, children: [
              TextButton.icon(
                  icon: const Icon(Icons.article_outlined),
                  onPressed: () => _open(RegionalSection.terms),
                  label: const Text('Ride terms')),
              TextButton.icon(
                  icon: const Icon(Icons.privacy_tip_outlined),
                  onPressed: () => _open(RegionalSection.privacy),
                  label: const Text('Privacy')),
            ]),
        ]),
      );
}
