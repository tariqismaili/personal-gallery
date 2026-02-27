import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._internal();
  SettingsService._internal();

  SharedPreferences? _prefs;

static const String _keyServerIp = 'server_ip';
static const String _keyServerPort = 'server_port';
  static const String _defaultIp = '10.10.10.221';
  static const String _defaultPort = '8000';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String get serverIp => _prefs?.getString(_keyServerIp) ?? _defaultIp;
  String get serverPort => _prefs?.getString(_keyServerPort) ?? _defaultPort;

  String get baseUrl => 'http://$serverIp:$serverPort';

  Future<void> setServerIp(String ip) async {
    await _prefs?.setString(_keyServerIp, ip);
  }

  Future<void> setServerPort(String port) async {
    await _prefs?.setString(_keyServerPort, port);
  }
}
