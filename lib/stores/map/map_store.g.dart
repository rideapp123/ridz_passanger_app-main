// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$MapStore on MapStoreBase, Store {
  Computed<List<Price>>? _$pricesListComputed;

  @override
  List<Price> get pricesList =>
      (_$pricesListComputed ??= Computed<List<Price>>(() => super.pricesList,
              name: 'MapStoreBase.pricesList'))
          .value;
  Computed<bool>? _$hasValidLocationsComputed;

  @override
  bool get hasValidLocations => (_$hasValidLocationsComputed ??= Computed<bool>(
          () => super.hasValidLocations,
          name: 'MapStoreBase.hasValidLocations'))
      .value;
  Computed<bool>? _$isSearchingComputed;

  @override
  bool get isSearching =>
      (_$isSearchingComputed ??= Computed<bool>(() => super.isSearching,
              name: 'MapStoreBase.isSearching'))
          .value;

  late final _$isLoginLoadingAtom =
      Atom(name: 'MapStoreBase.isLoginLoading', context: context);

  @override
  bool get isLoginLoading {
    _$isLoginLoadingAtom.reportRead();
    return super.isLoginLoading;
  }

  @override
  set isLoginLoading(bool value) {
    _$isLoginLoadingAtom.reportWrite(value, super.isLoginLoading, () {
      super.isLoginLoading = value;
    });
  }

  late final _$isDirectionLoadingAtom =
      Atom(name: 'MapStoreBase.isDirectionLoading', context: context);

  @override
  bool get isDirectionLoading {
    _$isDirectionLoadingAtom.reportRead();
    return super.isDirectionLoading;
  }

  @override
  set isDirectionLoading(bool value) {
    _$isDirectionLoadingAtom.reportWrite(value, super.isDirectionLoading, () {
      super.isDirectionLoading = value;
    });
  }

  late final _$coordinatesListAtom =
      Atom(name: 'MapStoreBase.coordinatesList', context: context);

  @override
  ObservableList<LatLng> get coordinatesList {
    _$coordinatesListAtom.reportRead();
    return super.coordinatesList;
  }

  @override
  set coordinatesList(ObservableList<LatLng> value) {
    _$coordinatesListAtom.reportWrite(value, super.coordinatesList, () {
      super.coordinatesList = value;
    });
  }

  late final _$tempCoordinatesListAtom =
      Atom(name: 'MapStoreBase.tempCoordinatesList', context: context);

  @override
  ObservableList<LatLng> get tempCoordinatesList {
    _$tempCoordinatesListAtom.reportRead();
    return super.tempCoordinatesList;
  }

  @override
  set tempCoordinatesList(ObservableList<LatLng> value) {
    _$tempCoordinatesListAtom.reportWrite(value, super.tempCoordinatesList, () {
      super.tempCoordinatesList = value;
    });
  }

  late final _$isCurrentControllerAtom =
      Atom(name: 'MapStoreBase.isCurrentController', context: context);

  @override
  bool get isCurrentController {
    _$isCurrentControllerAtom.reportRead();
    return super.isCurrentController;
  }

  @override
  set isCurrentController(bool value) {
    _$isCurrentControllerAtom.reportWrite(value, super.isCurrentController, () {
      super.isCurrentController = value;
    });
  }

  late final _$searchPlaceModelAtom =
      Atom(name: 'MapStoreBase.searchPlaceModel', context: context);

  @override
  SearchPlace? get searchPlaceModel {
    _$searchPlaceModelAtom.reportRead();
    return super.searchPlaceModel;
  }

  @override
  set searchPlaceModel(SearchPlace? value) {
    _$searchPlaceModelAtom.reportWrite(value, super.searchPlaceModel, () {
      super.searchPlaceModel = value;
    });
  }

  late final _$directionsAtom =
      Atom(name: 'MapStoreBase.directions', context: context);

  @override
  DirectionResponse? get directions {
    _$directionsAtom.reportRead();
    return super.directions;
  }

  @override
  set directions(DirectionResponse? value) {
    _$directionsAtom.reportWrite(value, super.directions, () {
      super.directions = value;
    });
  }

  late final _$mapStyleStringAtom =
      Atom(name: 'MapStoreBase.mapStyleString', context: context);

  @override
  String get mapStyleString {
    _$mapStyleStringAtom.reportRead();
    return super.mapStyleString;
  }

  @override
  set mapStyleString(String value) {
    _$mapStyleStringAtom.reportWrite(value, super.mapStyleString, () {
      super.mapStyleString = value;
    });
  }

  late final _$selectedSuggestionsFromAtom =
      Atom(name: 'MapStoreBase.selectedSuggestionsFrom', context: context);

  @override
  Features? get selectedSuggestionsFrom {
    _$selectedSuggestionsFromAtom.reportRead();
    return super.selectedSuggestionsFrom;
  }

  @override
  set selectedSuggestionsFrom(Features? value) {
    _$selectedSuggestionsFromAtom
        .reportWrite(value, super.selectedSuggestionsFrom, () {
      super.selectedSuggestionsFrom = value;
    });
  }

  late final _$selectedSuggestionsToAtom =
      Atom(name: 'MapStoreBase.selectedSuggestionsTo', context: context);

  @override
  Features? get selectedSuggestionsTo {
    _$selectedSuggestionsToAtom.reportRead();
    return super.selectedSuggestionsTo;
  }

  @override
  set selectedSuggestionsTo(Features? value) {
    _$selectedSuggestionsToAtom.reportWrite(value, super.selectedSuggestionsTo,
        () {
      super.selectedSuggestionsTo = value;
    });
  }

  late final _$currentLocationControllerAtom =
      Atom(name: 'MapStoreBase.currentLocationController', context: context);

  @override
  TextEditingController get currentLocationController {
    _$currentLocationControllerAtom.reportRead();
    return super.currentLocationController;
  }

  @override
  set currentLocationController(TextEditingController value) {
    _$currentLocationControllerAtom
        .reportWrite(value, super.currentLocationController, () {
      super.currentLocationController = value;
    });
  }

  late final _$designationControllerAtom =
      Atom(name: 'MapStoreBase.designationController', context: context);

  @override
  TextEditingController get designationController {
    _$designationControllerAtom.reportRead();
    return super.designationController;
  }

  @override
  set designationController(TextEditingController value) {
    _$designationControllerAtom.reportWrite(value, super.designationController,
        () {
      super.designationController = value;
    });
  }

  late final _$nearbyDriversAtom =
      Atom(name: 'MapStoreBase.nearbyDrivers', context: context);

  @override
  ObservableMap<String, DriverLocation> get nearbyDrivers {
    _$nearbyDriversAtom.reportRead();
    return super.nearbyDrivers;
  }

  @override
  set nearbyDrivers(ObservableMap<String, DriverLocation> value) {
    _$nearbyDriversAtom.reportWrite(value, super.nearbyDrivers, () {
      super.nearbyDrivers = value;
    });
  }

  late final _$isCreatingRideAtom =
      Atom(name: 'MapStoreBase.isCreatingRide', context: context);

  @override
  bool get isCreatingRide {
    _$isCreatingRideAtom.reportRead();
    return super.isCreatingRide;
  }

  @override
  set isCreatingRide(bool value) {
    _$isCreatingRideAtom.reportWrite(value, super.isCreatingRide, () {
      super.isCreatingRide = value;
    });
  }

  late final _$isRideAcceptedAtom =
      Atom(name: 'MapStoreBase.isRideAccepted', context: context);

  @override
  bool get isRideAccepted {
    _$isRideAcceptedAtom.reportRead();
    return super.isRideAccepted;
  }

  @override
  set isRideAccepted(bool value) {
    _$isRideAcceptedAtom.reportWrite(value, super.isRideAccepted, () {
      super.isRideAccepted = value;
    });
  }

  late final _$errorAtom = Atom(name: 'MapStoreBase.error', context: context);

  @override
  String? get error {
    _$errorAtom.reportRead();
    return super.error;
  }

  @override
  set error(String? value) {
    _$errorAtom.reportWrite(value, super.error, () {
      super.error = value;
    });
  }

  late final _$isConnectedAtom =
      Atom(name: 'MapStoreBase.isConnected', context: context);

  @override
  bool get isConnected {
    _$isConnectedAtom.reportRead();
    return super.isConnected;
  }

  @override
  set isConnected(bool value) {
    _$isConnectedAtom.reportWrite(value, super.isConnected, () {
      super.isConnected = value;
    });
  }

  late final _$currentRideAtom =
      Atom(name: 'MapStoreBase.currentRide', context: context);

  @override
  RideRequest? get currentRide {
    _$currentRideAtom.reportRead();
    return super.currentRide;
  }

  @override
  set currentRide(RideRequest? value) {
    _$currentRideAtom.reportWrite(value, super.currentRide, () {
      super.currentRide = value;
    });
  }

  late final _$googleMapControllerAtom =
      Atom(name: 'MapStoreBase.googleMapController', context: context);

  @override
  GoogleMapController? get googleMapController {
    _$googleMapControllerAtom.reportRead();
    return super.googleMapController;
  }

  @override
  set googleMapController(GoogleMapController? value) {
    _$googleMapControllerAtom.reportWrite(value, super.googleMapController, () {
      super.googleMapController = value;
    });
  }

  late final _$isMapReadyAtom =
      Atom(name: 'MapStoreBase.isMapReady', context: context);

  @override
  Observable<bool> get isMapReady {
    _$isMapReadyAtom.reportRead();
    return super.isMapReady;
  }

  @override
  set isMapReady(Observable<bool> value) {
    _$isMapReadyAtom.reportWrite(value, super.isMapReady, () {
      super.isMapReady = value;
    });
  }

  late final _$markersAtom =
      Atom(name: 'MapStoreBase.markers', context: context);

  @override
  Set<Marker> get markers {
    _$markersAtom.reportRead();
    return super.markers;
  }

  @override
  set markers(Set<Marker> value) {
    _$markersAtom.reportWrite(value, super.markers, () {
      super.markers = value;
    });
  }

  late final _$polylinesAtom =
      Atom(name: 'MapStoreBase.polylines', context: context);

  @override
  Set<Polyline> get polylines {
    _$polylinesAtom.reportRead();
    return super.polylines;
  }

  @override
  set polylines(Set<Polyline> value) {
    _$polylinesAtom.reportWrite(value, super.polylines, () {
      super.polylines = value;
    });
  }

  late final _$mapCameraPositionAtom =
      Atom(name: 'MapStoreBase.mapCameraPosition', context: context);

  @override
  CameraPosition get mapCameraPosition {
    _$mapCameraPositionAtom.reportRead();
    return super.mapCameraPosition;
  }

  @override
  set mapCameraPosition(CameraPosition value) {
    _$mapCameraPositionAtom.reportWrite(value, super.mapCameraPosition, () {
      super.mapCameraPosition = value;
    });
  }

  late final _$pricesAtom = Atom(name: 'MapStoreBase.prices', context: context);

  @override
  ObservableMap<String, Price> get prices {
    _$pricesAtom.reportRead();
    return super.prices;
  }

  @override
  set prices(ObservableMap<String, Price> value) {
    _$pricesAtom.reportWrite(value, super.prices, () {
      super.prices = value;
    });
  }

  late final _$selectedPriceAtom =
      Atom(name: 'MapStoreBase.selectedPrice', context: context);

  @override
  Price? get selectedPrice {
    _$selectedPriceAtom.reportRead();
    return super.selectedPrice;
  }

  @override
  set selectedPrice(Price? value) {
    _$selectedPriceAtom.reportWrite(value, super.selectedPrice, () {
      super.selectedPrice = value;
    });
  }

  late final _$isLoadingChatMessageAtom =
      Atom(name: 'MapStoreBase.isLoadingChatMessage', context: context);

  @override
  bool get isLoadingChatMessage {
    _$isLoadingChatMessageAtom.reportRead();
    return super.isLoadingChatMessage;
  }

  @override
  set isLoadingChatMessage(bool value) {
    _$isLoadingChatMessageAtom.reportWrite(value, super.isLoadingChatMessage,
        () {
      super.isLoadingChatMessage = value;
    });
  }

  late final _$chatMessagesAtom =
      Atom(name: 'MapStoreBase.chatMessages', context: context);

  @override
  List<RideMessage> get chatMessages {
    _$chatMessagesAtom.reportRead();
    return super.chatMessages;
  }

  @override
  set chatMessages(List<RideMessage> value) {
    _$chatMessagesAtom.reportWrite(value, super.chatMessages, () {
      super.chatMessages = value;
    });
  }

  late final _$isTrackingLocationAtom =
      Atom(name: 'MapStoreBase.isTrackingLocation', context: context);

  @override
  bool get isTrackingLocation {
    _$isTrackingLocationAtom.reportRead();
    return super.isTrackingLocation;
  }

  @override
  set isTrackingLocation(bool value) {
    _$isTrackingLocationAtom.reportWrite(value, super.isTrackingLocation, () {
      super.isTrackingLocation = value;
    });
  }

  late final _$isTypingAtom =
      Atom(name: 'MapStoreBase.isTyping', context: context);

  @override
  bool get isTyping {
    _$isTypingAtom.reportRead();
    return super.isTyping;
  }

  @override
  set isTyping(bool value) {
    _$isTypingAtom.reportWrite(value, super.isTyping, () {
      super.isTyping = value;
    });
  }

  late final _$userLocationAtom =
      Atom(name: 'MapStoreBase.userLocation', context: context);

  @override
  LatLng? get userLocation {
    _$userLocationAtom.reportRead();
    return super.userLocation;
  }

  @override
  set userLocation(LatLng? value) {
    _$userLocationAtom.reportWrite(value, super.userLocation, () {
      super.userLocation = value;
    });
  }

  late final _$userBearingAtom =
      Atom(name: 'MapStoreBase.userBearing', context: context);

  @override
  double get userBearing {
    _$userBearingAtom.reportRead();
    return super.userBearing;
  }

  @override
  set userBearing(double value) {
    _$userBearingAtom.reportWrite(value, super.userBearing, () {
      super.userBearing = value;
    });
  }

  late final _$_followUserAtom =
      Atom(name: 'MapStoreBase._followUser', context: context);

  @override
  bool get _followUser {
    _$_followUserAtom.reportRead();
    return super._followUser;
  }

  @override
  set _followUser(bool value) {
    _$_followUserAtom.reportWrite(value, super._followUser, () {
      super._followUser = value;
    });
  }

  late final _$destinationLocationAtom =
      Atom(name: 'MapStoreBase.destinationLocation', context: context);

  @override
  LatLng? get destinationLocation {
    _$destinationLocationAtom.reportRead();
    return super.destinationLocation;
  }

  @override
  set destinationLocation(LatLng? value) {
    _$destinationLocationAtom.reportWrite(value, super.destinationLocation, () {
      super.destinationLocation = value;
    });
  }

  late final _$isNavigatingAtom =
      Atom(name: 'MapStoreBase.isNavigating', context: context);

  @override
  bool get isNavigating {
    _$isNavigatingAtom.reportRead();
    return super.isNavigating;
  }

  @override
  set isNavigating(bool value) {
    _$isNavigatingAtom.reportWrite(value, super.isNavigating, () {
      super.isNavigating = value;
    });
  }

  late final _$isDropLocationArrivedAtom =
      Atom(name: 'MapStoreBase.isDropLocationArrived', context: context);

  @override
  bool get isDropLocationArrived {
    _$isDropLocationArrivedAtom.reportRead();
    return super.isDropLocationArrived;
  }

  @override
  set isDropLocationArrived(bool value) {
    _$isDropLocationArrivedAtom.reportWrite(value, super.isDropLocationArrived,
        () {
      super.isDropLocationArrived = value;
    });
  }

  late final _$lastPositionAtom =
      Atom(name: 'MapStoreBase.lastPosition', context: context);

  @override
  Position? get lastPosition {
    _$lastPositionAtom.reportRead();
    return super.lastPosition;
  }

  @override
  set lastPosition(Position? value) {
    _$lastPositionAtom.reportWrite(value, super.lastPosition, () {
      super.lastPosition = value;
    });
  }

  late final _$isApplyingPromoCodeAtom =
      Atom(name: 'MapStoreBase.isApplyingPromoCode', context: context);

  @override
  bool get isApplyingPromoCode {
    _$isApplyingPromoCodeAtom.reportRead();
    return super.isApplyingPromoCode;
  }

  @override
  set isApplyingPromoCode(bool value) {
    _$isApplyingPromoCodeAtom.reportWrite(value, super.isApplyingPromoCode, () {
      super.isApplyingPromoCode = value;
    });
  }

  late final _$isCancellingRideAtom =
      Atom(name: 'MapStoreBase.isCancellingRide', context: context);

  @override
  bool get isCancellingRide {
    _$isCancellingRideAtom.reportRead();
    return super.isCancellingRide;
  }

  @override
  set isCancellingRide(bool value) {
    _$isCancellingRideAtom.reportWrite(value, super.isCancellingRide, () {
      super.isCancellingRide = value;
    });
  }

  late final _$rideHistoryAtom =
      Atom(name: 'MapStoreBase.rideHistory', context: context);

  @override
  List<Ride> get rideHistory {
    _$rideHistoryAtom.reportRead();
    return super.rideHistory;
  }

  @override
  set rideHistory(List<Ride> value) {
    _$rideHistoryAtom.reportWrite(value, super.rideHistory, () {
      super.rideHistory = value;
    });
  }

  late final _$isRideHistoryLoadingAtom =
      Atom(name: 'MapStoreBase.isRideHistoryLoading', context: context);

  @override
  bool get isRideHistoryLoading {
    _$isRideHistoryLoadingAtom.reportRead();
    return super.isRideHistoryLoading;
  }

  @override
  set isRideHistoryLoading(bool value) {
    _$isRideHistoryLoadingAtom.reportWrite(value, super.isRideHistoryLoading,
        () {
      super.isRideHistoryLoading = value;
    });
  }

  @override
  ObservableFuture<void> loadChatMessage({required String rideId}) {
    final _$future = super.loadChatMessage(rideId: rideId);
    return ObservableFuture<void>(_$future, context: context);
  }

  late final _$getPricesAsyncAction =
      AsyncAction('MapStoreBase.getPrices', context: context);

  @override
  Future<void> getPrices() {
    return _$getPricesAsyncAction.run(() => super.getPrices());
  }

  late final _$moveToCurrentLocationAsyncAction =
      AsyncAction('MapStoreBase.moveToCurrentLocation', context: context);

  @override
  Future<void> moveToCurrentLocation() {
    return _$moveToCurrentLocationAsyncAction
        .run(() => super.moveToCurrentLocation());
  }

  late final _$sendMessageAsyncAction =
      AsyncAction('MapStoreBase.sendMessage', context: context);

  @override
  Future<void> sendMessage({required String rideId, required String message}) {
    return _$sendMessageAsyncAction
        .run(() => super.sendMessage(rideId: rideId, message: message));
  }

  late final _$joinChatRoomAsyncAction =
      AsyncAction('MapStoreBase.joinChatRoom', context: context);

  @override
  Future<void> joinChatRoom({required String rideId}) {
    return _$joinChatRoomAsyncAction
        .run(() => super.joinChatRoom(rideId: rideId));
  }

  late final _$leaveChatRoomAsyncAction =
      AsyncAction('MapStoreBase.leaveChatRoom', context: context);

  @override
  Future<void> leaveChatRoom({required String rideId}) {
    return _$leaveChatRoomAsyncAction
        .run(() => super.leaveChatRoom(rideId: rideId));
  }

  late final _$sendTypingNotificationAsyncAction =
      AsyncAction('MapStoreBase.sendTypingNotification', context: context);

  @override
  Future<void> sendTypingNotification(
      {required String rideId, required bool isTyping}) {
    return _$sendTypingNotificationAsyncAction.run(
        () => super.sendTypingNotification(rideId: rideId, isTyping: isTyping));
  }

  late final _$initializeMapAsyncAction =
      AsyncAction('MapStoreBase.initializeMap', context: context);

  @override
  Future<void> initializeMap() {
    return _$initializeMapAsyncAction.run(() => super.initializeMap());
  }

  late final _$createAssetMarkerAsyncAction =
      AsyncAction('MapStoreBase.createAssetMarker', context: context);

  @override
  Future<BitmapDescriptor> createAssetMarker(String assetPath,
      {double width = 100, double height = 100}) {
    return _$createAssetMarkerAsyncAction.run(
        () => super.createAssetMarker(assetPath, width: width, height: height));
  }

  late final _$initializeAsyncAction =
      AsyncAction('MapStoreBase.initialize', context: context);

  @override
  Future<void> initialize() {
    return _$initializeAsyncAction.run(() => super.initialize());
  }

  late final _$startNavigationAsyncAction =
      AsyncAction('MapStoreBase.startNavigation', context: context);

  @override
  Future<void> startNavigation(LatLng pickupPoint, LatLng destinationPoint) {
    return _$startNavigationAsyncAction
        .run(() => super.startNavigation(pickupPoint, destinationPoint));
  }

  late final _$_getDistanceBetweenAsyncAction =
      AsyncAction('MapStoreBase._getDistanceBetween', context: context);

  @override
  Future<double> _getDistanceBetween(
      {required double startLatitude, required double startLongitude}) {
    return _$_getDistanceBetweenAsyncAction.run(() => super._getDistanceBetween(
        startLatitude: startLatitude, startLongitude: startLongitude));
  }

  late final _$initializeLocationAsyncAction =
      AsyncAction('MapStoreBase.initializeLocation', context: context);

  @override
  Future<void> initializeLocation() {
    return _$initializeLocationAsyncAction
        .run(() => super.initializeLocation());
  }

  late final _$createPolylinesAsyncAction =
      AsyncAction('MapStoreBase.createPolylines', context: context);

  @override
  Future<void> createPolylines(
      {required List<LatLng> points,
      Color color = const Color(0xFFFF9100),
      int width = 5,
      String polylineId = 'route_polyline',
      bool fitBounds = true,
      int padding = 50}) {
    return _$createPolylinesAsyncAction.run(() => super.createPolylines(
        points: points,
        color: color,
        width: width,
        polylineId: polylineId,
        fitBounds: fitBounds,
        padding: padding));
  }

  late final _$searchPlaceAsyncAction =
      AsyncAction('MapStoreBase.searchPlace', context: context);

  @override
  Future<void> searchPlace(String searchText) {
    return _$searchPlaceAsyncAction.run(() => super.searchPlace(searchText));
  }

  late final _$getDirectionAsyncAction =
      AsyncAction('MapStoreBase.getDirection', context: context);

  @override
  Future<void> getDirection(
      String lat1, String long1, String lat2, String long2) {
    return _$getDirectionAsyncAction
        .run(() => super.getDirection(lat1, long1, lat2, long2));
  }

  late final _$findNearbyDriversAsyncAction =
      AsyncAction('MapStoreBase.findNearbyDrivers', context: context);

  @override
  Future<void> findNearbyDrivers() {
    return _$findNearbyDriversAsyncAction.run(() => super.findNearbyDrivers());
  }

  late final _$startLocationTrackingAsyncAction =
      AsyncAction('MapStoreBase.startLocationTracking', context: context);

  @override
  Future<void> startLocationTracking() {
    return _$startLocationTrackingAsyncAction
        .run(() => super.startLocationTracking());
  }

  late final _$submitFeedbackAsyncAction =
      AsyncAction('MapStoreBase.submitFeedback', context: context);

  @override
  Future<void> submitFeedback(
      {required String rideId, required String feedback, required int rating}) {
    return _$submitFeedbackAsyncAction.run(() => super
        .submitFeedback(rideId: rideId, feedback: feedback, rating: rating));
  }

  late final _$createRideRequestAsyncAction =
      AsyncAction('MapStoreBase.createRideRequest', context: context);

  @override
  Future<void> createRideRequest(PaymentMethod paymentMethod) {
    return _$createRideRequestAsyncAction
        .run(() => super.createRideRequest(paymentMethod));
  }

  late final _$addPromoCodeAsyncAction =
      AsyncAction('MapStoreBase.addPromoCode', context: context);

  @override
  Future<Bonuses?> addPromoCode(String code, num baseAmount) {
    return _$addPromoCodeAsyncAction
        .run(() => super.addPromoCode(code, baseAmount));
  }

  late final _$cancelRideAsyncAction =
      AsyncAction('MapStoreBase.cancelRide', context: context);

  @override
  Future<void> cancelRide(String reason) {
    return _$cancelRideAsyncAction.run(() => super.cancelRide(reason));
  }

  late final _$updateDriverMarkersAsyncAction =
      AsyncAction('MapStoreBase.updateDriverMarkers', context: context);

  @override
  Future<void> updateDriverMarkers() {
    return _$updateDriverMarkersAsyncAction
        .run(() => super.updateDriverMarkers());
  }

  late final _$getAllRideAsyncAction =
      AsyncAction('MapStoreBase.getAllRide', context: context);

  @override
  Future<void> getAllRide() {
    return _$getAllRideAsyncAction.run(() => super.getAllRide());
  }

  late final _$getCurrentRideAsyncAction =
      AsyncAction('MapStoreBase.getCurrentRide', context: context);

  @override
  Future<void> getCurrentRide() {
    return _$getCurrentRideAsyncAction.run(() => super.getCurrentRide());
  }

  late final _$MapStoreBaseActionController =
      ActionController(name: 'MapStoreBase', context: context);

  @override
  void setSelectedPrice(Price? price) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.setSelectedPrice');
    try {
      return super.setSelectedPrice(price);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPrices(List<Price> prices) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.setPrices');
    try {
      return super.setPrices(prices);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPrice(Price price) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.setPrice');
    try {
      return super.setPrice(price);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removePrice(String id) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.removePrice');
    try {
      return super.removePrice(id);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearPrices() {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.clearPrices');
    try {
      return super.clearPrices();
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updatePrice(Price price) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.updatePrice');
    try {
      return super.updatePrice(price);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setIsMapReady(bool value) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.setIsMapReady');
    try {
      return super.setIsMapReady(value);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void cancelDropStream() {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.cancelDropStream');
    try {
      return super.cancelDropStream();
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void _processDirectionCoordinates(DirectionResponse directionResponse) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase._processDirectionCoordinates');
    try {
      return super._processDirectionCoordinates(directionResponse);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void stopLocationTracking() {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.stopLocationTracking');
    try {
      return super.stopLocationTracking();
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSearchPlacesModel(SearchPlace? searchResponse) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.setSearchPlacesModel');
    try {
      return super.setSearchPlacesModel(searchResponse);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setDirectionModel(DirectionResponse? direction) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.setDirectionModel');
    try {
      return super.setDirectionModel(direction);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setCurrentController(bool value) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.setCurrentController');
    try {
      return super.setCurrentController(value);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addCoordinate(LatLng coordinate) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.addCoordinate');
    try {
      return super.addCoordinate(coordinate);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearCoordinates() {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.clearCoordinates');
    try {
      return super.clearCoordinates();
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  double getKilometer(double value) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.getKilometer');
    try {
      return super.getKilometer(value);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsLoginLoading(bool isLoading) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.setIsLoginLoading');
    try {
      return super.setIsLoginLoading(isLoading);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setIsDirectionLoading(bool isLoading) {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.setIsDirectionLoading');
    try {
      return super.setIsDirectionLoading(isLoading);
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearErrors() {
    final _$actionInfo = _$MapStoreBaseActionController.startAction(
        name: 'MapStoreBase.clearErrors');
    try {
      return super.clearErrors();
    } finally {
      _$MapStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoginLoading: ${isLoginLoading},
isDirectionLoading: ${isDirectionLoading},
coordinatesList: ${coordinatesList},
tempCoordinatesList: ${tempCoordinatesList},
isCurrentController: ${isCurrentController},
searchPlaceModel: ${searchPlaceModel},
directions: ${directions},
mapStyleString: ${mapStyleString},
selectedSuggestionsFrom: ${selectedSuggestionsFrom},
selectedSuggestionsTo: ${selectedSuggestionsTo},
currentLocationController: ${currentLocationController},
designationController: ${designationController},
nearbyDrivers: ${nearbyDrivers},
isCreatingRide: ${isCreatingRide},
isRideAccepted: ${isRideAccepted},
error: ${error},
isConnected: ${isConnected},
currentRide: ${currentRide},
googleMapController: ${googleMapController},
isMapReady: ${isMapReady},
markers: ${markers},
polylines: ${polylines},
mapCameraPosition: ${mapCameraPosition},
prices: ${prices},
selectedPrice: ${selectedPrice},
isLoadingChatMessage: ${isLoadingChatMessage},
chatMessages: ${chatMessages},
isTrackingLocation: ${isTrackingLocation},
isTyping: ${isTyping},
userLocation: ${userLocation},
userBearing: ${userBearing},
destinationLocation: ${destinationLocation},
isNavigating: ${isNavigating},
isDropLocationArrived: ${isDropLocationArrived},
lastPosition: ${lastPosition},
isApplyingPromoCode: ${isApplyingPromoCode},
isCancellingRide: ${isCancellingRide},
rideHistory: ${rideHistory},
isRideHistoryLoading: ${isRideHistoryLoading},
pricesList: ${pricesList},
hasValidLocations: ${hasValidLocations},
isSearching: ${isSearching}
    ''';
  }
}
