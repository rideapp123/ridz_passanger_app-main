// ignore_for_file: unused_import

import 'dart:math' as math;
import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
import '../../core/services/toast_service.dart';
import '../../models/common/location/driver_location.dart';
import '../../models/common/ride_response/ride_response.dart';
import '../../models/ride/get_ride_response.dart' hide Payment;

part 'map_store.g.dart';

class MapStore = MapStoreBase with _$MapStore;

MapStore mapStoreProvider({bool listen = false}) {
  return Provider.of(NavigationService.navigatorKey.currentContext!,
      listen: listen);
}

abstract class MapStoreBase with Store {
  final SocketService _socketService = SocketService();
  final RideService _rideService = RideService();
  final MapService _mapService = MapService();

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

  @observable
  Future<void> loadChatMessage({required String rideId}) async {
    try {
      isLoadingChatMessage = true;
      final request = await Api().dio.get(
            '/chat/$rideId',
          );

      log('Chat message status code: ${request.statusCode}');
      log('Chat message response: ${request.data}');

      if (request.statusCode == 200) {
        final payload = request.data is Map<String, dynamic>
            ? Map<String, dynamic>.from(request.data as Map)
            : <String, dynamic>{};
        final data = payload['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(payload['data'] as Map)
            : <String, dynamic>{};
        final messages = (data['messages'] as List? ?? <dynamic>[]);
        final response = messages.map((e) {
          return RideMessage.fromJson(e);
        }).toList();

        chatMessages = response.toList();
        isLoadingChatMessage = false;
      } else {
        log('Error loading chat messages: ${request.statusCode}');
        isLoadingChatMessage = false;
      }
    } catch (e) {
      log('Error loading chat messages: ${e.toString()}');
      isLoadingChatMessage = false;
    } finally {
      isLoadingChatMessage = false;
    }
  }

  @action
  Future<void> sendMessage({
    required String rideId,
    required String message,
  }) async {
    try {
      await _socketService.sendMessage(
        rideId: rideId,
        message: message,
      );
    } catch (e) {
      log('Error sending message: ${e.toString()}');
      ToastService.show('Error sending message');
    }
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
        onRideAccepted: (response) async {
          log('Ride Status: ${response.ride?.status}');
          log('Ride accepted: ${response.toJson()}');
          isCreatingRide = false;
          isRideAccepted = true;
          currentRide = response;

          nearbyDrivers.clear();

          if (response.ride?.pickup != null &&
              response.ride?.destination != null) {
            final pickupLocation = LatLng(
              response.ride!.pickup!.latitude!,
              response.ride!.pickup!.longitude!,
            );
            final dropLocation = LatLng(
              response.ride!.destination!.latitude!,
              response.ride!.destination!.longitude!,
            );

            await _calculateRoute(pickupLocation, dropLocation);

            await _addPickupMarker(pickupLocation);
            await _addDestinationMarker(dropLocation);
          }

          updateDriverMarkers();
        },
        onRideStatusUpdate: (response) {
          log('Ride Status Ride Status: ${response.ride?.status}');
          isCreatingRide = false;
          currentRide = response;
        },
        onRideRejected: (response) {
          log('Ride Status: ${response.ride?.status}');
        },
        onRideArrived: (response) {
          log('Ride Status: ${response.ride?.status}');
          currentRide = response;
        },
        onRideStarted: (response) async {
          log('Ride Status: ${response.ride?.status}');
          currentRide = response;
          startNavigation(
            LatLng(
              response.ride?.pickup?.latitude ?? 0.0,
              response.ride?.pickup?.longitude ?? 0.0,
            ),
            LatLng(
              response.ride?.destination?.latitude ?? 0.0,
              response.ride?.destination?.longitude ?? 0.0,
            ),
          );
        },
        onRideCompleted: (response) async {
          log('Ride completed: ${response.ride?.status}');
          currentRide = response;
          _stopNavigation();
          polylines.clear();
          markers = markers
              .where((m) => !m.markerId.value.startsWith('driver_'))
              .toSet();
          ToastService.show(_paymentCompletionMessage(response.ride?.payment));
        },
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
          isConnected = true;
          error = null;
          findNearbyDrivers();
        },
        onDisconnected: () {
          isConnected = false;
          nearbyDrivers.clear();
        },
        typingStatus: (data) {
          if (data['isTyping'] && data['user'] == 'driver') {
            isTyping = true;
          } else {
            isTyping = false;
          }
        },
        onMessageReceived: (message) {
          chatMessages = [...chatMessages, message];
        },
      );
    } catch (e) {
      error = e.toString();
    }
  }

  @observable
  bool isTyping = false;

  @observable
  LatLng? userLocation;

  @observable
  double userBearing = 0.0;

  Future<void> _addPickupMarker(LatLng point) async {
    final BitmapDescriptor icon = await _getBitmapDescriptorFromIconData(
      Icons.location_on,
      Colors.green,
      48,
    );

    final marker = Marker(
      markerId: const MarkerId('pickup_location'),
      position: point,
      icon: icon,
    );

    markers = {...markers, marker};
  }

  Future<void> _addDestinationMarker(LatLng point) async {
    final BitmapDescriptor icon = await _getBitmapDescriptorFromIconData(
      Icons.place,
      Colors.red,
      48,
    );

    final marker = Marker(
      markerId: const MarkerId('destination'),
      position: point,
      icon: icon,
    );

    markers = {...markers, marker};
  }

  Future<void> _addUserDirectionMarker(LatLng point) async {
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

    markers = {...markers, marker};
  }

  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<Position>? _dropStreamSubscription;

  @observable
  bool _followUser = false;

  void _startLocationTracking() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
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
    try {
      polylines.clear();

      final directions = await _mapService.directionAPI(
          pickupLocation.latitude.toString(),
          pickupLocation.longitude.toString(),
          dropLocation.latitude.toString(),
          dropLocation.longitude.toString());

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
    final pickupLocation = LatLng(pickupPoint.latitude, pickupPoint.longitude);
    final destination =
        LatLng(destinationPoint.latitude, destinationPoint.longitude);

    log('Pickup Location: Latitude: ${pickupLocation.latitude}, Longitude: ${pickupLocation.longitude}');
    log('Destination: Latitude: ${destination.latitude}, Longitude: ${destination.longitude}');

    await _calculateRoute(pickupLocation, destination);
    await _setDestination(destination);
    _startLocationTracking();
    _followUser = true;
    isNavigating = true;
  }

  @observable
  bool isNavigating = false;

  void _stopNavigation() async {
    _positionStreamSubscription?.cancel();
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
    if (isTrackingLocation) return;

    try {
      isTrackingLocation = true;
      final initialPosition = await Geolocator.getCurrentPosition();
      _lastPosition = initialPosition;
      await _findNearbyDriversAtPosition(initialPosition);

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50,
        ),
      ).listen(_handleLocationUpdate);

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
    try {
      await _socketService.giveFeedback(
        feedback: feedback,
        rideId: rideId,
        rating: rating,
      );

      isRideAccepted = false;
      currentRide = null;

      markers = {};
      polylines = {};
      _dropStreamSubscription?.cancel();
      chatMessages = [];
    } catch (e, st) {
      error = 'Failed to give ride: ${e.toString()}';
      log('Error giving ride: ${e.toString()}');
      log('Error giving ride: $st');
    }
  }

  @action
  Future<void> createRideRequest(PaymentMethod paymentMethod) async {
    if (!isConnected || !hasValidLocations) {
      error = 'Please select both pickup and dropoff locations';
      return;
    }

    try {
      isCreatingRide = true;
      error = null;
      final routeDistanceInKm =
          getKilometer(directions?.routes?[0].distance ?? 0.0);
      final routeTimeInMinutes = ((directions?.routes?[0].duration ?? 0.0) / 60)
          .round()
          .clamp(1, 1440)
          .toInt();

      final response = await _rideService.createRideRequest(
        vehicleType: selectedPrice!.vehicleType,
        pickup: LocationDetails(
          latitude: selectedSuggestionsFrom!.properties!.coordinates!.latitude!,
          longitude:
              selectedSuggestionsFrom!.properties!.coordinates!.longitude!,
          address: currentLocationController.text,
          instructions: selectedSuggestionsFrom!.properties!.address,
        ),
        destination: LocationDetails(
          latitude: selectedSuggestionsTo!.properties!.coordinates!.latitude!,
          longitude: selectedSuggestionsTo!.properties!.coordinates!.longitude!,
          address: designationController.text,
          instructions: selectedSuggestionsTo!.properties!.address,
        ),
        paymentMethod: paymentMethod,
        distanceInKm: routeDistanceInKm,
        estimatedTimeInMinutes: routeTimeInMinutes,
      );
      currentRide = response;
      final wayPoints = decodePolyline(
        currentRide?.ride?.route?.encoded ?? '',
      );

      List<LatLng> routePoints = wayPoints.map((e) {
        return LatLng(e[0], e[1]);
      }).toList();

      if (routePoints.isNotEmpty) {
        final polyline = Polyline(
          polylineId: const PolylineId('ride_route'),
          points: routePoints,
          color: const Color(0xffFF9100),
          width: 6,
        );

        polylines = {polyline};

        final bounds = _calculateBounds(routePoints);
        googleMapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }
    } catch (e) {
      error = 'Failed to create ride: ${e.toString()}';
    } finally {
      isCreatingRide = false;
    }
  }

  Future<num?> claimAdRewardForCurrentRide() async {
    final rideId = currentRide?.ride?.sId;
    final session = await _rideService.startAdReward(rideId: rideId);
    final sessionId = (session['id'] ?? session['_id'] ?? '').toString();
    if (sessionId.isEmpty) {
      throw Exception('Ad reward session was not created');
    }
    final result = await _rideService.completeAdReward(sessionId);
    final transaction = result['transaction'];
    if (transaction is Map && transaction['amount'] is num) {
      return transaction['amount'] as num;
    }
    final completedSession = result['session'];
    if (completedSession is Map && completedSession['rewardAmount'] is num) {
      return completedSession['rewardAmount'] as num;
    }
    return null;
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
    if (currentRide == null) return;

    try {
      isCancellingRide = true;
      await _rideService.updateRideStatus(
        currentRide!.ride!.sId!,
        RideStatus.cancelled,
        reason: reason,
      );

      currentRide = null;
      _stopNavigation();
      polylines.clear();
      isCreatingRide = false;
      isRideAccepted = false;
      markers =
          markers.where((m) => !m.markerId.value.startsWith('driver_')).toSet();
      ToastService.show('Ride cancelled successfully!');
    } catch (e) {
      error = 'Failed to cancel ride: ${e.toString()}';
    } finally {
      isCancellingRide = false;
    }
  }

  @action
  Future<void> updateDriverMarkers() async {
    // Remove existing driver markers
    markers =
        markers.where((m) => !m.markerId.value.startsWith('driver_')).toSet();

    // Add current driver markers
    for (var driver in nearbyDrivers.values) {
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
    try {
      isRideHistoryLoading = true;
      final rides = await _rideService.getRides();
      rideHistory = rides.rides;
    } catch (e) {
      log('Error getting rides: $e');
    } finally {
      isRideHistoryLoading = false;
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
    try {
      isCreatingRide = true;
      currentRide = await _rideService.getCurrentRides();
      if (currentRide != null && currentRide!.ride != null) {
        isRideAccepted = true;
        final pickupLocation = LatLng(
          currentRide!.ride!.pickup!.latitude!,
          currentRide!.ride!.pickup!.longitude!,
        );
        final dropLocation = LatLng(
          currentRide!.ride!.destination!.latitude!,
          currentRide!.ride!.destination!.longitude!,
        );
        await _calculateRoute(pickupLocation, dropLocation);
        await _addPickupMarker(pickupLocation);
        await _addDestinationMarker(dropLocation);
      } else {
        isRideAccepted = false;
      }
    } catch (e) {
      log('Error getting current ride: $e');
    } finally {
      isCreatingRide = false;
    }
  }

  void dispose() {
    _socketService.dispose();
    stopLocationTracking();
    currentLocationController.dispose();
    designationController.dispose();
    coordinatesList.clear();
    tempCoordinatesList.clear();
    nearbyDrivers.clear();
    _positionStreamSubscription?.cancel();
    googleMapController = null;
  }
}
