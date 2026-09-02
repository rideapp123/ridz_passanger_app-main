// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

abstract class Styles {
  static const Color COLOR_BG_WHITE = Color(0xFFF8F8F8);
  static const Color COLOR_BG_FULL_WHITE = Color(0xffffffff);
  static const Color COLOR_BG_OFF_WHITE = Color(0xffe8e8e8);

  // static const Color COLOR_BG_BLACK = Color(0xFF0c0c0c);

  static const Color COLOR_BG_BLACK = Color(0xFF121212);
  static const Color COLOR_CARD_GREY = Color(0xff242526);
  static const Color COLOR_CARD_GREY_93 = Color(0xff949393);
  static const Color COLOR_CARD_WHITE_E8E8 = Color(0xffE8E8E8);
  static const Color COLOR_CARD_BLUE_52FE = Color(0xff6552FE);

  // COLORS
  static const Color COLOR_BACKGROUND_YELLOW = Color.fromRGBO(255, 214, 0, 1);
  static const Color COLOR_PRIMARY_BLACK = Color.fromRGBO(0, 0, 0, 1);
  static const Color COLOR_PRIMARY_BLUE = Color.fromRGBO(53, 124, 184, 1);
  static const Color COLOR_OFF_GREY = Color.fromRGBO(0, 0, 0, 0.5);
  static const Color COLOR_ON_GREY = Color.fromRGBO(0, 0, 0, 1);
  static const Color COLOR_SECONDARY_BLACK_75 = Color.fromRGBO(0, 0, 0, 0.75);
  static const Color COLOR_BACKGROUND_WHITE = Color(0xffF3F2F2);
  static const Color COLOR_BACKGROUND_OFF_WHITE =
      Color.fromRGBO(249, 249, 249, 1);
  static const Color COLOR_GRADIANT = Color(0xFFffba94);
  static const COLOR_GREEN = Color(0xff2f7b00);
  static const COLOR_GREEN_BUTTON = Color(0XFFA8D104);
  static const COLOR_GREY = Color.fromARGB(255, 236, 237, 233);
  static const COLOR_ORANGE_BUTTON = Color(0xFFFC482D);
  static const COLOR_PRIMARY_ORANGE = Color(0xFFFF5b00);
  static const COLOR_RESERVATIONS_TODAY = Color(0xff96AA6B);
  static const COLOR_RESERVATIONS_UPCOMING = Color(0xffD4D06E);
  static const COLOR_RESERVATIONS_HISTORY = Color(0xffEA6C6C);
  static const COLOR_FAVOURITE = Color(0xffEB3842);
  static const COLOR_GREY_TEXT = Color(0xffa0a0a0);
  static const COLOR_BLUE_GRE_552FE = Color(0xff6552FE);
  static const COLOR_BLACK_BC = Color(0xff222529);

  static const COLOR_PRIMARY_LINEAR_GRADIENT = LinearGradient(
    colors: [
      Color(0xFFE55649),
      Color(0xFFA43707),
    ],
    stops: [
      0.3,
      0.9,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const COLOR_PRIMARY_LINEAR_GRADIENT_LOGIN_SCREEN_LEFT = LinearGradient(
    colors: [
      Color(0xFF121212),
      Color(0xFF4A4A4A),
    ],
    stops: [
      0.3,
      0.9,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const COLOR_PRIMARY_LINEAR_GRADIENT_LOGIN_SCREEN_RIGHT =
      LinearGradient(
    colors: [
      Color(0xFF4A4A4A),
      Color(0xFF121212),
    ],
    stops: [
      0.3,
      0.9,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const COLOR_LOGIN_GRADIENT = LinearGradient(
    colors: [
      Colors.transparent,
      Colors.black54,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  ///Text Gradient
  static Shader linearGradient = COLOR_LOGIN_GRADIENT
      .createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  static const COLOR_APPBAR_LINEAR_GRADIENT = LinearGradient(
      colors: [
        Color(0xFFFF5b00),
        Color(0xFFFF965C),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.3, 1]);

  static const COLOR_BOOKING_CONFIRMED = Color(0xFF249AA4);
  static const COLOR_ERROR_RED = Color(0xFFE00321);
  static const COLOR_LIGHT_ORANGE_BACKGROUND = Color(0xFFFF6320);
  static const COLOR_ORANGE = Color(0xFFFF5B00);
  static const COLOR_NFC_CONNECTED = Color(0xFF249AA4);

  //Tier Colors
  static const COLOR_TIER_GOLD = Color(0xFFFFD700);
  static const COLOR_TIER_SILVER = Color(0xFFC0C0C0);
  static const COLOR_TIER_BRONZE = Color(0xFFCD7F32);

  // Tier Gradients
  // Gold - AE8626, F7EF8A, D2AC47, EDC967
  // SIlver - AFAEAE, E6EAEC, BCC6CC, C0C0C0
  // Bronze - 905923, D78F4A, A46628, B9722D

  static const COLOR_TIER_GOLD_GRADIENT = LinearGradient(
    colors: [
      Color(0xFFAE8626),
      Color(0xFFF7EF8A),
      Color(0xFFD2AC47),
      Color(0xFFEDC967),
    ],
    stops: [0.26, 0.5, 0.75, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const COLOR_TIER_SILVER_GRADIENT = LinearGradient(
    colors: [
      Color(0xFFAFAEAE),
      Color(0xFFE6EAEC),
      Color(0xFFBCC6CC),
      Color(0xFFC0C0C0),
    ],
    stops: [0.26, 0.5, 0.75, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const COLOR_TIER_BRONZE_GRADIENT = LinearGradient(
    colors: [
      Color(0xFF905923),
      Color(0xFFD78F4A),
      Color(0xFFA46628),
      Color(0xFFB9722D),
    ],
    stops: [0.26, 0.5, 0.75, 1],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const COLOR_AI_BG_PURPLE = Color(0xffCC97FF);

  // FONT-SIZES

  static const double TEXT_HEADING_1 = 35.0;
  static const double TEXT_HEADING_2 = 26.0;
  static const double TEXT_HEADING_3 = 24.0;
  static const double TEXT_HEADING_4 = 17.5;
  static const double TEXT_NORMAL = 16.0;
  static const double TEXT_BODY = 14.0;
  static const double TEXT_SMALL = 12.0;

  // static const double TEXT_TITLE_SMALL = 14.0;
  // static const double TEXT_TITLE_MEDIUM = 16.0;
  // static const double TEXT_TITLE_LARGE = 22.0;

  // labelSmall (11): Very small labels for compact layouts or when space is limited.
  // labelMedium (12): Standard size for most labels.
  // labelLarge (14): Larger labels for emphasis or legibility on smaller screens.
  // bodySmall (12): Ideal for small amounts of text, like captions or footnotes.
  // bodyMedium (14): Default size for most body text, providing good readability.
  // bodyLarge (16): Larger body text for improved legibility on lower-resolution screens.
  // titleSmall (14): Good for smaller section headings or subheadings.
  // titleMedium (16): Standard size for prominent section titles.
  // titleLarge (22): Larger titles for emphasis or main sections.
  // headlineSmall (24): Introductory headlines or subheadings for major sections.
  // headlineMedium (28): Main headlines that capture attention.
  // headlineLarge (32): Very large headlines for maximum impact.
  // displaySmall (36): Suitable for app titles or logos on smaller screens.
  // displayMedium (45): Larger display fonts for greater visibility on bigger screens.
  // displayLarge (57): Huge display fonts for impactful logos or titles.

  // This is for the labelling the image and also the button texts
  static const double TEXT_LABEL_SMALL = 11.0;
  static const double TEXT_LABEL_MEDIUM = 12.0;
  static const double TEXT_LABEL_LARGE = 14.0;

  // This is for the description and paragraphs
  static const double TEXT_BODY_SMALL = 12.0;
  static const double TEXT_BODY_MEDIUM = 14.0;
  static const double TEXT_BODY_LARGE = 16.0;
  static const double TEXT_TITLE_SMALL = 14.0;
  static const double TEXT_TITLE_MEDIUM = 16.0;
  static const double TEXT_TITLE_SEMILARGE = 18.0;

  static const double TEXT_APPBAR = 18.0;

  // This is for the title of each tab on the topmost
  static const double TEXT_TITLE_LARGE = 22.0;

  // This is for the name of the Restaurants/heading of each section in the entire app
  static const double TEXT_HEADLINE_SMALL = 24.0;
  static const double TEXT_HEADLINE_MEDIUM = 28.0;
  static const double TEXT_HEADLINE_LARGE = 32.0;
  static const double TEXT_DISPLAY_SMALL = 36.0;
  static const double TEXT_DISPLAY_MEDIUM = 45.0;
  static const double TEXT_DISPLAY_LARGE = 57.0;

  static TextStyle textStyleHeading1(
      {Color? color,
      FontWeight? fontWeight,
      TextOverflow? overflow,
      double? size}) {
    return TextStyle(
      fontSize: size ?? TEXT_HEADING_1,
      color: color,
      fontWeight: fontWeight,
      overflow: overflow,
    );
  }

  static TextStyle textStyleHeading2(
      {Color? color,
      FontWeight? fontWeight,
      TextOverflow? overflow,
      double? size}) {
    return TextStyle(
      fontSize: size ?? TEXT_HEADING_2,
      color: color,
      fontWeight: fontWeight,
      overflow: overflow,
    );
  }

  static TextStyle textStyleHeading3(
      {Color? color,
      FontWeight? fontWeight,
      TextOverflow? overflow,
      double? size}) {
    return TextStyle(
      fontSize: size ?? TEXT_HEADING_3,
      color: color,
      fontWeight: fontWeight,
      overflow: overflow,
    );
  }

  static TextStyle textStyleHeading4(
      {Color? color,
      FontWeight? fontWeight,
      TextOverflow? overflow,
      double? size}) {
    return TextStyle(
      fontSize: size ?? TEXT_HEADING_4,
      color: color,
      fontWeight: fontWeight,
      overflow: overflow,
    );
  }

  static TextStyle textStyleNormalText(
      {Color? color,
      FontWeight? fontWeight,
      TextOverflow? overflow,
      TextDecoration? decoration,
      double? size}) {
    return TextStyle(
      decoration: decoration,
      fontSize: size ?? TEXT_NORMAL,
      color: color,
      fontWeight: fontWeight,
      overflow: overflow,
    );
  }

  static TextStyle textStyleBodyText(
      {Color? color,
      FontWeight? fontWeight,
      TextOverflow? overflow,
      double? size}) {
    return TextStyle(
      fontSize: size ?? TEXT_BODY,
      color: color,
      fontWeight: fontWeight,
      overflow: overflow,
    );
  }

  static TextStyle textStyleSmallText(
      {Color? color,
      FontWeight? fontWeight,
      TextOverflow? overflow,
      double? size}) {
    return TextStyle(
      fontSize: size ?? TEXT_SMALL,
      color: color,
      fontWeight: fontWeight,
      overflow: overflow,
    );
  }

  static TextStyle textStyleTitleSmall(
      {Color? color,
      FontWeight? fontWeight,
      TextOverflow? overflow,
      double? size}) {
    return TextStyle(
      fontSize: size ?? TEXT_TITLE_SMALL,
      color: color,
      fontWeight: fontWeight,
      overflow: overflow,
    );
  }

  static TextStyle textStyleTitleMedium(
      {Color? color,
      FontWeight? fontWeight,
      TextOverflow? overflow,
      double? size}) {
    return TextStyle(
      fontSize: size ?? TEXT_TITLE_MEDIUM,
      color: color,
      fontWeight: fontWeight,
      overflow: overflow,
    );
  }

  static TextStyle textStyleTitleLarge(
      {Color? color,
      FontWeight? fontWeight,
      TextOverflow? overflow,
      double? size}) {
    return TextStyle(
      fontSize: size ?? TEXT_TITLE_LARGE,
      color: color,
      fontWeight: fontWeight,
      overflow: overflow,
    );
  }

  // labelMedium, //Font Size - 12
  // labelLarge, //Font Size - 14
  // bodySmall, //Font Size - 12
  // bodyMedium, //Font Size - 14
  // bodyLarge, //Font Size - 16
  // titleSmall, //Font Size - 14
  // titleMedium, //Font Size - 16
  // titleLarge, //Font Size - 22
  // headlineSmall, //Font Size - 24
  // headlineMedium, //Font Size - 28
  // headlineLarge, //Font Size - 32
  // displaySmall, //Font Size - 36
  // displayMedium, //Font Size - 45
  // displayLarge, //Font Size - 57

  // Font Family
  // static const String HEADING_FONT = 'Poppins';

  // Border Radius

  static const BorderRadius defaultBorderRadius = BorderRadius.all(
    Radius.circular(15),
  );

  static const BorderRadius carouselContainerBorderRadius = BorderRadius.all(
    Radius.circular(25),
  );

  static const BorderRadius ratingContainerBorderRadius = BorderRadius.all(
    Radius.circular(25),
  );

  static const BorderRadius textFieldBorderRadius = BorderRadius.all(
    Radius.circular(10),
  );

  static const BorderRadius segmentedButtonBorderRadius = BorderRadius.all(
    Radius.circular(10),
  );
}
