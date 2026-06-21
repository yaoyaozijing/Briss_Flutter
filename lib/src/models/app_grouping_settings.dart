import 'cluster_settings.dart';

class AppGroupingSettings {
  const AppGroupingSettings({
    this.defaultSmartGroupingLevel = SmartGroupingLevel.balanced,
    this.defaultSeparateOddEven = true,
    this.batchCropRecursive = false,
    this.useOriginalFileNameForExport = false,
  });

  final SmartGroupingLevel defaultSmartGroupingLevel;
  final bool defaultSeparateOddEven;
  final bool batchCropRecursive;
  final bool useOriginalFileNameForExport;

  AppGroupingSettings copyWith({
    SmartGroupingLevel? defaultSmartGroupingLevel,
    bool? defaultSeparateOddEven,
    bool? batchCropRecursive,
    bool? useOriginalFileNameForExport,
  }) {
    return AppGroupingSettings(
      defaultSmartGroupingLevel:
          defaultSmartGroupingLevel ?? this.defaultSmartGroupingLevel,
      defaultSeparateOddEven:
          defaultSeparateOddEven ?? this.defaultSeparateOddEven,
      batchCropRecursive: batchCropRecursive ?? this.batchCropRecursive,
      useOriginalFileNameForExport:
          useOriginalFileNameForExport ?? this.useOriginalFileNameForExport,
    );
  }
}
