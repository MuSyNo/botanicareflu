import 'package:flutter/material.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final String label;
  final bool connected;
  final VoidCallback? onRetry;
  final bool isChecking;

  const ConnectionStatusWidget({
    super.key,
    required this.label,
    required this.connected,
    this.onRetry,
    this.isChecking = false,
  });

  @override
  Widget build(BuildContext context) {
    final isESP = label.trim().toLowerCase().contains('esp32');
    final theme = Theme.of(context);
    final statusText = connected ? "Connected" : "Disconnected";

    return Semantics(
      label: "$label connection status: $statusText",
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: Icon(
            isESP ? Icons.device_hub : Icons.wifi,
            color: connected ? Colors.green : Colors.red,
          ),
          title: Text(
            "$label Connection",
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(statusText),
          trailing: onRetry != null
              ? IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isChecking ? "Checking..." : "Retry",
            onPressed: isChecking ? null : onRetry,
          )
              : null,
        ),
      ),
    );
  }
}

class SensorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const SensorCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(icon, size: 36, color: color),
        title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
        trailing: Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
