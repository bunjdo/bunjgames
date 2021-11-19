import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'settings.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';


Uint8List int32BigEndianBytes(int value) =>
    Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);

Uint8List int32LittleEndianBytes(int value) =>
    Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.little);


class UDPService {

  static final UDPService _singleton = UDPService._internal();

  factory UDPService() {
    return _singleton;
  }

  late bool _useUDP;
  late InternetAddress _udpIP;
  late int _udpPort;
  RawDatagramSocket? _socket;

  UDPService._internal() {
    this.init();
  }

  Future<void> init() async {
    this._useUDP = (await SettingsService.getInstance()).getBool(SettingsType.USE_UDP_IP);
    var udpIP = (await SettingsService.getInstance()).getString(SettingsType.UDP_IP);
    this._udpPort = (await SettingsService.getInstance()).getInt(SettingsType.UDP_PORT);
    if (udpIP == SettingsType.UDP_IP.defaultValue) {
      var wifiIP = await WifiInfo().getWifiIP();
      if (wifiIP != null) {
        var splitWifiIP = wifiIP.split(".");
        splitWifiIP[splitWifiIP.length - 1] = "255";
        var newIP = splitWifiIP.join(".");
        print("Using UPD IP $newIP:$_udpPort");
        this._udpIP = InternetAddress(newIP);
      } else {
        print("Cannot get local IP for UPD service");
        this._udpIP = InternetAddress("0.0.0.0");
        this._useUDP = false;
      }
    } else {
      this._udpIP = InternetAddress(udpIP);
    }

    this._socket?.close();
    if (_useUDP) {
      this._socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _udpPort);
      this._socket!.broadcastEnabled = true;
      print("UPD socket opened");
    }
  }

  void close() {
    this._socket?.close();
  }

  Future<void> send(int playerId) async {
    _socket?.send(utf8.encode(playerId.toString()), this._udpIP, this._udpPort);
  }

}
