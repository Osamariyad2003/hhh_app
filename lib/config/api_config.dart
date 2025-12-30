import 'dart:io';

/// API Configuration
/// 
/// Handles different base URLs for development and production.
/// 
/// **Usage:**
/// 1. Set `isDevelopment = true` for localhost development
/// 2. Set `localhostPort` to your backend server port (e.g., 3000, 8000, 5000)
/// 3. The config automatically uses the correct localhost URL for each platform:
///    - Android Emulator: `http://10.0.2.2:PORT/api/`
///    - iOS Simulator: `http://localhost:PORT/api/`
///    - Desktop/Web: `http://localhost:PORT/api/`
/// 
/// **For Physical Devices:**
/// If testing on a physical device, you'll need to:
/// 1. Find your computer's IP address (e.g., `192.168.1.100`)
/// 2. Make sure your device and computer are on the same network
/// 3. Temporarily modify `getLocalhostUrl()` to return your IP address
/// 
/// **Example:**
/// ```dart
/// // For physical device testing
/// return 'http://192.168.1.100:$port/api/';
/// ```
class ApiConfig {
  static const bool isDevelopment = true;
  
  static const String productionBaseUrl = 'http://localhost:3000/api/';

  static const int localhostPort = 3000;
  
  static String get baseUrl {
    if (isDevelopment) {
      return getLocalhostUrl(localhostPort);
    }
    return productionBaseUrl;
  }
  
  static String getLocalhostUrl(int port) {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$port/api/';
    } else if (Platform.isIOS) {
      return 'http://localhost:$port/api/';
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'http://localhost:$port/api/';
    } else {
      return 'http://localhost:$port/api/';
    }
  }
  
  static String get developmentBaseUrl {
    return getLocalhostUrl(localhostPort);
  }
}

