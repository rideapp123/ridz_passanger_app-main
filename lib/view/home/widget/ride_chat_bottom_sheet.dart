import 'ride_contact_button.dart';
import '../../safety/ride_safety_screen.dart';
import 'ride_chat_composer.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';

class RideChatBottomSheet extends HookWidget {
  final RideRequest rideRequest;
  const RideChatBottomSheet({
    super.key,
    required this.rideRequest,
  });

  @override
  Widget build(BuildContext context) {
    final mapStore = mapStoreProvider();
    final rideId = rideRequest.ride!.sId!;
    final route = ModalRoute.of(context);

    useEffect(() {
      mapStore.loadChatMessage(
        rideId: rideRequest.ride!.sId!,
      );
      mapStore.joinChatRoom(rideId: rideRequest.ride!.sId!);
      return () {
        mapStore.leaveChatRoom(rideId: rideRequest.ride!.sId!);
      };
    }, [mapStore, rideId]);

    useEffect(() {
      void update(AppLifecycleState? state) {
        if (state == null || state == AppLifecycleState.resumed) {
          mapStore.startChatRecovery(rideId,
              canRead: () => route?.isCurrent ?? true);
        } else {
          mapStore.chat.stopRecovery();
        }
      }

      final listener = AppLifecycleListener(onStateChange: update);
      update(WidgetsBinding.instance.lifecycleState);
      return () {
        listener.dispose();
        mapStore.chat.stopRecovery();
      };
    }, [mapStore, rideId, route]);

    return Padding(
      padding: const EdgeInsets.only(
        top: 60,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            //
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.screenWidth * 0.04,
                vertical: SizeConfig.screenHeight * 0.02,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Row(
                children: [
                  //
                  Expanded(
                    child: Row(
                      children: [
                        //
                        GestureDetector(
                          onTap: () {
                            NavigationService().pop();
                          },
                          child: CustomImageView(
                            svgPath: Assets.backArrow,
                            height: 24,
                            width: 24,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),

                        SizedBox(width: SizeConfig.screenWidth * 0.04),

                        if (rideRequest.driverPhoto != null &&
                            rideRequest.driverPhoto!.isNotEmpty)
                          Container(
                            height: SizeConfig.screenHeight * 0.055,
                            width: SizeConfig.screenHeight * 0.055,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: ClipOval(
                              child: CustomImageView(
                                url: rideRequest.driverPhoto,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        else
                          Container(
                            height: SizeConfig.screenHeight * 0.055,
                            width: SizeConfig.screenHeight * 0.055,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),

                        SizedBox(width: SizeConfig.screenWidth * 0.02),

                        Expanded(
                            child: Text(
                          rideRequest.participantLabel,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.style15w400.copyWith(
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.w600,
                          ),
                        )),
                      ],
                    ),
                  ),

                  RideContactButton(uri: rideRequest.contactUri),
                  IconButton(
                      tooltip: 'Ride safety',
                      icon: const Icon(Icons.health_and_safety_outlined),
                      color: Theme.of(context).colorScheme.error,
                      onPressed: () => openRideSafety(
                          context,
                          rideRequest.ride!.sId!,
                          mapStore.createSafetySession())),
                ],
              ),
            ),

            Observer(
                builder: (_) => RideChatHistoryStatus(
                      chat: mapStore.chat,
                      loading: mapStore.isLoadingChatMessage,
                      foreground: Theme.of(context).colorScheme.surface,
                      reload: () => mapStore.loadChatMessage(
                          rideId: rideRequest.ride!.sId!),
                      older: () => mapStore.loadChatMessage(
                          rideId: rideRequest.ride!.sId!, older: true),
                    )),
            //
            Observer(builder: (context) {
              if (mapStore.isLoadingChatMessage &&
                  mapStore.chatMessages.isEmpty) {
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              }

              return Expanded(
                child: ListView.separated(
                  itemCount: mapStore.chatMessages.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.screenWidth * 0.04,
                    vertical: SizeConfig.screenHeight * 0.02,
                  ),
                  separatorBuilder: (_, index) {
                    return SizedBox(height: SizeConfig.screenHeight * 0.02);
                  },
                  itemBuilder: (_, index) {
                    final message = mapStore.chatMessages[index];
                    final date = DateTime.parse(message.timestamp).toLocal();
                    final formattedDate = DateFormat('hh:mm a').format(date);
                    return Row(
                      children: [
                        //
                        if (message.sender == 'passenger') const Spacer(),

                        Flexible(
                          flex: 4,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.screenWidth * 0.04,
                              vertical: SizeConfig.screenHeight * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryFixedDim
                                  .withValues(alpha: .1),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                bottomRight: message.sender == 'passenger'
                                    ? Radius.zero
                                    : const Radius.circular(16),
                                bottomLeft: message.sender == 'passenger'
                                    ? const Radius.circular(16)
                                    : Radius.zero,
                                topRight: const Radius.circular(16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: message.sender == 'passenger'
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                //
                                Text(
                                  message.message,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                ),

                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryFixedDim,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (message.sender != 'passenger') const Spacer(),
                      ],
                    );
                  },
                ),
              );
            }),

            Observer(builder: (context) {
              if (!mapStore.isTyping) {
                return const SizedBox.shrink();
              }

              return Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.screenWidth * 0.04,
                      vertical: SizeConfig.screenHeight * 0.02,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: SizeConfig.screenWidth * 0.04,
                      vertical: SizeConfig.screenHeight * 0.02,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .tertiaryFixedDim
                          .withValues(alpha: .1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                        bottomLeft: Radius.zero,
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const TypingAnimationWidget(),
                  ),
                  const Spacer(),
                ],
              );
            }),

            //
            Observer(
                builder: (_) => RideChatComposer(
                      enabled: const {'accepted', 'arrived', 'started'}
                          .contains(mapStore.currentRide?.ride?.status?.name),
                      key: ValueKey(rideRequest.ride!.sId!),
                      rideId: rideRequest.ride!.sId!,
                      chat: mapStore.chat,
                      foreground: Theme.of(context).colorScheme.surface,
                      send: (text) => mapStore.sendMessage(
                          rideId: rideRequest.ride!.sId!, message: text),
                      typing: (typing) => mapStore.sendTypingNotification(
                          rideId: rideRequest.ride!.sId!, isTyping: typing),
                    )),
          ],
        ),
      ),
    );
  }
}

class TypingAnimationWidget extends StatefulWidget {
  final Color dotColor;
  final double dotSize;
  final double spacing;
  final Duration animationDuration;

  const TypingAnimationWidget({
    super.key,
    this.dotColor = Colors.grey,
    this.dotSize = 8.0,
    this.spacing = 4.0,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<TypingAnimationWidget> createState() => _TypingAnimationWidgetState();
}

class _TypingAnimationWidgetState extends State<TypingAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();

    _animations = List.generate(3, (index) {
      final startInterval = index / 3;
      final endInterval = startInterval + 0.2;

      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 0.0),
          weight: startInterval * 100 + 1,
        ),
        // Dot moves up
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: -1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 10,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: -1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 10,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 0.0),
          weight: (1 - endInterval) * 100,
        ),
      ]).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0),
      ));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _animations[index].value * widget.dotSize),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
