import 'dart:developer';
import 'ride_booking_hint.dart';
import 'package:ridzs_passenger_app/core/services/preferences_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/services/dio_service.dart';
import '../../models/chat/chat_message_model.dart';
import '../../models/common/location/driver_location.dart';
import '../../models/common/ride_response/ride_response.dart';
import '../configs/app_config.dart';

typedef NearbyDriversCallback = void Function(List<DriverLocation> drivers);
typedef RideResponseCallback = void Function(RideRequest response);
typedef RideArrivedCallback = void Function(RideRequest response);
typedef RideStartedCallback = void Function(RideRequest response);
typedef RideStatusCallback = void Function(RideRequest status);
typedef RideCompletedCallback = void Function(RideRequest response);
typedef DriverLocationCallback = void Function(DriverLocation location);
typedef ErrorCallback = void Function(String message);
typedef TypingStatusCallback = Function(Map<String, dynamic>);
typedef RideMessageCallback = Function(RideMessage);
typedef ConnectionCallback = void Function();

class SocketService {
  static final SocketService _instance = SocketService._();
  factory SocketService() => _instance;
  SocketService._()
      : _tokenReader = PreferencesService.getAccessToken,
        _socketFactory = io.io;
  SocketService.withTransport({
    Future<String?> Function()? tokenReader,
    io.Socket Function(String, Map<String, dynamic>)? socketFactory,
  })  : _tokenReader = tokenReader ?? PreferencesService.getAccessToken,
        _socketFactory = socketFactory ?? io.io;

  final Future<String?> Function() _tokenReader;
  final io.Socket Function(String, Map<String, dynamic>) _socketFactory;

  late io.Socket socket;
  bool _initialized = false;
  int _epoch = 0;

  NearbyDriversCallback? _onNearbyDrivers;
  RideResponseCallback? _onRideAccepted;
  RideResponseCallback? _onRideStarted;
  RideResponseCallback? _onRideRejected;
  RideArrivedCallback? _onRideArrived;
  RideStatusCallback? _onRideStatusUpdate;
  RideCompletedCallback? _onRideCompleted;
  DriverLocationCallback? _onDriverLocation;
  ErrorCallback? _onError;
  ConnectionCallback? _onConnected;
  TypingStatusCallback? _typingStatus;
  RideMessageCallback? _onMessageReceived;
  ConnectionCallback? _onDisconnected;

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _unwrapData(dynamic value) {
    final body = _asMap(value);
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return body;
  }

  double _toDouble(dynamic value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  Future<void> initialize({
    NearbyDriversCallback? onNearbyDrivers,
    RideResponseCallback? onRideAccepted,
    TypingStatusCallback? typingStatus,
    RideResponseCallback? onRideRejected,
    RideArrivedCallback? onRideArrived,
    RideStartedCallback? onRideStarted,
    RideStatusCallback? onRideStatusUpdate,
    RideCompletedCallback? onRideCompleted,
    DriverLocationCallback? onDriverLocation,
    ErrorCallback? onError,
    ConnectionCallback? onConnected,
    ConnectionCallback? onDisconnected,
    RideMessageCallback? onMessageReceived,
    void Function(dynamic)? onRideSync,
    void Function(dynamic, String)? onBookingSync,
  }) async {
    final epoch = ++_epoch;
    if (_initialized) socket.dispose();
    _initialized = false;

    try {
      String? accessToken = await _tokenReader();
      if (epoch != _epoch) return;
      if (accessToken == null) throw Exception('Access token not available');

      _setupCallbacks(
        onNearbyDrivers: onNearbyDrivers,
        onRideAccepted: onRideAccepted,
        typingStatus: typingStatus,
        onRideRejected: onRideRejected,
        onRideStarted: onRideStarted,
        onRideStatusUpdate: onRideStatusUpdate,
        onRideArrived: onRideArrived,
        onRideCompleted: onRideCompleted,
        onDriverLocation: onDriverLocation,
        onError: onError,
        onConnected: onConnected,
        onDisconnected: onDisconnected,
        onMessageReceived: onMessageReceived,
      );

      socket = _socketFactory(
        AppConfig.socketUrl,
        io.OptionBuilder()
            .setPath(AppConfig.socketPath)
            .setTransports(['websocket'])
            .setExtraHeaders({
              'authorization': 'Bearer $accessToken',
              'x-user-type': 'passenger',
            })
            .setQuery({'token': accessToken, 'userType': 'passenger'})
            .enableForceNew()
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(15)
            .setReconnectionDelay(2000)
            .build(),
      );

      _setupSocketListeners();
      socket.on('ride:sync', (data) {
        if (_initialized && epoch == _epoch) onRideSync?.call(data);
      });
      var readingBookingToken = false;
      socket.on('ride:booking-sync', (data) async {
        if (!_initialized ||
            epoch != _epoch ||
            readingBookingToken ||
            RideBookingHint.parse(data) == null) {
          return;
        }
        readingBookingToken = true;
        try {
          final token = await _tokenReader();
          if (_initialized && epoch == _epoch && token == accessToken) {
            onBookingSync?.call(data, accessToken);
          }
        } catch (_) {
          // Resume/reconciliation remains available when local storage fails.
        } finally {
          readingBookingToken = false;
        }
      });
      _initialized = true;
      socket.connect();
      log('Socket initialized', name: 'socket');
    } catch (e) {
      if (epoch != _epoch) return;
      _initialized = false;
      final error = 'Socket initialization failed: $e';
      log(error, name: 'socket');
      _onError?.call(error);
      rethrow;
    }
  }

  void _setupCallbacks({
    NearbyDriversCallback? onNearbyDrivers,
    RideResponseCallback? onRideAccepted,
    RideResponseCallback? onRideRejected,
    TypingStatusCallback? typingStatus,
    RideStartedCallback? onRideStarted,
    RideArrivedCallback? onRideArrived,
    RideStatusCallback? onRideStatusUpdate,
    RideCompletedCallback? onRideCompleted,
    DriverLocationCallback? onDriverLocation,
    ErrorCallback? onError,
    ConnectionCallback? onConnected,
    ConnectionCallback? onDisconnected,
    RideMessageCallback? onMessageReceived,
  }) {
    _onNearbyDrivers = onNearbyDrivers;
    _typingStatus = typingStatus;
    _onRideAccepted = onRideAccepted;
    _onRideArrived = onRideArrived;
    _onRideRejected = onRideRejected;
    _onRideStarted = onRideStarted;
    _onRideStatusUpdate = onRideStatusUpdate;
    _onRideCompleted = onRideCompleted;
    _onDriverLocation = onDriverLocation;
    _onError = onError;
    _onConnected = onConnected;
    _onDisconnected = onDisconnected;
    _onMessageReceived = onMessageReceived;
  }

  void _setupSocketListeners() {
    socket
      ..onConnect((_) {
        log('Socket connected', name: 'socket');
        _onConnected?.call();
      })
      ..onDisconnect((_) {
        log('Socket disconnected', name: 'socket');
        _onDisconnected?.call();
      })
      ..onConnectError((err) {
        final error = 'Connection error: $err';
        log(error, name: 'socket');
        _onError?.call(error);
      })
      ..onError((err) {
        final error = 'Socket error: $err';
        log(error, name: 'socket');
        _onError?.call(error);
      });

    socket.on('nearbyDrivers:found', _handleNearbyDrivers);
    socket.on('ride:rejected', _handleRideRejected);
    socket.on('ride:cancelled', _handleRideStatus);
    socket.on('ride:driverAssigned', _handleRideAccepted);
    socket.on('ride:driverArrived', _handleRideArrived);
    socket.on('ride:status', _handleRideStatus);
    socket.on('ride:started', _handleRideStarted);
    socket.on('ride:completed', _handleRideCompleted);
    socket.on('driver:location', _handleDriverLocation);
    socket.on(
      'ride:noDriverFound',
      (_) => _onError?.call('No drivers available nearby'),
    );
    socket.on('chat:typing', _handleTypingStatus);
    socket.on('ride:notification', _handleRideNotification);
    socket.on(
        'ride:noDriverFound',
        (data) => _handleRideNotification(
            {'type': 'RIDE_NO_DRIVER_FOUND', 'data': data}));
    socket.on('system:notification', _handleSystemNotification);
    socket.on('chat:message', (data) {
      log('Handle message data', name: 'socket');
      try {
        final message = RideMessage.fromJson(_asMap(data));
        _onMessageReceived?.call(message);
      } catch (e) {
        log('Error parsing message: $e', name: 'socket');
        _onError?.call('Error processing message data');
      }
    });
  }

  Future<void> joinChatRoom(String rideId) async {
    if (!_checkConnection()) return;

    try {
      socket.emit('join:ride', {"rideId": rideId});
      log('Joining chat room for rideId: $rideId', name: 'socket');
    } catch (e) {
      log('Error joining chat room: $e', name: 'socket');
      rethrow;
    }
  }

  Future<void> leaveChatRoom(String rideId) async {
    if (!_checkConnection()) return;

    try {
      socket.emit('leave:ride', {"rideId": rideId});
      log('Joining chat room for rideId: $rideId', name: 'socket');
    } catch (e) {
      log('Error joining chat room: $e', name: 'socket');
      rethrow;
    }
  }

  void _handleNearbyDrivers(dynamic data) {
    try {
      log('Handle Driver location update data', name: 'socket');
      final list = data is List ? data : <dynamic>[];
      final List<DriverLocation> drivers = list.map((driver) {
        final d = _asMap(driver);
        return DriverLocation.fromJson({
          'driverId': d['driverId'] ?? '',
          'latitude': _toDouble(d['latitude']),
          'longitude': _toDouble(d['longitude']),
          'heading': d['heading'],
          'speed': d['speed'],
          'timestamp': d['timestamp'] ?? DateTime.now().toIso8601String(),
          'isAvailable': d['isAvailable'] ?? true,
          'vehicle': d['vehicle'],
        });
      }).toList();
      _onNearbyDrivers?.call(drivers);
    } catch (e) {
      log('Error parsing nearby drivers: $e', name: 'socket');
      _onError?.call('Error processing nearby drivers data');
    }
  }

  void _handleRideAccepted(dynamic data) {
    try {
      log('Handle ride accepted data', name: 'socket');
      final response = RideRequest.fromJson(data);
      _onRideAccepted?.call(response);
    } catch (e) {
      log('Error parsing ride acceptance: $e', name: 'socket');
      _onError?.call('Error processing ride acceptance');
    }
  }

  void _handleRideStarted(dynamic data) {
    try {
      log('Handle ride started data', name: 'socket');
      final response = RideRequest.fromJson(data);
      _onRideStarted?.call(response);
    } catch (e) {
      log('Error parsing ride acceptance: $e', name: 'socket');
      _onError?.call('Error processing ride acceptance');
    }
  }

  void _handleRideRejected(dynamic data) {
    try {
      final response = RideRequest.fromJson(data);
      _onRideRejected?.call(response);
    } catch (e) {
      log('Error parsing ride rejection: $e', name: 'socket');
      _onError?.call('Error processing ride rejection');
    }
  }

  void _handleRideArrived(dynamic data) {
    try {
      final response = RideRequest.fromJson(data);
      _onRideArrived?.call(response);
    } catch (e) {
      log('Error parsing ride rejection: $e', name: 'socket');
      _onError?.call('Error processing ride rejection');
    }
  }

  void _handleRideStatus(dynamic data) {
    try {
      final response = RideRequest.fromJson(data);
      _onRideStatusUpdate?.call(response);
    } catch (e) {
      log('Error parsing ride status: $e', name: 'socket');
      _onError?.call('Error processing ride status');
    }
  }

  void _handleRideCompleted(dynamic data) {
    try {
      log('Handle ride completed data', name: 'socket');
      final response = RideRequest.fromJson(data);
      _onRideCompleted?.call(response);
    } catch (e) {
      log('Error parsing ride completion: $e', name: 'socket');
      _onError?.call('Error processing ride completion');
    }
  }

  void _handleDriverLocation(dynamic data) {
    try {
      final d = _asMap(data);
      final driver = DriverLocation.fromJson({
        'driverId': d['driverId'] ?? '',
        'latitude': _toDouble(d['latitude']),
        'longitude': _toDouble(d['longitude']),
        'heading': d['heading'],
        'speed': d['speed'],
        'timestamp': d['timestamp'] ??
            d['updatedAt'] ??
            DateTime.now().toIso8601String(),
        'isAvailable': d['isAvailable'] ?? true,
        'vehicle': d['vehicle'],
      });
      _onDriverLocation?.call(driver);
    } catch (e) {
      log('Error parsing driver location: $e', name: 'socket');
      _onError?.call('Error processing driver location');
    }
  }

  void _handleTypingStatus(dynamic data) {
    try {
      log('Handle typing status data', name: 'socket');
      final payload = _asMap(data);
      final role = payload['user'] ?? payload['by'];
      final typing = payload['isTyping'] ?? payload['typing'];
      if (payload['rideId'] is! String ||
          (role != 'driver' && role != 'passenger') ||
          typing is! bool) {
        return;
      }
      _typingStatus?.call({
        'rideId': payload['rideId'],
        'user': role,
        'isTyping': typing,
      });
    } catch (e) {
      log('Error parsing typing status: $e', name: 'socket');
      _onError?.call('Error processing typing status');
    }
  }

  Future<RideRequest?> _fetchRideRequestById(String rideId) async {
    try {
      final response = await Api().dio.get('/rides/$rideId');
      final data = _unwrapData(response.data);
      final ride = data['ride'];
      if (ride is! Map) return null;
      return RideRequest.fromJson({'ride': Map<String, dynamic>.from(ride)});
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleRideNotification(dynamic raw) async {
    final epoch = _epoch;
    final payload = _asMap(raw);
    final type = (payload['type'] ?? '').toString();
    final data = _asMap(payload['data']);
    final rideId = (data['rideId'] ?? '').toString();
    if (!const {
          'RIDE_ACCEPTED',
          'DRIVER_ARRIVED',
          'RIDE_STARTED',
          'RIDE_COMPLETED',
          'RIDE_CANCELLED',
          'RIDE_STATUS_UPDATED',
          'RIDE_REQUESTED',
          'RIDE_NO_DRIVER_FOUND'
        }.contains(type) ||
        rideId.isEmpty) {
      return;
    }
    // A notification is a refresh hint, never a fabricated ride snapshot.
    final request = await _fetchRideRequestById(rideId);
    if (epoch != _epoch) return;
    if (request?.ride?.sId == rideId) _onRideStatusUpdate?.call(request!);
  }

  void _handleSystemNotification(dynamic raw) {
    final payload = _asMap(raw);
    final message = (payload['message'] ?? '').toString();
    if (message.isNotEmpty && payload['type'] == 'error') {
      _onError?.call(message);
    }
  }

  void getRideStatus(String rideId) {
    if (!_checkConnection()) return;

    try {
      socket.emit('passenger:rideStatus', {'rideId': rideId});
      log('Getting ride status', name: 'socket');
    } catch (e) {
      log('Error getting ride status: $e', name: 'socket');
      _onError?.call('Error while getting ride status');
    }
  }

  Future<void> sendTypingNotification({
    required String rideId,
    required bool isTyping,
  }) async {
    if (!_checkConnection()) return;

    try {
      socket.emit(isTyping ? 'chat:typing:start' : 'chat:typing:stop', {
        "rideId": rideId,
      });
      log('Sending typing start:', name: 'socket');
    } catch (e) {
      log('Error Sending typing start: $e', name: 'socket');
      _onError?.call('Error while Sending typing start');
    }
  }

  void findNearbyDrivers({
    required double latitude,
    required double longitude,
    double radius = 3.0,
  }) {
    final epoch = _epoch;
    try {
      if (_initialized && socket.connected) {
        socket.emit('passenger:nearbyDrivers', {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        });
      }
      Api().dio.get('/nearby-drivers', queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      }).then((response) {
        if (epoch != _epoch) return;
        final body = _asMap(response.data);
        final data = body['data'];
        if (data is List) {
          _handleNearbyDrivers(data);
        }
      }).catchError((_) {});
    } catch (e) {
      log('Error finding nearby drivers: $e', name: 'socket');
      _onError?.call('Error while searching for nearby drivers');
    }
  }

  bool _checkConnection() {
    if (!_initialized || !socket.connected) {
      _onError?.call(
          !_initialized ? 'Socket not initialized' : 'Not connected to server');
      return false;
    }
    return true;
  }

  void dispose() {
    _epoch++;
    if (_initialized) {
      socket.dispose();
      _initialized = false;
    }
    _clearCallbacks();
  }

  void reconnect() {
    if (_initialized && !socket.connected) socket.connect();
  }

  void _clearCallbacks() {
    _onNearbyDrivers = null;
    _onRideAccepted = null;
    _onRideStarted = null;
    _onRideArrived = null;
    _onRideRejected = null;
    _onRideStatusUpdate = null;
    _onRideCompleted = null;
    _onDriverLocation = null;
    _typingStatus = null;
    _onMessageReceived = null;
    _onError = null;
    _onConnected = null;
    _onDisconnected = null;
  }

  bool get isConnected => _initialized && socket.connected;
}
