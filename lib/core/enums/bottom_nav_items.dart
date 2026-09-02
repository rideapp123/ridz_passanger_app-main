// import 'package:flutter/material.dart';
//
//
// import '../constants/assets.dart';
//
// List<BottomTabItem> bottomTabItems = [
//   BottomTabItem.community,
//   BottomTabItem.ai,
//   BottomTabItem.experience,
// ];
//
// Map<BottomTabItem, Widget> bottomTabItemToPage = {
//   BottomTabItem.community: const CommunityMainPage(),
//   BottomTabItem.ai: const LesGoAIPage(),
//   BottomTabItem.experience: const ExperienceSelectHomePage(),
// };
//
// enum BottomTabItem {
//   community,
//   ai,
//   experience,
// }
//
// extension BottomNavItemsExtension on BottomTabItem {
//   String get name {
//     switch (this) {
//       case BottomTabItem.community:
//         return 'Community';
//       case BottomTabItem.ai:
//         return 'AI';
//       case BottomTabItem.experience:
//         return 'Experience';
//       default:
//         return 'Experience';
//     }
//   }
//
//   String get icon {
//     switch (this) {
//       case BottomTabItem.community:
//         return Assets.BOTTOMBAR_COMMUNITY;
//       case BottomTabItem.ai:
//         return Assets.BOTTOMBAR_AI;
//       case BottomTabItem.experience:
//         return Assets.BOTTOMBAR_EXPERIENCE;
//       default:
//         return Assets.BOTTOMBAR_EXPERIENCE;
//     }
//   }
// }
