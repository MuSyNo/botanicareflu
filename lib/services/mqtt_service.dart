import 'dart:async';
import 'package:flutter/foundation.dart';
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
      debugPrint('ℹ️ MQTT is already connected.');
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
        debugPrint('✅ MQTT connected to $broker');

        if (topics != null) {
          for (final topic in topics.toSet()) {
            client.subscribe(topic, MqttQos.atMostOnce);
          }
        } else {
          _subscribeToDefaultTopics();
        }

        _bindMessageListener();
      } else {
        debugPrint('❌ MQTT failed to connect: ${client.connectionStatus}');
        disconnect();
      }
    } catch (e) {
      debugPrint('❌ MQTT connection exception: $e');
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

        debugPrint('📩 [MQTT] Received [$topic]: $payload');
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
      debugPrint("⚠️ MQTT not connected. Cannot publish to $topic");
      return;
    }

    final builder = MqttClientPayloadBuilder()..addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    debugPrint('📤 [MQTT] Published [$topic]: $message');
  }

  /// Disconnect from broker
  void disconnect() {
    try {
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        client.disconnect();
        debugPrint('🔌 [MQTT] Disconnected cleanly');
      }
    } catch (e) {
      debugPrint('❌ Error during MQTT disconnect: $e');
    } finally {
      _connected = false;
    }
  }

  void _onDisconnected() {
    debugPrint('⚠️ [MQTT] Disconnected unexpectedly');
    _connected = false;
  }

  void _onConnected() {
    debugPrint('✅ [MQTT] Connection established');
    _connected = true;
  }

  void _onSubscribed(String topic) {
    debugPrint('🔔 [MQTT] Subscribed to $topic');
  }
}