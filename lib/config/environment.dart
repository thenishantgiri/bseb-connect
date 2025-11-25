import 'package:flutter/foundation.dart';

/// Environment configuration for different deployment stages
/// This replaces hardcoded values and allows easy switching between environments
class Environment {
  static const String _dev = 'development';
  static const String _staging = 'staging';
  static const String _prod = 'production';

  /// Current environment - change this for different deployments
  /// You can also set this via build flags or environment variables
  static const String current = _dev;

  /// Check if running in development
  static bool get isDevelopment => current == _dev;

  /// Check if running in staging
  static bool get isStaging => current == _staging;

  /// Check if running in production
  static bool get isProduction => current == _prod;

  /// Check if running in debug mode
  static bool get isDebugMode => kDebugMode;

  /// Get the appropriate base URL for the current environment
  static String get baseUrl {
    switch (current) {
      case _dev:
        return 'http://bseb-backend.mvpl.info:3000/'; // Development server
      case _staging:
        return 'http://bseb-backend.mvpl.info:3000/'; // Staging server
      case _prod:
        return 'http://bseb-backend.mvpl.info:3000/'; // Production server
      default:
        return 'http://bseb-backend.mvpl.info:3000/';
    }
  }

  /// Legacy API URL (if still needed)
  static String get legacyApiUrl {
    switch (current) {
      case _dev:
        return 'https://registrationapi.bsebmarks.in/api/MaterialApi';
      case _staging:
        return 'https://staging-registrationapi.bsebmarks.in/api/MaterialApi';
      case _prod:
        return 'https://registrationapi.bsebmarks.in/api/MaterialApi';
      default:
        return 'https://registrationapi.bsebmarks.in/api/MaterialApi';
    }
  }

  /// Get Firebase configuration based on environment
  static Map<String, dynamic> get firebaseConfig {
    switch (current) {
      case _dev:
        return {
          'enabled': true,
          'crashlytics': false, // Disable crashlytics in development
          'analytics': false, // Disable analytics in development
          'performance': false, // Disable performance monitoring in dev
        };
      case _staging:
        return {
          'enabled': true,
          'crashlytics': true,
          'analytics': true,
          'performance': false, // Optional in staging
        };
      case _prod:
        return {
          'enabled': true,
          'crashlytics': true,
          'analytics': true,
          'performance': true,
        };
      default:
        return {'enabled': false};
    }
  }

  /// API timeout configurations
  static Duration get connectTimeout {
    switch (current) {
      case _dev:
        return const Duration(seconds: 60); // Longer timeout for development
      case _staging:
        return const Duration(seconds: 30);
      case _prod:
        return const Duration(seconds: 15); // Shorter timeout for production
      default:
        return const Duration(seconds: 30);
    }
  }

  static Duration get receiveTimeout {
    switch (current) {
      case _dev:
        return const Duration(seconds: 60);
      case _staging:
        return const Duration(seconds: 30);
      case _prod:
        return const Duration(seconds: 15);
      default:
        return const Duration(seconds: 30);
    }
  }

  /// Logging configuration
  static bool get enableLogging {
    switch (current) {
      case _dev:
        return true; // Always enable in development
      case _staging:
        return true; // Enable in staging for debugging
      case _prod:
        return false; // Disable in production
      default:
        return kDebugMode;
    }
  }

  /// Feature flags
  static Map<String, bool> get features {
    switch (current) {
      case _dev:
        return {
          'biometric_auth': true,
          'offline_mode': true,
          'push_notifications': true,
          'analytics': false,
          'crash_reporting': false,
          'performance_monitoring': false,
          'remote_config': false,
          'in_app_updates': false,
        };
      case _staging:
        return {
          'biometric_auth': true,
          'offline_mode': true,
          'push_notifications': true,
          'analytics': true,
          'crash_reporting': true,
          'performance_monitoring': true,
          'remote_config': true,
          'in_app_updates': false,
        };
      case _prod:
        return {
          'biometric_auth': true,
          'offline_mode': true,
          'push_notifications': true,
          'analytics': true,
          'crash_reporting': true,
          'performance_monitoring': true,
          'remote_config': true,
          'in_app_updates': true,
        };
      default:
        return {};
    }
  }

  /// Get environment-specific app name
  static String get appName {
    switch (current) {
      case _dev:
        return 'BSEB Connect (Dev)';
      case _staging:
        return 'BSEB Connect (Staging)';
      case _prod:
        return 'BSEB Connect';
      default:
        return 'BSEB Connect';
    }
  }

  /// Check if a specific feature is enabled
  static bool isFeatureEnabled(String feature) {
    return features[feature] ?? false;
  }

  /// Get environment display name
  static String get displayName {
    switch (current) {
      case _dev:
        return 'Development';
      case _staging:
        return 'Staging';
      case _prod:
        return 'Production';
      default:
        return 'Unknown';
    }
  }

  /// Security configurations
  static Map<String, dynamic> get security {
    return {
      'enable_certificate_pinning': isProduction,
      'enable_root_detection': isProduction,
      'enable_jailbreak_detection': isProduction,
      'enable_app_integrity': isProduction,
      'enable_code_obfuscation': isProduction,
      'min_tls_version': isProduction ? 'TLS 1.3' : 'TLS 1.2',
    };
  }
}