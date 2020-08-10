import 'package:package_info/package_info.dart';

class AppVersion {
  String version;
  String buildNumber;

  AppVersion({
    this.version,
    this.buildNumber,
  });

  factory AppVersion.fromJson(
    Map<dynamic, dynamic> json,
  ) {
    if (json == null) {
      return null;
    }

    return AppVersion(
      version: json['version'],
      buildNumber: json['build_number'],
    );
  }

  AppVersion fromPackageInfo(
    PackageInfo packageInfo,
  ) {
    if (packageInfo == null) {
      return null;
    }

    return AppVersion(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }

  Map<String, dynamic> toMap(
    AppVersion version,
  ) {
    if (version == null) {
      return null;
    }

    Map<String, dynamic> versionMap = Map<String, dynamic>();
    versionMap['version'] = version.version;
    versionMap['build_number'] = version.buildNumber;
    return versionMap;
  }
}
