import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/foundation.dart';

class MQTTManager {
  final MqttServerClient client;
  final String clientId;

  /// Callback for received messages
  Function(String topic, String message)? onMessage;

  final Set<String> _subscribedTopics = {};

  MQTTManager({required this.clientId})
      : client = MqttServerClient.withPort('broker.hivemq.com', clientId, 1883) {
    client
      ..logging(on: false)
      ..keepAlivePeriod = 20
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed;

    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
  }

  Future<void> connect() async {
    try {
      await client.connect();

      final status = client.connectionStatus?.state;
      if (status == MqttConnectionState.connected) {
        debugPrint('✅ MQTT connection successful');
        _listenToMessages();
      } else {
        debugPrint('❌ MQTT connection failed: $status');
        disconnect();
      }
    } catch (e) {
      debugPrint('❌ MQTT connection error: $e');
      disconnect();
    }
  }

  void disconnect() {
    try {
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        client.disconnect();
        debugPrint('🔌 MQTT disconnected');
      }
    } catch (e) {
      debugPrint('⚠️ Error during disconnect: $e');
    }
  }

  void publish(String topic, String message) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder()..addString(message);
      final payload = builder.payload;
      if (payload != null) {
        client.publishMessage(topic, MqttQos.atMostOnce, payload);
        debugPrint('📤 Published to [$topic]: $message');
      } else {
        debugPrint('⚠️ Cannot publish null payload.');
      }
    } else {
      debugPrint('⚠️ Cannot publish. MQTT not connected.');
    }
  }

  void subscribe(String topic) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      if (_subscribedTopics.add(topic)) {
        client.subscribe(topic, MqttQos.atMostOnce);
        debugPrint('📡 Subscribed to $topic');
      } else {
        debugPrint('⚠️ Already subscribed to $topic');
      }
    } else {
      debugPrint('⚠️ Cannot subscribe. MQTT not connected.');;
    }
  }

  void _listenToMessages() {
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>>? events) {
      if (events == null || events.isEmpty) return;

      for (var event in events) {
        final msg = event.payload as MqttPublishMessage?;
        if (msg == null) continue;

        final topic = event.topic;
        final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.message);
        debugPrint('📩 Received [$topic]: $payload');
        onMessage?.call(topic, payload);
      }
    });
  }

  static void _onConnected() => debugPrint('✅ Connected to MQTT');
  static void _onDisconnected() => debugPrint('🔌 Disconnected from MQTT');
  static void _onSubscribed(String topic) => debugPrint('🔔 Subscribed to $topic');
}
