import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/models/common/ride_response/ride_response.dart';
import 'package:ridzs_passenger_app/services/debouncer_service.dart';
import 'package:ridzs_passenger_app/stores/map/map_store.dart';
import 'package:url_launcher/url_launcher.dart';

class RideChatBottomSheet extends HookWidget {
  final RideRequest rideRequest;
  const RideChatBottomSheet({
    super.key,
    required this.rideRequest,
  });

  @override
  Widget build(BuildContext context) {
    final debounce = useMemoized(
      () => Debouncer(
        delay: const Duration(milliseconds: 500),
      ),
    );
    final messageController = useTextEditingController();
    final mapStore = mapStoreProvider();

    useEffect(() {
      mapStore.loadChatMessage(
        rideId: rideRequest.ride!.sId!,
      );
      mapStore.joinChatRoom(rideId: rideRequest.ride!.sId!);
      return () {
        mapStore.leaveChatRoom(rideId: rideRequest.ride!.sId!);
      };
    }, []);

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

                        Text(
                          rideRequest.driverName ?? '',
                          style: AppTextStyles.style15w400.copyWith(
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      final number = 'tel:${rideRequest.driverNumber}';
                      launchUrl(Uri.parse(number));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: SizeConfig.screenWidth * 0.1,
                      height: SizeConfig.screenWidth * 0.1,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: CustomImageView(
                        svgPath: Assets.phoneIc2,
                        height: 24,
                        width: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //
            Observer(builder: (context) {
              if (mapStore.isLoadingChatMessage) {
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

                        Container(
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
                                style: AppTextStyles.style15w400.copyWith(
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),

                              Text(
                                formattedDate,
                                style: AppTextStyles.style12w400.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryFixedDim,
                                ),
                              ),
                            ],
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
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: SizeConfig.screenHeight * 0.01,
              ),
              child: SizedBox(
                height: SizeConfig.screenHeight * 0.05,
                child: ListView.separated(
                  itemCount: 6,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.screenWidth * 0.04,
                  ),
                  separatorBuilder: (context, index) {
                    return SizedBox(width: SizeConfig.screenWidth * 0.02);
                  },
                  itemBuilder: (_, index) {
                    return Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.screenWidth * 0.04,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiaryFixedDim
                            .withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Okay, I’ll be there in a minute',
                        style: AppTextStyles.style15w400.copyWith(
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            //
            Divider(
              color: Theme.of(context)
                  .colorScheme
                  .tertiaryFixedDim
                  .withValues(alpha: .4),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.screenWidth * 0.04,
                vertical: SizeConfig.screenHeight * 0.02,
              ),
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: messageController,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      mapStore.sendTypingNotification(
                        rideId: rideRequest.ride!.sId!,
                        isTyping: true,
                      );
                    }
                    debounce.run(() {
                      mapStore.sendTypingNotification(
                        rideId: rideRequest.ride!.sId!,
                        isTyping: false,
                      );
                    });
                  },
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.screenWidth * 0.04,
                      vertical: 8,
                    ),
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.tertiaryFixedDim,
                    ),
                    fillColor: Theme.of(context).colorScheme.onSecondary,
                    filled: true,
                    suffixIcon: IconButton(
                      onPressed: () {
                        if (messageController.text.isEmpty) return;
                        mapStore.sendMessage(
                          rideId: rideRequest.ride!.sId!,
                          message: messageController.text,
                        );

                        messageController.clear();
                      },
                      icon: Icon(
                        Icons.send,
                        size: 20,
                        color: Theme.of(context).colorScheme.tertiaryFixedDim,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            //
            SizedBox(height: SizeConfig.screenHeight * 0.02),
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
