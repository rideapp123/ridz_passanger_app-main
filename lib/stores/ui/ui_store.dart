import 'package:geolocator/geolocator.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import '../../core/services/geolocator_service.dart';
import '../../core/services/navigation_service.dart';
import '../../core/services/permission_service.dart';

part 'ui_store.g.dart';

class UIStore = UIStoreBase with _$UIStore;

UIStore uiStoreProvider({bool listen = false}) {
  return Provider.of(NavigationService.navigatorKey.currentContext!,
      listen: listen);
}

abstract class UIStoreBase with Store {
  @observable
  int percent = 90;

  ///Search Module
  @observable
  bool isSearchFocused = false;

  @action
  void setIsSearchFocused(bool isSearchFocused) {
    this.isSearchFocused = isSearchFocused;
  }

  @observable
  String searchKey = '';

  @action
  void setSearchKey(String searchKey) {
    this.searchKey = searchKey;
  }

  @observable
  bool hideBottomNav = false;

  @action
  void setHideBottomNav(bool hideBottomNav) {
    this.hideBottomNav = hideBottomNav;
  }

  @observable
  bool searchNearest = false;

  @action
  void setSearchNearest(bool nearest) {
    searchNearest = nearest;
  }

  @observable
  double? lat;

  @observable
  double? lng;

  @observable
  String? address;

  @observable
  int currentNavigationIndex = 0;

  @observable
  bool? isLocationPermissionGiven;

  @observable
  bool isAddressLoading = false;

  @observable
  bool isUserEditingProfile = false;

  @action
  void setIsUserEditingProfile(bool isUserEditingProfile) {
    this.isUserEditingProfile = isUserEditingProfile;
  }

  @action
  Future<bool> updateMyLocation({bool showDialogAgain = false}) async {
    if (!await PermissionService.isLocationPermissionPermanentlyDenied()) {
      await Geolocator.requestPermission();
    }
    final isEnabled = await PermissionService.showPermissionDialogIfNotGiven(
        showDialogAgain: showDialogAgain);
    if (isEnabled == true) {
      var position = await geoLocator();
      lat = position.latitude;
      lng = position.longitude;
      return true;
    } else {
      return false;
    }
  }

  @action
  Future<void> updateMyAddress() async {
    if (isAddressLoading) {
      return;
    }
    isAddressLoading = true;
    var address = await getMyAddress();
    if (address != null) {
      this.address = address;
    }
    isAddressLoading = false;
  }

  bool hasUserPosition() {
    return lat != null && lng != null;
  }

  @action
  Future<void> initApp() async {
    updateMyLocation();
    updateMyAddress();
  }

  void onLogOut() {
    percent = 90;
    currentNavigationIndex = 0;
    isAddressLoading = false;
    isUserEditingProfile = false;
    searchNearest = false;
    lat = null;
    lng = null;
    address = null;
    isSearchFocused = false;
    searchKey = '';
    hideBottomNav = false;
  }
}
