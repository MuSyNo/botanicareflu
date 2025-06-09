import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final String broker = 'broker.hivemq.com';
  final int port = 1883;
  final String clientId = 'botanicare_flutter_client_${DateTime.now().millisecondsSinceEpoch}';

  late MqttServerClient client;
  bool _connected = false;
  bool get isConnected => _connected;

  /// Callback for received messages
  Function(String topic, String message)? onMessageReceived;

  /// Connect to the MQTT broker
  Future<void> connect({List<String>? topics}) async {
    if (_connected) {
      print('ℹ️ MQTT is already connected.');
      return;
    }

    client = MqttServerClient(broker, clientId)
      ..port = port
      ..logging(on: false)
      ..keepAlivePeriod = 20
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed;

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    try {
      await client.connect();
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        _connected = true;
        print('✅ MQTT connected to $broker');

        if (topics != null) {
          for (final topic in topics.toSet()) {
            client.subscribe(topic, MqttQos.atMostOnce);
          }
        } else {
          _subscribeToDefaultTopics();
        }

        _bindMessageListener();
      } else {
        print('❌ MQTT failed to connect: ${client.connectionStatus}');
        disconnect();
      }
    } catch (e) {
      print('❌ MQTT connection exception: $e');
      disconnect();
    }
  }

  void _subscribeToDefaultTopics() {
    const defaultTopics = [
      'irrigation/sensors/soil_moisture/device_id_1',
      'irrigation/sensors/temperature/device_id_1',
      'irrigation/sensors/battery/device_id_1',
    ];
    for (final topic in defaultTopics) {
      client.subscribe(topic, MqttQos.atMostOnce);
    }
  }

  void _bindMessageListener() {
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>>? messages) {
      if (messages == null || messages.isEmpty) return;

      for (final message in messages) {
        final recMessage = message.payload as MqttPublishMessage;
        final topic = message.topic;
        final payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

        print('📩 [MQTT] Received [$topic]: $payload');
        onMessageReceived?.call(topic, payload);
      }
    });
  }

  /// Publish valve control message
  void publishValveCommand(String message) {
    publish('irrigation/control/device_id_1/start', message);
  }

  /// Publish to a custom topic
  void publishCustomCommand(String topic, String message) {
    publish(topic, message);
  }

  /// Generic publish method
  void publish(String topic, String message) {
    if (!_connected) {
      print("⚠️ MQTT not connected. Cannot publish to $topic");
      return;
    }

    final builder = MqttClientPayloadBuilder()..addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    print('📤 [MQTT] Published [$topic]: $message');
  }

  /// Disconnect from broker
  void disconnect() {
    try {
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        client.disconnect();
        print('🔌 [MQTT] Disconnected cleanly');
      }
    } catch (e) {
      print('❌ Error during MQTT disconnect: $e');
    } finally {
      _connected = false;
    }
  }

  void _onDisconnected() {
    print('⚠️ [MQTT] Disconnected unexpectedly');
    _connected = false;
  }

  void _onConnected() {
    print('✅ [MQTT] Connection established');
    _connected = true;
  }

  void _onSubscribed(String topic) {
    print('🔔 [MQTT] Subscribed to $topic');
  }
}
