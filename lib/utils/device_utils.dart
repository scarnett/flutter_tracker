import 'package:device_info/device_info.dart';

Map<String, dynamic> readAndroidBuildData(
  AndroidDeviceInfo build,
) {
  return <String, dynamic>{
    'version_security_patch': build.version.securityPatch,
    'version_sdk_int': build.version.sdkInt,
    'version_release': build.version.release,
    'version_preview_sdk_int': build.version.previewSdkInt,
    'version_incremental': build.version.incremental,
    'version_codename': build.version.codename,
    'version_base_os': build.version.baseOS,
    'board': build.board,
    'bootloader': build.bootloader,
    'brand': build.brand,
    'device': build.device,
    'display': build.display,
    'fingerprint': build.fingerprint,
    'hardware': build.hardware,
    'host': build.host,
    'id': build.id,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    'supported_32_bit_abis': build.supported32BitAbis,
    'supported_64_bit_abis': build.supported64BitAbis,
    'supported_abis': build.supportedAbis,
    'tags': build.tags,
    'type': build.type,
    'is_physical_device': build.isPhysicalDevice,
    'android_id': build.androidId,
  };
}

Map<String, dynamic> readIosDeviceInfo(
  IosDeviceInfo data,
) {
  return <String, dynamic>{
    'name': data.name,
    'system_name': data.systemName,
    'system_version': data.systemVersion,
    'model': data.model,
    'localized_model': data.localizedModel,
    'identifier_for_vendor': data.identifierForVendor,
    'is_physical_device': data.isPhysicalDevice,
    'utsname_sysname:': data.utsname.sysname,
    'utsname_nodename:': data.utsname.nodename,
    'utsname_release:': data.utsname.release,
    'utsname_version:': data.utsname.version,
    'utsname_machine:': data.utsname.machine,
  };
}
