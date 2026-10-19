// ignore_for_file: unused_import

import 'dart:math' as math;
import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:ridzs_passenger_app/core/configs/app_routes.dart';
// import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/core/services/navigation_service.dart';
import 'package:ridzs_passenger_app/models/chat/chat_message_model.dart';
import 'package:ridzs_passenger_app/models/promocode/all_promocode_response_model.dart';
import 'package:ridzs_passenger_app/models/response/maps/direction_response.dart';
import 'package:ridzs_passenger_app/models/response/maps/search_place.dart';
import 'package:ridzs_passenger_app/models/response/price_response.dart';
import 'package:ridzs_passenger_app/services/maps_service.dart';
import 'package:ridzs_passenger_app/services/ride_service.dart';
import '../../core/constants/assets.dart';
import '../../core/enums/ride.dart';
import '../../core/services/dio_service.dart';
import '../../core/services/socket_service.dart';
import '../../core/services/ride_update_policy.dart';
import '../../core/services/ride_recovery.dart';
import '../../services/booking_attempt.dart';
import '../../services/booking_quote_service.dart';
import '../../models/ride/booking_quote.dart';
import '../../core/configs/app_config.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/toast_service.dart';
import '../../models/common/location/driver_location.dart';
import '../../models/common/ride_response/ride_response.dart';
import '../../models/ride/get_ride_response.dart' hide Payment;

import '../../services/ride_chat_service.dart';
import '../../services/ride_rating_service.dart';
import '../../services/ride_emergency_service.dart';

part 'map_store.g.dart';

class MapStore = MapStoreBase with _$MapStore;

MapStore mapStoreProvider({bool listen = false}) {
  return Provider.of(NavigationService.navigatorKey.currentContext!,
      listen: listen);
}

abstract class MapStoreBase with Store {
  MapStoreBase(
      {RideService? rideService,
      void Function(String)? rideNotice,
      Dio? recoveryDio,
      SocketService? socketService,
      RideChatService? chatService,
      RideRatingService? ratingService,
      bool? bookingQuotesEnabled,
      Future<String?> Function()? sessionTokenReader})
      : _rideService = rideService ?? RideService(),
        _rideNotice = rideNotice ?? ToastService.show,
        _recoveryDio = recoveryDio,
        _socketService = socketService ?? SocketService(),
        _providedChat = chatService,
        _providedRatings = ratingService,
        _sessionTokenReader = sessionTokenReader,
        quoteBookingsEnabled =
            bookingQuotesEnabled ?? AppConfig.bookingQuotesEnabled;

  final bool quoteBookingsEnabled;
  Object? _quoteSessionIdentity;
  String? _quoteToken;
  final _quoteSessions = <BookingQuoteService>{};

  Future<BookingQuoteService> createQuoteSession() async {
    if (!quoteBookingsEnabled) throw StateError('Quoted booking is disabled');
    final generation = _sessionGeneration;
    final token =
        await (_sessionTokenReader ?? PreferencesService.getAccessToken)();
    if (generation != _sessionGeneration || token == null || token.isEmpty) {
      throw StateError('Sign in required');
    }
    await booking.restore();
    if (generation != _sessionGeneration ||
        booking.pending.value ||
        booking.busy.value ||
        currentRide != null) {
      throw StateError(
          'Resolve the current booking before requesting another fare');
    }
    if (_quoteToken != token) {
      for (final session in _quoteSessions) {
        session.dispose();
      }
      _quoteSessions.clear();
      _quoteSessionIdentity = Object();
      _quoteToken = token;
    }
    final service = BookingQuoteService(
        dio: _recoveryDio ?? Api().dio,
        expectedAuthToken: token,
        sessionReader: () => _quoteSessionIdentity);
    _quoteSessions.add(service);
    return service;
  }

  void endQuoteSession(BookingQuoteService service) {
    _quoteSessions.remove(service);
    service.dispose();
  }

  Map<String, dynamic> quoteRequest() {
    if (!hasValidLocations || selectedPrice == null) {
      throw StateError('Select your trip');
    }
    return BookingQuote.canonicalRequest({
      'vehicleType': selectedPrice!.vehicleType.name,
      'pickup': {
        'latitude': selectedSuggestionsFrom!.properties!.coordinates!.latitude!,
        'longitude':
            selectedSuggestionsFrom!.properties!.coordinates!.longitude!,
        'address': currentLocationController.text,
      },
      'destination': {
        'latitude': selectedSuggestionsTo!.properties!.coordinates!.latitude!,
        'longitude': selectedSuggestionsTo!.properties!.coordinates!.longitude!,
        'address': designationController.text,
      },
    });
  }

  final RideRatingService? _providedRatings;
  late final RideRatingService ratings = _providedRatings ??
      RideRatingService(role: 'passenger', dio: _recoveryDio);
  final _feedbackBusy = Observable(false);
  final _safetySessions = <RideEmergencyService>{};

  RideEmergencyService createSafetySession() {
    late final RideEmergencyService service;
    service = RideEmergencyService(
        role: 'passenger',
        dio: _recoveryDio,
        tokenReader: _sessionTokenReader,
        onEnd: () => _safetySessions.remove(service));
    _safetySessions.add(service);
    return service;
  }

  final RideChatService? _providedChat;
  late final RideChatService chat = _providedChat ??
      RideChatService(
          role: 'passenger',
          dio: _recoveryDio,
          tokenReader: _sessionTokenReader);
  Timer? _typingExpiry;
  int _chatRead = 0;

  void clearTyping() {
    _typingExpiry?.cancel();
    _typingExpiry = null;
    isTyping = false;
  }

  void receiveTyping(Map<String, dynamic> data) {
    if (currentRide?.ride?.sId != data['rideId'] ||
        !const {RideStatus.accepted, RideStatus.arrived, RideStatus.started}
            .contains(currentRide?.ride?.status) ||
        (data['user'] ?? data['by']) != 'driver') {
      return;
    }
    clearTyping();
    if ((data['isTyping'] ?? data['typing']) == true) {
      isTyping = true;
      final generation = _sessionGeneration;
      _typingExpiry = Timer(const Duration(seconds: 4), () {
        if (generation == _sessionGeneration) isTyping = false;
      });
    }
  }

  void receiveChatMessage(RideMessage message) {
    if (currentRide?.ride?.sId != message.rideId) return;
    chatMessages =
        RideMessage.mergeHistory(chatMessages, [message], message.rideId);
    if (message.sender == 'driver') clearTyping();
  }

  void startChatRecovery(String rideId, {bool Function()? canRead}) {
    final generation = _sessionGeneration;
    chat.startRecovery(rideId, (messages) {
      if (generation != _sessionGeneration ||
          currentRide?.ride?.sId != rideId) {
        return;
      }
      runInAction(() => chatMessages =
          RideMessage.mergeHistory(chatMessages, messages, rideId));
    }, canRead: canRead);
  }

  final Dio? _recoveryDio;
  final Future<String?> Function()? _sessionTokenReader;
  bool _sessionStarted = false;
  int _sessionGeneration = 0;
  late final BookingAttempt booking =
      BookingAttempt(service: _rideService, tokenReader: _sessionTokenReader);
  final searchBusy = Observable(false);
  bool get bookingConfirmationPending {
    final ride = currentRide?.ride;
    if (ride?.status != RideStatus.requested &&
        ride?.status != RideStatus.searching) {
      return false;
    }
    return !{'authorized', 'held'}.contains(ride?.payment?.status);
  }

  bool get noDriversFound =>
      isCreatingRide &&
      !bookingConfirmationPending &&
      currentRide?.ride?.dispatch?['state'] == 'exhausted';
  late final RideRecovery recovery = RideRecovery(
    dio: _recoveryDio,
    tokenReader: _sessionTokenReader,
    currentRideId: () => currentRide?.ride?.sId,
    restore: _restoreRecoveredRide,
    canReconcile: () => !booking.busy.value && !isCancellingRide,
  );

  Future<void> _restoreRecoveredRide(Map<String, dynamic>? snapshot) async {
    final generation = _sessionGeneration;
    await booking.restore();
    if (generation != _sessionGeneration) return;
    if (snapshot == null) {
      if (recovery.reconciling && currentRide == null) return;
      _clearRideState();
      return;
    }
    final incoming = RideRequest.fromJson(snapshot);
    final samePhase = currentRide?.ride?.sId == incoming.ride?.sId &&
        currentRide?.ride?.status == incoming.ride?.status;
    if (currentRide?.ride?.sId != incoming.ride?.sId) _clearRideState();
    applyRideUpdate(incoming, allowNewRide: true, fromRecovery: true);
    if (recovery.reconciling && samePhase) return;
    await resumeRideResources();
  }

  Future<void> resumeRideResources() async {
    final ride = currentRide?.ride;
    if (ride == null ||
        ride.status == RideStatus.completed ||
        ride.status == RideStatus.cancelled) {
      return;
    }
    final epoch = _rideVisualEpoch;
    if (ride.status == RideStatus.accepted ||
        ride.status == RideStatus.arrived ||
        ride.status == RideStatus.started) {
      await _socketService.joinChatRoom(ride.sId!);
      if (epoch != _rideVisualEpoch) return;
      await loadChatMessage(rideId: ride.sId!);
      if (epoch != _rideVisualEpoch) return;
    }
    final pickup = ride.pickup;
    final destination = ride.destination;
    if (pickup?.latitude == null ||
        pickup?.longitude == null ||
        destination?.latitude == null ||
        destination?.longitude == null) {
      return;
    }
    final from = LatLng(pickup!.latitude!, pickup.longitude!);
    final to = LatLng(destination!.latitude!, destination.longitude!);
    if (ride.status == RideStatus.started) {
      await startNavigation(from, to);
    } else {
      await _calculateRoute(from, to);
      if (epoch != _rideVisualEpoch) return;
      await _addPickupMarker(from);
      if (epoch != _rideVisualEpoch) return;
      await _addDestinationMarker(to);
    }
  }

  void _clearRideState() => runInAction(() {
        ratings.reset();
        _feedbackBusy.value = false;
        _chatRead++;
        chat.reset();
        final previousId = currentRide?.ride?.sId;
        if (previousId != null) {
          unawaited(_socketService
              .leaveChatRoom(previousId)
              .catchError((Object _) {}));
        }
        _rideVisualEpoch++;
        _stopNavigation();
        _dropStreamSubscription?.cancel();
        _dropStreamSubscription = null;
        currentRide = null;
        isCreatingRide = false;
        isRideAccepted = false;
        isCancellingRide = false;
        chatMessages = [];
        clearTyping();
        isLoadingChatMessage = false;
        markers = {};
        polylines = {};
        nearbyDrivers.clear();
      });

  Future<void> onResume() async {
    if (!_sessionStarted) return;
    _socketService.reconnect();
    await recovery.refresh();
  }

  Future<void> endSession() async {
    final cleared = recovery.forget();
    dispose();
    await cleared;
  }

  final SocketService _socketService;
  final RideService _rideService;
  final void Function(String) _rideNotice;
  final MapService _mapService = MapService();
  final Set<String> _closedRideIds = {};
  int _rideVisualEpoch = 0;

  bool applyRideUpdate(RideRequest incoming,
          {bool allowNewRide = false, bool fromRecovery = false}) =>
      runInAction(() {
        final previous = currentRide;
        final ride = incoming.ride;

        // Profile/contact refreshes can change independently of the ride revision.
        if (fromRecovery &&
            currentRide != null &&
            ride != null &&
            ride.sId != null &&
            ride.sId == previous?.ride?.sId &&
            ride.version != null &&
            ride.version == previous?.ride?.version &&
            ride.status == previous?.ride?.status &&
            ride.driverId == previous?.ride?.driverId &&
            !_closedRideIds.contains(ride.sId)) {
          incoming.mergeDisplayFrom(previous);
          incoming.ride = previous!.ride;
          currentRide = incoming;
          return true;
        }
        if (ride == null ||
            _closedRideIds.contains(ride.sId) ||
            !acceptsRideUpdate(
              expectedId:
                  previous?.ride?.sId ?? (allowNewRide ? ride.sId : null),
              incomingId: ride.sId,
              currentStatus: previous?.ride?.status?.title,
              incomingStatus: ride.status?.title,
              currentVersion: previous?.ride?.version,
              incomingVersion: ride.version,
            )) {
          return false;
        }
        final oldStatus = previous?.ride?.status;
        if (ride.status == RideStatus.completed ||
            ride.status == RideStatus.cancelled) {
          _chatRead++;
          chat.reset();
          clearTyping();
          isLoadingChatMessage = false;
        }
        if (_sessionStarted && !fromRecovery) {
          recovery.changed();
          recovery
              .remember(ride.status == RideStatus.cancelled ? null : ride.sId);
        }
        _rideVisualEpoch++;
        error = null;
        if (ride.status == RideStatus.cancelled) {
          _closedRideIds.add(ride.sId!);
          currentRide = null;
          isCreatingRide = false;
          isRideAccepted = false;
          isCancellingRide = false;
          _stopNavigation();
          _dropStreamSubscription?.cancel();
          _dropStreamSubscription = null;
          markers = {};
          polylines = {};
          nearbyDrivers.clear();
          chatMessages = [];
          clearTyping();
          unawaited(_socketService
              .leaveChatRoom(ride.sId!)
              .catchError((Object _) {}));
          _rideNotice(ride.payment?.status == 'rejected'
              ? 'Booking was not placed. Review your payment method.'
              : 'Ride cancelled. You can book another ride.');
          return true;
        }
        incoming.mergeDisplayFrom(previous);
        currentRide = incoming;
        isCreatingRide = ride.status == RideStatus.requested ||
            ride.status == RideStatus.searching;
        isRideAccepted = !isCreatingRide;
        if (ride.status == RideStatus.completed) {
          _stopNavigation();
          _dropStreamSubscription?.cancel();
          _dropStreamSubscription = null;
          polylines = {};
          markers = {};
          if (oldStatus != RideStatus.completed) {
            _rideNotice(_paymentCompletionMessage(ride.payment));
          }
        }
        return true;
      });

  Future<void> _handleRideUpdate(RideRequest response) async {
    if (currentRide == null && (booking.pending.value || booking.busy.value)) {
      await recovery.refresh();
      return;
    }
    final oldStatus = currentRide?.ride?.status;
    if (!applyRideUpdate(response)) return;
    final ride = currentRide?.ride;
    if (ride == null || oldStatus == ride.status) return;
    final pickup = ride.pickup;
    final destination = ride.destination;
    if (pickup?.latitude == null ||
        pickup?.longitude == null ||
        destination?.latitude == null ||
        destination?.longitude == null) {
      return;
    }
    final from = LatLng(pickup!.latitude!, pickup.longitude!);
    final to = LatLng(destination!.latitude!, destination.longitude!);
    final epoch = _rideVisualEpoch;
    if (ride.status == RideStatus.accepted) {
      nearbyDrivers.clear();
      await _calculateRoute(from, to);
      if (epoch != _rideVisualEpoch) return;
      await _addPickupMarker(from);
      if (epoch != _rideVisualEpoch) return;
      await _addDestinationMarker(to);
    } else if (ride.status == RideStatus.started) {
      await startNavigation(from, to);
    }
  }

  @observable
  bool isLoginLoading = false;

  @observable
  bool isDirectionLoading = false;

  @observable
  ObservableList<LatLng> coordinatesList = ObservableList<LatLng>();

  @observable
  ObservableList<LatLng> tempCoordinatesList = ObservableList<LatLng>();

  @observable
  bool isCurrentController = true;

  @observable
  SearchPlace? searchPlaceModel;

  @observable
  DirectionResponse? directions;

  @observable
  String mapStyleString = '';

  @observable
  Features? selectedSuggestionsFrom;

  @observable
  Features? selectedSuggestionsTo;

  @observable
  TextEditingController currentLocationController = TextEditingController();

  @observable
  TextEditingController designationController = TextEditingController();

  @observable
  ObservableMap<String, DriverLocation> nearbyDrivers =
      ObservableMap<String, DriverLocation>();

  @observable
  bool isCreatingRide = false;

  @observable
  bool isRideAccepted = false;

  @observable
  String? error;

  @observable
  bool isConnected = false;

  @observable
  RideRequest? currentRide;

  @observable
  GoogleMapController? googleMapController;

  @observable
  Observable<bool> isMapReady = Observable<bool>(false);

  @observable
  Set<Marker> markers = {};

  @observable
  Set<Polyline> polylines = {};

  @observable
  CameraPosition mapCameraPosition = const CameraPosition(
    target: LatLng(19.957860, 74.996357),
    zoom: 14.4746,
  );

  @observable
  ObservableMap<String, Price> prices = ObservableMap<String, Price>();

  @observable
  Price? selectedPrice;

  @action
  void setSelectedPrice(Price? price) => selectedPrice = price;

  @computed
  List<Price> get pricesList => prices.values.toList();

  @action
  void setPrices(List<Price> prices) {
    for (var price in prices) {
      this.prices[price.id] = price;
    }
  }

  @action
  void setPrice(Price price) {
    prices[price.id] = price;
  }

  @action
  void removePrice(String id) {
    prices.remove(id);
  }

  @action
  void clearPrices() {
    prices.clear();
  }

  @action
  void updatePrice(Price price) {
    if (prices.containsKey(price.id)) {
      prices[price.id] = price;
    }
  }

  @action
  Future<void> getPrices() async {
    try {
      final response = await _rideService.getPrices();
      setPrices(response.pricing);
      if (response.pricing.isNotEmpty) {
        selectedPrice = response.pricing.first;
      }
    } catch (e) {
      debugPrint('Error getting prices: $e');
    }
  }

  @action
  Future<void> moveToCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ToastService.show('Allow location permission in settings');
          debugPrint('Location permission denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ToastService.show('Allow location permission in settings');
        debugPrint('Location permission permanently denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      await googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @observable
  bool isLoadingChatMessage = false;

  Future<void> loadChatMessage(
      {required String rideId, bool older = false}) async {
    if (currentRide?.ride?.sId != rideId) return;
    final generation = _sessionGeneration;
    final read = ++_chatRead;
    isLoadingChatMessage = true;
    runInAction(() => chat.historyError.value = null);
    try {
      final messages = await chat.history(rideId, older: older);
      if (generation != _sessionGeneration ||
          read != _chatRead ||
          currentRide?.ride?.sId != rideId) {
        return;
      }
      // Refreshed source text must replace cached text after a privacy correction.
      chatMessages = RideMessage.mergeHistory(chatMessages, messages, rideId);
    } catch (failure) {
      if (generation == _sessionGeneration &&
          read == _chatRead &&
          currentRide?.ride?.sId == rideId) {
        runInAction(() => chat.historyError.value = failure is FormatException
            ? failure.message
            : 'Chat history could not be loaded.');
      }
    } finally {
      if (generation == _sessionGeneration &&
          read == _chatRead &&
          currentRide?.ride?.sId == rideId) {
        isLoadingChatMessage = false;
      }
    }
  }

  Future<bool> sendMessage({
    required String rideId,
    required String message,
  }) async {
    if (currentRide?.ride?.sId != rideId) return false;
    final generation = _sessionGeneration;
    final confirmed = await chat.send(rideId, message);
    if (generation != _sessionGeneration ||
        currentRide?.ride?.sId != rideId ||
        confirmed == null) {
      return false;
    }
    receiveChatMessage(confirmed);
    await sendTypingNotification(rideId: rideId, isTyping: false);
    return generation == _sessionGeneration && currentRide?.ride?.sId == rideId;
  }

  @action
  Future<void> joinChatRoom({required String rideId}) async {
    try {
      await _socketService.joinChatRoom(rideId);
    } catch (e) {
      log('Error joining chat room: ${e.toString()}');
      ToastService.show('Error joining chat room');
    }
  }

  @action
  Future<void> leaveChatRoom({required String rideId}) async {
    if (currentRide?.ride?.sId == rideId) clearTyping();
    try {
      await _socketService.leaveChatRoom(rideId);
    } catch (e) {
      log('Error joining chat room: ${e.toString()}');
      ToastService.show('Error joining chat room');
    }
  }

  @action
  Future<void> sendTypingNotification({
    required String rideId,
    required bool isTyping,
  }) async {
    if (currentRide?.ride?.sId != rideId ||
        !chat.shouldSendTyping(rideId, isTyping)) {
      return;
    }
    try {
      await _socketService.sendTypingNotification(
        rideId: rideId,
        isTyping: isTyping,
      );
    } catch (e) {
      log('Error sending typing notification: ${e.toString()}');
      ToastService.show('Error sending typing notification');
    }
  }

  Timer? _nearbyDriversTimer;

  StreamSubscription<Position>? _locationSubscription;

  Position? _lastPosition;

  @observable
  List<RideMessage> chatMessages = [];

  @observable
  bool isTrackingLocation = false;

  final _locationUpdateThreshold = 50;
  final distanceThreshold = 500;

  @computed
  bool get hasValidLocations =>
      selectedSuggestionsFrom != null && selectedSuggestionsTo != null;

  @computed
  bool get isSearching => isLoginLoading || isDirectionLoading;

  @action
  setIsMapReady(bool value) => isMapReady.value = value;

  @action
  Future<void> initializeMap() async {
    try {
      // Get initial position
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        error = 'Location permissions are denied';
        mapCameraPosition = const CameraPosition(
          target: LatLng(19.957860, 74.996357),
          zoom: 14.4746,
        );
        return;
      }
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition();

      final initLat = position.latitude;
      final initLng = position.longitude;

      mapCameraPosition = CameraPosition(
        target: LatLng(initLat, initLng),
        zoom: 14.4746,
      );
    } catch (e) {
      error = 'Error initializing map: ${e.toString()}';
      mapCameraPosition = const CameraPosition(
        target: LatLng(19.957860, 74.996357),
        zoom: 14.4746,
      );
      debugPrint(error);
    }
  }

  Future<BitmapDescriptor> _getBitmapDescriptorFromIconData(
      IconData iconData, Color color, double size,
      {double? angle}) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = ui.Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    if (angle != null) {
      final centerX = size / 2;
      final centerY = size / 2;
      canvas.translate(centerX, centerY);
      canvas.rotate(angle);
      canvas.translate(-centerX, -centerY);
    }

    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: iconData.fontFamily,
        color: color,
      ),
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  @action
  Future<BitmapDescriptor> createAssetMarker(
    String assetPath, {
    double width = 100,
    double height = 100,
  }) async {
    try {
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      // Load the image from assets
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: width.toInt(),
        targetHeight: height.toInt(),
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Draw the image on canvas
      canvas.drawImage(image, Offset.zero, Paint());

      // Convert to bitmap descriptor
      final ui.Picture picture = pictureRecorder.endRecording();
      final ui.Image markerImage =
          await picture.toImage(width.toInt(), height.toInt());
      final ByteData? byteData =
          await markerImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List markerBytes = byteData!.buffer.asUint8List();

      return BitmapDescriptor.bytes(markerBytes);
    } catch (e) {
      debugPrint('Error creating asset marker: $e');
      // Fallback to default marker
      return BitmapDescriptor.defaultMarker;
    }
  }

  @action
  Future<void> initialize() async {
    if (_sessionStarted) {
      await recovery.refresh();
      return;
    }
    _sessionStarted = true;
    recovery.activate();
    try {
      initializeMap();
      await _socketService.initialize(
        onNearbyDrivers: (drivers) {
          nearbyDrivers.clear();
          for (var driver in drivers) {
            if (isRideAccepted) {
              // Only show the assigned driver when ride is accepted
              if (driver.driverId == currentRide?.ride?.driverId) {
                nearbyDrivers[driver.driverId] = driver;
              }
            } else {
              // Show all nearby drivers when no ride is accepted
              nearbyDrivers[driver.driverId] = driver;
            }
          }
          updateDriverMarkers();
        },
        onRideAccepted: _handleRideUpdate,
        onRideStatusUpdate: _handleRideUpdate,
        onRideSync: recovery.handleSyncHint,
        onBookingSync: recovery.handleBookingHint,
        onRideRejected: (response) {
          if (response.ride?.status == RideStatus.cancelled) {
            _handleRideUpdate(response);
          }
        },
        onRideArrived: _handleRideUpdate,
        onRideStarted: _handleRideUpdate,
        onRideCompleted: _handleRideUpdate,
        onDriverLocation: (driver) {
          if (!isRideAccepted ||
              driver.driverId != currentRide?.ride?.driverId) {
            return;
          }
          nearbyDrivers[driver.driverId] = driver;
          updateDriverMarkers();
        },
        onError: (message) => error = message,
        onConnected: () {
          if (!_sessionStarted) return;
          isConnected = true;
          error = null;
          unawaited(recovery.refresh());
          findNearbyDrivers();
        },
        onDisconnected: () {
          clearTyping();
          isConnected = false;
          nearbyDrivers.clear();
        },
        typingStatus: receiveTyping,
        onMessageReceived: receiveChatMessage,
      );
    } catch (e) {
      error = e.toString();
    }
    if (_sessionStarted) await recovery.refresh();
  }

  @observable
  bool isTyping = false;

  @observable
  LatLng? userLocation;

  @observable
  double userBearing = 0.0;

  Future<void> _addPickupMarker(LatLng point) async {
    final epoch = _rideVisualEpoch;
    final BitmapDescriptor icon = await _getBitmapDescriptorFromIconData(
      Icons.location_on,
      Colors.green,
      48,
    );

    if (epoch != _rideVisualEpoch) return;
    final marker = Marker(
      markerId: const MarkerId('pickup_location'),
      position: point,
      icon: icon,
    );

    markers = {...markers, marker};
  }

  Future<void> _addDestinationMarker(LatLng point) async {
    final epoch = _rideVisualEpoch;
    final BitmapDescriptor icon = await _getBitmapDescriptorFromIconData(
      Icons.place,
      Colors.red,
      48,
    );

    if (epoch != _rideVisualEpoch) return;
    final marker = Marker(
      markerId: const MarkerId('destination'),
      position: point,
      icon: icon,
    );

    markers = {...markers, marker};
  }

  Future<void> _addUserDirectionMarker(LatLng point) async {
    final epoch = _rideVisualEpoch;
    try {
      markers =
          markers.where((m) => m.markerId.value != 'user_location').toSet();
    } catch (e) {
      debugPrint("Error removing user marker: $e");
    }

    final BitmapDescriptor icon = await _getBitmapDescriptorFromIconData(
      Icons.navigation,
      Colors.blue,
      48,
      angle: userBearing * (math.pi / 180),
    );

    final marker = Marker(
      markerId: const MarkerId('user_location'),
      position: point,
      icon: icon,
      flat: true,
      rotation: userBearing,
    );

    if (epoch == _rideVisualEpoch) markers = {...markers, marker};
  }

  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<Position>? _dropStreamSubscription;

  @observable
  bool _followUser = false;

  void _startLocationTracking() {
    final generation = _sessionGeneration;
    _positionStreamSubscription?.cancel();
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (generation != _sessionGeneration) return;
      _updateUserLocation(position);
    });
  }

  Future<void> _updateUserLocation(Position position) async {
    if (_lastPosition != null) {
      userBearing = Geolocator.bearingBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
    }

    LatLng newLocation = LatLng(position.latitude, position.longitude);
    userLocation = newLocation;

    await _addUserDirectionMarker(
      LatLng(
        position.latitude,
        position.longitude,
      ),
    );
    _lastPosition = position;

    if (_followUser) {
      await googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: userLocation!,
            zoom: 16,
            bearing: userBearing,
          ),
        ),
      );
    }
  }

  @observable
  LatLng? destinationLocation;

  Future<void> _setDestination(LatLng point) async {
    markers = markers.where((m) => m.markerId.value != 'destination').toSet();
    destinationLocation = point;
    await _addDestinationMarker(destinationLocation!);
  }

  Future<void> _calculateRoute(
      LatLng pickupLocation, LatLng dropLocation) async {
    final epoch = _rideVisualEpoch;
    try {
      polylines.clear();

      final directions = await _mapService.directionAPI(
          pickupLocation.latitude.toString(),
          pickupLocation.longitude.toString(),
          dropLocation.latitude.toString(),
          dropLocation.longitude.toString());

      if (epoch != _rideVisualEpoch) return;
      List<LatLng> routePoints = [];

      if (directions.routes != null && directions.routes!.isNotEmpty) {
        for (var coord in directions.routes![0].geometry!.coordinates!) {
          if (coord is List<dynamic> && coord.length >= 2) {
            routePoints.add(LatLng(coord[1] as double, coord[0] as double));
          }
        }

        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          points: routePoints,
          color: const Color(0xffFF9100),
          width: 6,
        );

        polylines = {polyline};

        if (routePoints.isNotEmpty) {
          final bounds = _calculateBounds(routePoints);
          googleMapController?.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 100),
          );
        }
      }
    } catch (e) {
      debugPrint("Error calculating route: $e");
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
        southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  @action
  Future<void> startNavigation(
    LatLng pickupPoint,
    LatLng destinationPoint,
  ) async {
    final epoch = _rideVisualEpoch;
    final pickupLocation = LatLng(pickupPoint.latitude, pickupPoint.longitude);
    final destination =
        LatLng(destinationPoint.latitude, destinationPoint.longitude);

    log('Pickup Location: Latitude: ${pickupLocation.latitude}, Longitude: ${pickupLocation.longitude}');
    log('Destination: Latitude: ${destination.latitude}, Longitude: ${destination.longitude}');

    await _calculateRoute(pickupLocation, destination);
    if (epoch != _rideVisualEpoch) return;
    await _setDestination(destination);
    if (epoch != _rideVisualEpoch) return;
    _startLocationTracking();
    _followUser = true;
    isNavigating = true;
  }

  @observable
  bool isNavigating = false;

  void _stopNavigation() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    polylines.clear();

    googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: userLocation ?? const LatLng(19.957860, 74.996357),
          zoom: 14.4746,
          bearing: 0,
        ),
      ),
    );

    isNavigating = false;
    _followUser = false;
  }

  @action
  void cancelDropStream() {
    _dropStreamSubscription?.cancel();
  }

  @observable
  bool isDropLocationArrived = false;

  @action
  Future<double> _getDistanceBetween({
    required double startLatitude,
    required double startLongitude,
  }) async {
    Position currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    double distance = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      startLatitude,
      startLongitude,
    );
    return distance;
  }

  @observable
  Position? lastPosition;

  @action
  Future<void> initializeLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      lastPosition = position;
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @action
  Future<void> createPolylines({
    required List<LatLng> points,
    Color color = const Color(0xFFFF9100),
    int width = 5,
    String polylineId = 'route_polyline',
    bool fitBounds = true,
    int padding = 50,
  }) async {
    if (points.isEmpty) {
      return;
    }

    try {
      final polyline = Polyline(
        polylineId: PolylineId(polylineId),
        points: points,
        color: color,
        width: width,
        geodesic: true,
      );

      polylines = {
        ...polylines.where((p) => p.polylineId.value != polylineId),
        polyline
      };

      if (fitBounds && points.length > 1) {
        final bounds = _calculateBounds(points);
        googleMapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, padding.toDouble()),
        );
      }
    } catch (e) {
      debugPrint('Error creating polyline: $e');
      error = 'Failed to draw route on map';
    }
  }

  @action
  Future<void> searchPlace(String searchText) async {
    if (searchText.isEmpty) {
      setSearchPlacesModel(null);
      return;
    }

    setIsLoginLoading(true);
    try {
      final searchResults = await _mapService.searchPlace(searchText);
      setSearchPlacesModel(searchResults);
    } catch (e) {
      error = 'Search failed: ${e.toString()}';
    } finally {
      setIsLoginLoading(false);
    }
  }

  @action
  Future<void> getDirection(
    String lat1,
    String long1,
    String lat2,
    String long2,
  ) async {
    setIsDirectionLoading(true);
    try {
      final directions = await _mapService.directionAPI(
        lat1,
        long1,
        lat2,
        long2,
      );
      setDirectionModel(directions);
      _processDirectionCoordinates(directions);
    } catch (e) {
      error = 'Direction fetch failed: ${e.toString()}';
    } finally {
      setIsDirectionLoading(false);
    }
  }

  @action
  void _processDirectionCoordinates(DirectionResponse directionResponse) {
    tempCoordinatesList.clear();
    for (var route in directionResponse.routes ?? []) {
      if (route.geometry?.coordinates != null) {
        for (var coord in route.geometry!.coordinates!) {
          if (coord is List<dynamic> && coord.length >= 2) {
            tempCoordinatesList
                .add(LatLng(coord[1] as double, coord[0] as double));
          }
        }
      }
    }
  }

  @action
  Future<void> findNearbyDrivers() async {
    if (isTrackingLocation) return;
    await startLocationTracking();
  }

  @action
  Future<void> startLocationTracking() async {
    final generation = _sessionGeneration;
    if (isTrackingLocation) return;

    try {
      isTrackingLocation = true;
      final initialPosition = await Geolocator.getCurrentPosition();
      if (generation != _sessionGeneration) return;
      _lastPosition = initialPosition;
      await _findNearbyDriversAtPosition(initialPosition);
      if (generation != _sessionGeneration) return;

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50,
        ),
      ).listen((position) {
        if (generation == _sessionGeneration) _handleLocationUpdate(position);
      });

      _nearbyDriversTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _updateIfStationary(),
      );
    } catch (e) {
      error = 'Failed to start location tracking: ${e.toString()}';
      isTrackingLocation = false;
    }
  }

  void _handleLocationUpdate(Position newPosition) async {
    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );

      if (distance >= _locationUpdateThreshold) {
        await _findNearbyDriversAtPosition(newPosition);
        _lastPosition = newPosition;
      }
    } else {
      await _findNearbyDriversAtPosition(newPosition);
      _lastPosition = newPosition;
    }
  }

  Future<void> _findNearbyDriversAtPosition(Position position) async {
    if (!isConnected) return;

    try {
      _socketService.findNearbyDrivers(
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 3.0,
      );
    } catch (e) {
      error = 'Failed to find nearby drivers: ${e.toString()}';
    }
  }

  void _updateIfStationary() {
    if (_lastPosition != null && isConnected && isTrackingLocation) {
      _socketService.findNearbyDrivers(
        latitude: _lastPosition!.latitude,
        longitude: _lastPosition!.longitude,
        radius: 3.0,
      );
    }
  }

  @action
  Future<void> submitFeedback({
    required String rideId,
    required String feedback,
    required int rating,
  }) async {
    if (_feedbackBusy.value || currentRide?.ride?.sId != rideId) return;
    if (currentRide?.ride?.status != RideStatus.completed) {
      runInAction(
          () => ratings.error.value = 'Only completed rides can be rated.');
      return;
    }
    final generation = _sessionGeneration;
    bool savedConfirmed = false;
    _feedbackBusy.value = true;

    try {
      final saved = await ratings.submit(rideId, rating, feedback);
      if (saved == null ||
          generation != _sessionGeneration ||
          currentRide?.ride?.sId != rideId) {
        return;
      }
      savedConfirmed = true;
      await recovery.forget();
      if (generation != _sessionGeneration ||
          currentRide?.ride?.sId != rideId) {
        return;
      }
      _closedRideIds.add(rideId);
      _clearRideState();
      _rideNotice(saved.stars == rating && saved.feedback == feedback.trim()
          ? 'Rating saved.'
          : 'Your earlier rating was already saved.');
    } catch (_) {
      if (generation == _sessionGeneration &&
          currentRide?.ride?.sId == rideId) {
        runInAction(() => ratings.error.value = savedConfirmed
            ? 'Your rating is saved. Finishing this ride could not be confirmed; please retry.'
            : 'Rating not confirmed. Please retry.');
      }
    } finally {
      if (generation == _sessionGeneration) {
        _feedbackBusy.value = false;
      }
    }
  }

  @action
  Future<bool> createRideRequest(PaymentMethod paymentMethod,
      {String? cardId,
      BookingQuote? quote,
      BookingQuoteService? quoteSession}) async {
    if (booking.busy.value || booking.pending.value || currentRide != null) {
      return false;
    }
    if (_sessionStarted && !recovery.ready.value) return false;
    if (!hasValidLocations || selectedPrice == null) {
      error = 'Please select both pickup and dropoff locations';
      return false;
    }
    if (quoteBookingsEnabled || quote != null) {
      final generation = _sessionGeneration;
      final token =
          await (_sessionTokenReader ?? PreferencesService.getAccessToken)();
      if (generation != _sessionGeneration) return false;
      if (!quoteBookingsEnabled ||
          quote == null ||
          quoteSession == null ||
          !_quoteSessions.contains(quoteSession) ||
          !quoteSession.owns(quote) ||
          token != _quoteToken ||
          !quote.bookingSupported ||
          quote.remaining <= Duration.zero ||
          !quote.matchesRequest(quoteRequest())) {
        error = 'Review a current fare before booking.';
        return false;
      }
      return submitBooking({
        'quoteId': quote.id,
        'quoteFingerprint': quote.fingerprint,
        'quoteAmountMinor': quote.amountMinor,
        'paymentMethod': paymentMethod.name,
        if (paymentMethod == PaymentMethod.card && cardId != null)
          'cardId': cardId,
      });
    }
    final routeDistanceInKm =
        getKilometer(directions?.routes?[0].distance ?? 0.0);
    final routeTimeInMinutes = ((directions?.routes?[0].duration ?? 0.0) / 60)
        .round()
        .clamp(1, 1440)
        .toInt();

    return submitBooking({
      'vehicleType': selectedPrice!.vehicleType.name,
      'pickup': {
        'latitude': selectedSuggestionsFrom!.properties!.coordinates!.latitude!,
        'longitude':
            selectedSuggestionsFrom!.properties!.coordinates!.longitude!,
        'address': currentLocationController.text
      },
      'destination': {
        'latitude': selectedSuggestionsTo!.properties!.coordinates!.latitude!,
        'longitude': selectedSuggestionsTo!.properties!.coordinates!.longitude!,
        'address': designationController.text
      },
      'paymentMethod': paymentMethod.name,
      if (cardId != null) 'cardId': cardId,
      'distanceInKm': routeDistanceInKm,
      'timeInMinutes': routeTimeInMinutes,
    });
  }

  Future<bool> submitBooking([Map<String, dynamic>? payload]) async {
    if (booking.busy.value ||
        (currentRide != null &&
            (!bookingConfirmationPending || !booking.pending.value))) {
      return false;
    }
    if (_sessionStarted && !recovery.ready.value) return false;
    final generation = _sessionGeneration;
    try {
      final response = await booking.submit(payload);
      if (generation != _sessionGeneration) return false;
      applyRideUpdate(response, allowNewRide: true);
      await resumeRideResources();
      return generation == _sessionGeneration &&
          currentRide != null &&
          !bookingConfirmationPending;
    } catch (_) {
      if (generation != _sessionGeneration) return false;
      if (_sessionStarted) await recovery.requireRefresh();
      if (generation != _sessionGeneration) return false;
      if (currentRide != null && !bookingConfirmationPending) return true;
      runInAction(() => error = booking.error.value);
      return false;
    }
  }

  Future<void> retryBookingConfirmation() async {
    if (booking.busy.value) return;
    if (currentRide == null || booking.pending.value) {
      await submitBooking();
    } else if (bookingConfirmationPending) {
      await recovery.requireRefresh();
    }
  }

  Future<void> retryDriverSearch() async {
    final ride = currentRide?.ride;
    if (searchBusy.value ||
        !noDriversFound ||
        ride?.sId == null ||
        ride?.version == null) {
      return;
    }
    if (_sessionStarted && !recovery.ready.value) return;
    final generation = _sessionGeneration;
    final rideId = ride!.sId!;
    final version = ride.version!;
    bool ownsRide() =>
        generation == _sessionGeneration && currentRide?.ride?.sId == rideId;
    runInAction(() {
      searchBusy.value = true;
      error = null;
    });
    try {
      final token =
          await (_sessionTokenReader ?? PreferencesService.getAccessToken)();
      if (!ownsRide() ||
          currentRide?.ride?.version != version ||
          !noDriversFound) {
        return;
      }
      if (token == null || token.isEmpty) throw StateError('Sign in required');
      final updated = await _rideService.retrySearch(rideId, version,
          expectedAuthToken: token);
      if (ownsRide()) applyRideUpdate(updated);
    } catch (failure) {
      if (!ownsRide()) return;
      if (_sessionStarted) await recovery.requireRefresh();
      if (ownsRide() && noDriversFound) {
        final data = failure is DioException ? failure.response?.data : null;
        final needsRecovery =
            data is Map && data['code'] == 'BOOKING_SEARCH_RECOVERY_REQUIRED';
        runInAction(() => error = needsRecovery
            ? 'This search cannot be restarted automatically. Refresh the ride or contact support.'
            : 'Search could not be refreshed. Please retry.');
      }
    } finally {
      if (generation == _sessionGeneration) {
        runInAction(() => searchBusy.value = false);
      }
    }
  }


  @observable
  bool isApplyingPromoCode = false;

  @action
  Future<Bonuses?> addPromoCode(String code, num baseAmount) async {
    try {
      isApplyingPromoCode = true;
      final result = await _rideService.addPromoCode(code, baseAmount);
      return result;
    } catch (e) {
      error = 'Failed to apply promo code: ${e.toString()}';
      return null;
    } finally {
      isApplyingPromoCode = false;
    }
  }

  List<List<double>> decodePolyline(String str, {int precision = 5}) {
    int index = 0;
    double lat = 0;
    double lng = 0;
    final List<List<double>> coordinates = [];
    final double factor = math.pow(10, precision).toDouble();

    while (index < str.length) {
      // Decode latitude
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = str.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final int deltaLat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      // Decode longitude
      shift = 0;
      result = 0;
      do {
        byte = str.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final int deltaLng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      coordinates.add([lat / factor, lng / factor]);
    }

    return coordinates;
  }

  @observable
  bool isCancellingRide = false;

  @action
  Future<void> cancelRide(String reason) async {
    if (bookingConfirmationPending) return;
    if (_sessionStarted && !recovery.ready.value) return;
    final generation = _sessionGeneration;
    if (currentRide == null || isCancellingRide) return;
    final rideId = currentRide!.ride!.sId!;

    try {
      isCancellingRide = true;
      final confirmed = await _rideService.updateRideStatus(
        rideId,
        RideStatus.cancelled,
        reason: reason,
      );

      if (generation != _sessionGeneration) return;
      applyRideUpdate(RideRequest(ride: confirmed));
    } catch (e) {
      if (generation != _sessionGeneration) return;
      if (_sessionStarted) await recovery.requireRefresh();
      if (generation != _sessionGeneration) return;
      if (currentRide?.ride?.sId == rideId) {
        error = 'Failed to cancel ride: ${e.toString()}';
      }
    } finally {
      if (generation == _sessionGeneration &&
          (currentRide == null || currentRide?.ride?.sId == rideId)) {
        isCancellingRide = false;
      }
    }
  }

  @action
  Future<void> updateDriverMarkers() async {
    final epoch = _rideVisualEpoch;
    // Remove existing driver markers
    markers =
        markers.where((m) => !m.markerId.value.startsWith('driver_')).toSet();

    // Add current driver markers
    for (var driver in nearbyDrivers.values.toList()) {
      final BitmapDescriptor icon = await createAssetMarker(
        Assets.taxiIc,
        height: 150,
        width: 150,
      );

      final marker = Marker(
        markerId: MarkerId('driver_${driver.driverId}'),
        position: LatLng(driver.latitude, driver.longitude),
        icon: icon,
        flat: true,
        infoWindow:
            isRideAccepted && driver.driverId == currentRide?.ride?.driverId
                ? const InfoWindow(
                    title: 'Your Driver',
                    snippet: 'On the way to pickup',
                  )
                : InfoWindow.noText,
      );

      if (epoch != _rideVisualEpoch) return;
      markers = {...markers, marker};
    }
  }

  @action
  void stopLocationTracking() {
    isTrackingLocation = false;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _nearbyDriversTimer?.cancel();
    _nearbyDriversTimer = null;
    _lastPosition = null;
  }

  @action
  void setSearchPlacesModel(SearchPlace? searchResponse) {
    searchPlaceModel = searchResponse;
  }

  @action
  void setDirectionModel(DirectionResponse? direction) {
    directions = direction;
  }

  @action
  void setCurrentController(bool value) {
    isCurrentController = value;
  }

  @action
  void addCoordinate(LatLng coordinate) {
    coordinatesList.add(coordinate);
  }

  @action
  void clearCoordinates() {
    coordinatesList.clear();
  }

  @action
  double getKilometer(double value) {
    return value / 1000;
  }

  @action
  void setIsLoginLoading(bool isLoading) => isLoginLoading = isLoading;

  @action
  void setIsDirectionLoading(bool isLoading) => isDirectionLoading = isLoading;

  @action
  void clearErrors() => error = null;

  @observable
  List<Ride> rideHistory = [];

  @observable
  bool isRideHistoryLoading = false;

  @action
  Future<void> getAllRide() async {
    final generation = _sessionGeneration;
    try {
      isRideHistoryLoading = true;
      final rides = await _rideService.getRides();
      if (generation != _sessionGeneration) return;
      rideHistory = rides.rides;
    } catch (e) {
      log('Error getting rides: $e');
    } finally {
      if (generation == _sessionGeneration) isRideHistoryLoading = false;
    }
  }

  String _paymentCompletionMessage(Payment? payment) {
    final status = payment?.status?.toLowerCase() ?? '';
    final amount = payment?.capturedAmount ?? payment?.driverCreditedAmount;
    switch (status) {
      case 'captured':
      case 'settled':
        if (amount != null && amount > 0) {
          return 'Ride complete. ${_paymentMethodLabel(payment?.method)} paid \$${amount.toStringAsFixed(2)}.';
        }
        return 'Ride complete. Payment settled.';
      case 'adjustment_pending':
        final captured = payment?.capturedAmount;
        final remaining = payment?.adjustmentRemaining;
        if (captured != null && remaining != null) {
          return 'Ride complete. \$${captured.toStringAsFixed(2)} paid, \$${remaining.toStringAsFixed(2)} retry pending.';
        }
        return 'Ride complete. Payment retry pending.';
      case 'adjustment_failed_permanent':
        return 'Ride complete. Payment needs support review.';
      default:
        return 'Ride completed successfully!';
    }
  }

  String _paymentMethodLabel(String? method) {
    return switch (method?.toLowerCase()) {
      'wallet' => 'Wallet',
      'card' => 'Card',
      _ => 'Payment',
    };
  }

  @action
  Future<void> getCurrentRide() async {
    await recovery.refresh();
  }

  void dispose() {
    for (final service in _safetySessions.toList()) {
      service.endSession();
    }
    _sessionStarted = false;
    _sessionGeneration++;
    for (final session in _quoteSessions) {
      session.dispose();
    }
    _quoteSessions.clear();
    _quoteSessionIdentity = null;
    _quoteToken = null;
    ratings.reset();
    _feedbackBusy.value = false;
    _chatRead++;
    chat.reset();
    clearTyping();
    recovery.dispose();
    booking.dispose();
    runInAction(() => searchBusy.value = false);
    _socketService.dispose();
    _clearRideState();
    _closedRideIds.clear();
    isConnected = false;
    error = null;
    stopLocationTracking();
    currentLocationController.clear();
    designationController.clear();
    selectedSuggestionsFrom = null;
    selectedSuggestionsTo = null;
    userLocation = null;
    _lastPosition = null;
    rideHistory = [];
    isRideHistoryLoading = false;
    prices.clear();
    selectedPrice = null;
    coordinatesList.clear();
    tempCoordinatesList.clear();
    nearbyDrivers.clear();
    _positionStreamSubscription?.cancel();
    googleMapController = null;
  }
}
