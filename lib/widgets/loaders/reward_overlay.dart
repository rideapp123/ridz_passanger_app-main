// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:mobx/mobx.dart';
//
// import '../../../core/constants/assets.dart';
// import '../../../stores/restaurants/item_subscription_store.dart';
//
// class RewardOverlay extends StatefulWidget {
//   const RewardOverlay({
//     super.key,
//     required this.child,
//     required this.onClaimed,
//   });
//
//   final Widget child;
//   final VoidCallback onClaimed;
//
//   @override
//   State<RewardOverlay> createState() => _RewardOverlayState();
// }
//
// class _RewardOverlayState extends State<RewardOverlay>
//     with TickerProviderStateMixin {
//   late final ReactionDisposer claimReaction;
//
//   late bool claiming;
//   late bool claimed;
//   late bool claimError;
//
//   late final AnimationController giftBoxLoopAnimationController;
//   late final AnimationController controller;
//   late final AnimationController confettiController;
//
//   double giftBoxStart = 0.1;
//   double giftBoxShakeStop = 0.5;
//
//   void _updateStates(bool isClaiming, bool isClaimError) {
//     // started to claim
//     if (!claiming && isClaiming) {
//       if (mounted) {
//         setState(() {
//           claiming = isClaiming;
//         });
//       }
//     }
//
//     // claim success without any errors
//     if (claiming && !isClaiming && !claimError) {
//       if (mounted) {
//         setState(() {
//           claiming = isClaiming;
//           claimed = true;
//         });
//       }
//     }
//
//     // error happened while claiming
//     if (isClaimError) {
//       if (mounted) {
//         setState(() {
//           claiming = false;
//           claimed = false;
//           claimError = true;
//
//           // Reset animation controllers here
//           giftBoxLoopAnimationController.reset();
//           controller.reset();
//           confettiController.reset();
//         });
//       }
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     claiming = false;
//     claimed = false;
//     claimError = false;
//
//     giftBoxLoopAnimationController = AnimationController(vsync: this);
//     controller = AnimationController(vsync: this);
//     confettiController = AnimationController(vsync: this);
//
//     claimReaction = autorun((_) {
//       final isClaiming = ItemSubscriptionStoreProvider().isClaiming;
//       final isClaimError = ItemSubscriptionStoreProvider().isClaimError;
//
//       scheduleMicrotask(() {
//         _updateStates(isClaiming, isClaimError);
//       });
//     });
//
//     controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         scheduleMicrotask(() {
//           if (mounted && claimed) {
//             setState(() {
//               claimed = false;
//
//               // Reset animation controllers here
//               giftBoxLoopAnimationController.reset();
//               controller.reset();
//               confettiController.reset();
//
//               widget.onClaimed();
//             });
//           }
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     claimReaction();
//     giftBoxLoopAnimationController.dispose();
//     controller.dispose();
//     confettiController.dispose();
//
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         widget.child,
//         if (claiming)
//           DecoratedBox(
//             decoration: BoxDecoration(
//               color: Colors.black.withValues(alpha: 0.3),
//             ),
//             child: Center(
//               child: Lottie.asset(
//                 Assets.LOTTIE_GIFT_BOX,
//                 controller: giftBoxLoopAnimationController,
//                 onLoaded: (composition) {
//                   giftBoxLoopAnimationController.duration =
//                       composition.duration;
//
//                   giftBoxLoopAnimationController.repeat(
//                     min: giftBoxStart,
//                     max: giftBoxShakeStop,
//                     period: giftBoxLoopAnimationController.duration! *
//                         (giftBoxShakeStop - giftBoxStart),
//                   );
//                 },
//               ),
//             ),
//           ),
//         if (claimed) ...[
//           DecoratedBox(
//             decoration: BoxDecoration(
//               color: Colors.black.withValues(alpha: 0.3),
//             ),
//             child: Center(
//               child: Lottie.asset(
//                 Assets.LOTTIE_CONFETTI,
//                 repeat: false,
//                 controller: confettiController,
//                 onLoaded: (composition) async {
//                   confettiController.duration = composition.duration;
//
//                   await Future.delayed(
//                     const Duration(seconds: 1),
//                     () => confettiController.forward(),
//                   );
//                 },
//               ),
//             ),
//           ),
//           Center(
//             child: Lottie.asset(
//               Assets.LOTTIE_GIFT_BOX,
//               controller: controller,
//               repeat: false,
//               onLoaded: (composition) {
//                 controller.duration = composition.duration;
//
//                 controller.forward();
//               },
//             ),
//           ),
//         ]
//       ],
//     );
//   }
// }
