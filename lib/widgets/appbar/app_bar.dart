// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
//
// import '../../../core/constants/assets.dart';
// import '../../../core/theme/size_config.dart';
// import '../../../core/theme/styles.dart';
// import '../../../stores/users/user_store.dart';
// import 'appbar_icons.dart';
//
// class CustomAppBar extends HookWidget implements PreferredSizeWidget {
//   const CustomAppBar({
//     super.key,
//     this.text,
//     this.title,
//     this.toolbarHeight,
//     this.isCommunity = false,
//     this.isHome = false,
//     this.isCreatePost = false,
//     this.hasNotificationIcon = true,
//     this.onBackPressed,
//     this.hasLeading = true,
//     this.hasLeadingLogo = false,
//     this.textColor,
//     this.actions,
//     this.hasProfileIcon = true,
//     this.statusBarIconBrightness = Brightness.dark,
//     this.hasLightNotificationIcon = false,
//     this.backgroundColor,
//     this.leadingWidget,
//     this.onTapPost,
//     this.actionButtonText = '',
//     this.statusBarColor,
//   });
//   final String? text;
//   final bool hasNotificationIcon;
//   final bool hasLeading;
//   final bool hasLeadingLogo;
//   final bool hasProfileIcon;
//   final VoidCallback? onBackPressed;
//   final bool hasLightNotificationIcon;
//   final Color? textColor;
//   final List<Widget>? actions;
//   final Brightness statusBarIconBrightness;
//   final Color? backgroundColor;
//   final Widget? leadingWidget;
//   final String actionButtonText;
//   final bool isHome;
//   final bool isCommunity;
//   final VoidCallback? onTapPost;
//   final bool isCreatePost;
//   final Widget? title;
//   final double? toolbarHeight;
//   final Color? statusBarColor;
//
//   @override
//   Widget build(BuildContext context) {
//     if (isCreatePost) {
//       return createPostAppBar(context);
//     } else {
//       return Observer(builder: (_) {
//         var user = userStoreProvider().loggedInUser;
//         return AppBar(
//           toolbarHeight: toolbarHeight ?? kToolbarHeight,
//           scrolledUnderElevation: 0,
//           centerTitle: false,
//           surfaceTintColor: Colors.transparent,
//           backgroundColor: backgroundColor,
//           systemOverlayStyle: SystemUiOverlayStyle(
//             statusBarColor: statusBarColor ?? Colors.transparent,
//             statusBarIconBrightness: statusBarIconBrightness,
//             statusBarBrightness: statusBarIconBrightness == Brightness.light
//                 ? Brightness.dark
//                 : Brightness.light,
//           ),
//           automaticallyImplyLeading: hasLeading,
//           iconTheme: IconThemeData(
//             color: textColor,
//           ),
//           title: title ??
//               Text(
//                 text ?? '',
//                 maxLines: 2,
//                 softWrap: true,
//                 style: TextStyle(
//                   color: textColor,
//                   fontWeight: FontWeight.w600,
//                   fontSize: Styles.TEXT_APPBAR,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//           leading: hasLeadingLogo
//               ? Container(
//                   margin: const EdgeInsets.only(left: 20, top: 5),
//                   child: const SvgIcon(
//                     icon: Assets.SVG_LOGO,
//                   ),
//                 )
//               : hasLeading
//                   ? leadingWidget ??
//                       BackButton(
//                         onPressed: onBackPressed,
//                         color: textColor,
//                       )
//                   : null,
//           leadingWidth: 50,
//           actions: [
//             ...?getActions(
//                 context: context,
//                 hasNotificationIcon: hasNotificationIcon,
//                 url: user?.profile_pic_url,
//                 showProfile: hasProfileIcon,
//                 hasLightNotificationIcon: hasLightNotificationIcon),
//             ...?actions,
//           ],
//         );
//       });
//     }
//   }
//
//   Widget createPostAppBar(BuildContext context) {
//     return SafeArea(
//       bottom: true,
//       child: Row(
//         children: [
//           IconButton(
//               onPressed: onBackPressed ??
//                   () {
//                     Navigator.pop(context);
//                   },
//               icon: const SvgIcon(
//                 width: 16,
//                 icon: Assets.ARROW_BACK,
//               )),
//           Text(
//             text ?? '',
//             textAlign: TextAlign.start,
//             style: TextStyle(
//               color: textColor,
//               fontWeight: FontWeight.w600,
//               fontSize: 20,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//           const Spacer(),
//           Bounce(
//             onTap: onTapPost ?? () {},
//             child: Container(
//               height: 31,
//               padding: EdgeInsets.symmetric(
//                   horizontal: text == 'Create an Invite' ? 13 : 20),
//               margin:
//                   EdgeInsets.only(right: SizeConfig.safeBlockHorizontal * 4),
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Styles.COLOR_PRIMARY_ORANGE),
//               child: Center(
//                 child: Text(actionButtonText,
//                     style: Styles.textStyleNormalText(
//                         fontWeight: FontWeight.w600, color: Colors.white)),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   //implement preferredSize
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
