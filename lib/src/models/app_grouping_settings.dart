import 'cluster_settings.dart';

class AppGroupingSettings {
  const AppGroupingSettings({
    this.defaultSmartGroupingLevel = SmartGroupingLevel.balanced,
    this.defaultSeparateOddEven = true,
    this.batchCropRecursive = false,
    this.useOriginalFileNameForExport = false,
    this.allowCropOutsidePage = false,
    this.scaleWithWindowResize = false,
  });

  final SmartGroupingLevel defaultSmartGroupingLevel;
  final bool defaultSeparateOddEven;
  final bool batchCropRecursive;
  final bool useOriginalFileNameForExport;
  final bool allowCropOutsidePage;
  final bool scaleWithWindowResize;

  AppGroupingSettings copyWith({
    SmartGroupingLevel? defaultSmartGroupingLevel,
    bool? defaultSeparateOddEven,
    bool? batchCropRecursive,
    bool? useOriginalFileNameForExport,
    bool? allowCropOutsidePage,
    bool? scaleWithWindowResize,
  }) {
    return AppGroupingSettings(
      defaultSmartGroupingLevel:
          defaultSmartGroupingLevel ?? this.defaultSmartGroupingLevel,
      defaultSeparateOddEven:
          defaultSeparateOddEven ?? this.defaultSeparateOddEven,
      batchCropRecursive: batchCropRecursive ?? this.batchCropRecursive,
      useOriginalFileNameForExport:
          useOriginalFileNameForExport ?? this.useOriginalFileNameForExport,
      allowCropOutsidePage:
          allowCropOutsidePage ?? this.allowCropOutsidePage,
      scaleWithWindowResize:
          scaleWithWindowResize ?? this.scaleWithWindowResize,
    );
  }
}
