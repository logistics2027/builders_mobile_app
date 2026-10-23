// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';

// class VersionCheckService {
//   static Future<Map<String, dynamic>> parseVersionConfig(String versionCheckJson) async {
//     try {
//       // remove any trailing commas before }
//       final fixedJson = versionCheckJson.replaceAll(RegExp(r',\s*}'), '}');

//       return jsonDecode(fixedJson);
//     } catch (e) {
//       debugPrint("❌ Failed to parse version_check: $e");
//       return {};
//     }
//   }


//   static Future<String> getCurrentAppVersion() async {
//     final info = await PackageInfo.fromPlatform();
//     return info.version; // e.g. "1.2.0"
//   }

//   static Future<int> getCurrentBuildNumber() async {
//     final info = await PackageInfo.fromPlatform();
//     return int.tryParse(info.buildNumber) ?? 0; // e.g. 12
//   }

//   static Future<void> launchPlayStore(String packageName) async {
//     final url = Uri.parse("https://play.google.com/store/apps/details?id=$packageName");
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } else {
//       throw "Could not launch $url";
//     }
//   }

//   static Future<void> launchAppStore(String appId) async {
//     final url = Uri.parse("https://apps.apple.com/app/id$appId");
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } else {
//       throw "Could not launch $url";
//     }
//   }

// }


import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionCheckService {
  static Future<Map<String, dynamic>> parseVersionConfig(String versionCheckJson) async {
    try {
      // remove any trailing commas before }
      final fixedJson = versionCheckJson.replaceAll(RegExp(r',\s*}'), '}');

      return jsonDecode(fixedJson);
    } catch (e) {
      debugPrint("❌ Failed to parse version_check: $e");
      return {};
    }
  }

  static Future<String> getCurrentAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version; // e.g. "1.2.0"
  }

  static Future<int> getCurrentBuildNumber() async {
    final info = await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber) ?? 0; // e.g. 12
  }

  /// Returns true if [current] (e.g. "1.2.3") is lower than [latest].
  static bool isVersionLower(String current, String latest) {
    final cur = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final lat = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLength = cur.length > lat.length ? cur.length : lat.length;

    for (int i = 0; i < maxLength; i++) {
      final c = i < cur.length ? cur[i] : 0;
      final l = i < lat.length ? lat[i] : 0;
      if (c < l) return true;
      if (c > l) return false;
    }
    return false;
  }

  static Future<void> launchPlayStore(String packageName) async {
    final url = Uri.parse("https://play.google.com/store/apps/details?id=$packageName");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $url";
    }
  }

  static Future<void> launchAppStore(String appId) async {
    if (appId.trim().isEmpty) return;
    final url = Uri.parse("https://apps.apple.com/app/id$appId");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $url";
    }
  }
}