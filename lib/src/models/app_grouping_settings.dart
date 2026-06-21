import 'cluster_settings.dart';

class AppGroupingSettings {
  const AppGroupingSettings({
    this.defaultSmartGroupingLevel = SmartGroupingLevel.balanced,
  });

  final SmartGroupingLevel defaultSmartGroupingLevel;

  AppGroupingSettings copyWith({
    SmartGroupingLevel? defaultSmartGroupingLevel,
  }) {
    return AppGroupingSettings(
      defaultSmartGroupingLevel:
          defaultSmartGroupingLevel ?? this.defaultSmartGroupingLevel,
    );
  }
}
