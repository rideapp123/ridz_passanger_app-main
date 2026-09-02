// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$UIStore on UIStoreBase, Store {
  late final _$percentAtom =
      Atom(name: 'UIStoreBase.percent', context: context);

  @override
  int get percent {
    _$percentAtom.reportRead();
    return super.percent;
  }

  @override
  set percent(int value) {
    _$percentAtom.reportWrite(value, super.percent, () {
      super.percent = value;
    });
  }

  late final _$isSearchFocusedAtom =
      Atom(name: 'UIStoreBase.isSearchFocused', context: context);

  @override
  bool get isSearchFocused {
    _$isSearchFocusedAtom.reportRead();
    return super.isSearchFocused;
  }

  @override
  set isSearchFocused(bool value) {
    _$isSearchFocusedAtom.reportWrite(value, super.isSearchFocused, () {
      super.isSearchFocused = value;
    });
  }

  late final _$searchKeyAtom =
      Atom(name: 'UIStoreBase.searchKey', context: context);

  @override
  String get searchKey {
    _$searchKeyAtom.reportRead();
    return super.searchKey;
  }

  @override
  set searchKey(String value) {
    _$searchKeyAtom.reportWrite(value, super.searchKey, () {
      super.searchKey = value;
    });
  }

  late final _$hideBottomNavAtom =
      Atom(name: 'UIStoreBase.hideBottomNav', context: context);

  @override
  bool get hideBottomNav {
    _$hideBottomNavAtom.reportRead();
    return super.hideBottomNav;
  }

  @override
  set hideBottomNav(bool value) {
    _$hideBottomNavAtom.reportWrite(value, super.hideBottomNav, () {
      super.hideBottomNav = value;
    });
  }

  late final _$searchNearestAtom =
      Atom(name: 'UIStoreBase.searchNearest', context: context);

  @override
  bool get searchNearest {
    _$searchNearestAtom.reportRead();
    return super.searchNearest;
  }

  @override
  set searchNearest(bool value) {
    _$searchNearestAtom.reportWrite(value, super.searchNearest, () {
      super.searchNearest = value;
    });
  }

  late final _$latAtom = Atom(name: 'UIStoreBase.lat', context: context);

  @override
  double? get lat {
    _$latAtom.reportRead();
    return super.lat;
  }

  @override
  set lat(double? value) {
    _$latAtom.reportWrite(value, super.lat, () {
      super.lat = value;
    });
  }

  late final _$lngAtom = Atom(name: 'UIStoreBase.lng', context: context);

  @override
  double? get lng {
    _$lngAtom.reportRead();
    return super.lng;
  }

  @override
  set lng(double? value) {
    _$lngAtom.reportWrite(value, super.lng, () {
      super.lng = value;
    });
  }

  late final _$addressAtom =
      Atom(name: 'UIStoreBase.address', context: context);

  @override
  String? get address {
    _$addressAtom.reportRead();
    return super.address;
  }

  @override
  set address(String? value) {
    _$addressAtom.reportWrite(value, super.address, () {
      super.address = value;
    });
  }

  late final _$currentNavigationIndexAtom =
      Atom(name: 'UIStoreBase.currentNavigationIndex', context: context);

  @override
  int get currentNavigationIndex {
    _$currentNavigationIndexAtom.reportRead();
    return super.currentNavigationIndex;
  }

  @override
  set currentNavigationIndex(int value) {
    _$currentNavigationIndexAtom
        .reportWrite(value, super.currentNavigationIndex, () {
      super.currentNavigationIndex = value;
    });
  }

  late final _$isLocationPermissionGivenAtom =
      Atom(name: 'UIStoreBase.isLocationPermissionGiven', context: context);

  @override
  bool? get isLocationPermissionGiven {
    _$isLocationPermissionGivenAtom.reportRead();
    return super.isLocationPermissionGiven;
  }

  @override
  set isLocationPermissionGiven(bool? value) {
    _$isLocationPermissionGivenAtom
        .reportWrite(value, super.isLocationPermissionGiven, () {
      super.isLocationPermissionGiven = value;
    });
  }

  late final _$isAddressLoadingAtom =
      Atom(name: 'UIStoreBase.isAddressLoading', context: context);

  @override
  bool get isAddressLoading {
    _$isAddressLoadingAtom.reportRead();
    return super.isAddressLoading;
  }

  @override
  set isAddressLoading(bool value) {
    _$isAddressLoadingAtom.reportWrite(value, super.isAddressLoading, () {
      super.isAddressLoading = value;
    });
  }

  late final _$isUserEditingProfileAtom =
      Atom(name: 'UIStoreBase.isUserEditingProfile', context: context);

  @override
  bool get isUserEditingProfile {
    _$isUserEditingProfileAtom.reportRead();
    return super.isUserEditingProfile;
  }

  @override
  set isUserEditingProfile(bool value) {
    _$isUserEditingProfileAtom.reportWrite(value, super.isUserEditingProfile,
        () {
      super.isUserEditingProfile = value;
    });
  }

  late final _$updateMyLocationAsyncAction =
      AsyncAction('UIStoreBase.updateMyLocation', context: context);

  @override
  Future<bool> updateMyLocation({bool showDialogAgain = false}) {
    return _$updateMyLocationAsyncAction
        .run(() => super.updateMyLocation(showDialogAgain: showDialogAgain));
  }

  late final _$updateMyAddressAsyncAction =
      AsyncAction('UIStoreBase.updateMyAddress', context: context);

  @override
  Future<void> updateMyAddress() {
    return _$updateMyAddressAsyncAction.run(() => super.updateMyAddress());
  }

  late final _$initAppAsyncAction =
      AsyncAction('UIStoreBase.initApp', context: context);

  @override
  Future<void> initApp() {
    return _$initAppAsyncAction.run(() => super.initApp());
  }

  late final _$UIStoreBaseActionController =
      ActionController(name: 'UIStoreBase', context: context);

  @override
  void setIsSearchFocused(bool isSearchFocused) {
    final _$actionInfo = _$UIStoreBaseActionController.startAction(
        name: 'UIStoreBase.setIsSearchFocused');
    try {
      return super.setIsSearchFocused(isSearchFocused);
    } finally {
      _$UIStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSearchKey(String searchKey) {
    final _$actionInfo = _$UIStoreBaseActionController.startAction(
        name: 'UIStoreBase.setSearchKey');
    try {
      return super.setSearchKey(searchKey);
    } finally {
      _$UIStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setHideBottomNav(bool hideBottomNav) {
    final _$actionInfo = _$UIStoreBaseActionController.startAction(
        name: 'UIStoreBase.setHideBottomNav');
    try {
      return super.setHideBottomNav(hideBottomNav);
    } finally {
      _$UIStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSearchNearest(bool nearest) {
    final _$actionInfo = _$UIStoreBaseActionController.startAction(
        name: 'UIStoreBase.setSearchNearest');
    try {
      return super.setSearchNearest(nearest);
    } finally {
      _$UIStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsUserEditingProfile(bool isUserEditingProfile) {
    final _$actionInfo = _$UIStoreBaseActionController.startAction(
        name: 'UIStoreBase.setIsUserEditingProfile');
    try {
      return super.setIsUserEditingProfile(isUserEditingProfile);
    } finally {
      _$UIStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
percent: ${percent},
isSearchFocused: ${isSearchFocused},
searchKey: ${searchKey},
hideBottomNav: ${hideBottomNav},
searchNearest: ${searchNearest},
lat: ${lat},
lng: ${lng},
address: ${address},
currentNavigationIndex: ${currentNavigationIndex},
isLocationPermissionGiven: ${isLocationPermissionGiven},
isAddressLoading: ${isAddressLoading},
isUserEditingProfile: ${isUserEditingProfile}
    ''';
  }
}
