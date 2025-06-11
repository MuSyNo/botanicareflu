import 'package:flutter/material.dart';
import 'package:botanicareflu/gen_l10n/app_localizations.dart';

import '../app_colors.dart';
import '../services/mqtt_service.dart';

class IrrigationControlScreen extends StatefulWidget {
  const IrrigationControlScreen({super.key});

  @override
  State<IrrigationControlScreen> createState() => _IrrigationControlScreenState();
}

class _IrrigationControlScreenState extends State<IrrigationControlScreen> {
  final mqtt = MqttService();
  bool isIrrigating = false;
  int irrigationDuration = 15; // seconds
  bool autoMode = false;
  int moistureThreshold = 30; // percent

  void _toggleIrrigation() {
    final newState = !isIrrigating;
    if (mqtt.isConnected) {
      mqtt.publishValveCommand(newState ? '1' : '0');
    }
    setState(() => isIrrigating = newState);
  }

  @override
  void dispose() {
    mqtt.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(t.irrigation),
        backgroundColor: AppColors.forestGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModeSelector(t),
            const SizedBox(height: 16),
            _buildStatusCard(t),
            const SizedBox(height: 16),
            autoMode ? _buildMoistureThresholdSlider(t) : _buildDurationSlider(t),
            const SizedBox(height: 20),
            if (!autoMode) _buildIrrigationButton(t),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(AppLocalizations t) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.irrigationMode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(t.autoMode),
                    value: true,
                    groupValue: autoMode,
                    onChanged: (val) => setState(() => autoMode = val ?? false),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(t.manualMode),
                    value: false,
                    groupValue: autoMode,
                    onChanged: (val) => setState(() => autoMode = val ?? false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations t) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: const Icon(Icons.info_outline, color: AppColors.tealBlue, size: 36),
        title: Text(t.status, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isIrrigating ? t.active : t.idle),
        trailing: Icon(Icons.circle, color: isIrrigating ? Colors.green : Colors.grey, size: 16),
      ),
    );
  }

  Widget _buildDurationSlider(AppLocalizations t) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.irrigationDuration, style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: irrigationDuration.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              label: '$irrigationDuration seconds',
              activeColor: AppColors.forestGreen,
              onChanged: (value) => setState(() => irrigationDuration = value.toInt()),
              onChangeEnd: (value) {
                if (mqtt.isConnected) {
                  mqtt.publishCustomCommand("irrigation/settings/duration", value.toInt().toString());
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoistureThresholdSlider(AppLocalizations t) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.setThreshold, style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: moistureThreshold.toDouble(),
              min: 10,
              max: 80,
              divisions: 14,
              label: '$moistureThreshold%',
              activeColor: AppColors.forestGreen,
              onChanged: (value) => setState(() => moistureThreshold = value.toInt()),
              onChangeEnd: (value) {
                if (mqtt.isConnected) {
                  mqtt.publishCustomCommand(
                    'irrigation/settings/moisture_threshold',
                    value.toInt().toString(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${t.setThreshold} → ${value.toInt()}%')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIrrigationButton(AppLocalizations t) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(isIrrigating ? Icons.pause : Icons.water),
        label: Text(isIrrigating ? t.stopIrrigation : t.startIrrigation),
        onPressed: _toggleIrrigation,
        style: ElevatedButton.styleFrom(
          backgroundColor: isIrrigating ? Colors.red.shade700 : AppColors.forestGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
