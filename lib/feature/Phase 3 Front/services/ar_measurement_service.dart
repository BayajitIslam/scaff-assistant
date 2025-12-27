import 'dart:async';
import 'package:flutter/services.dart';

class ArMeasurementService {
  static const MethodChannel _channel = MethodChannel('com.ssaprktech.scaffassistant/ar_measurement');
  
  // Callbacks
  Function(bool)? onPlaneDetected;
  Function(Map<String, double>)? onPointAdded;
  Function(double)? onDistanceCalculated;
  Function(String)? onError;
  Function(int)? onPointCount;

  ArMeasurementService() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onPlaneDetected':
        onPlaneDetected?.call(call.arguments as bool);
        break;
      case 'onPointAdded':
        onPointAdded?.call(Map<String, double>.from(call.arguments));
        break;
      case 'onDistanceCalculated':
        onDistanceCalculated?.call((call.arguments as num).toDouble());
        break;
      case 'onPointCount':
        onPointCount?.call(call.arguments as int);
        break;
      case 'onError':
        onError?.call(call.arguments as String);
        break;
    }
  }

  Future<bool> initialize() async {
    try {
      final result = await _channel.invokeMethod<bool>('initialize');
      return result ?? false;
    } on PlatformException catch (e) {
      onError?.call(e.message ?? 'Failed to initialize AR');
      return false;
    } catch (e) {
      onError?.call(e.toString());
      return false;
    }
  }

  Future<void> addPoint() async {
    try {
      await _channel.invokeMethod('addPoint');
    } on PlatformException catch (e) {
      onError?.call(e.message ?? 'Failed to add point');
    }
  }

  Future<void> undo() async {
    try {
      await _channel.invokeMethod('undo');
    } on PlatformException catch (e) {
      onError?.call(e.message ?? 'Failed to undo');
    }
  }

  Future<void> clear() async {
    try {
      await _channel.invokeMethod('clear');
    } on PlatformException catch (e) {
      onError?.call(e.message ?? 'Failed to clear');
    }
  }

  Future<Uint8List?> takeSnapshot() async {
    try {
      final result = await _channel.invokeMethod<Uint8List>('snapshot');
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('dispose');
    } catch (e) {
      // Ignore
    }
  }

  static Future<bool> isSupported() async {
    try {
      final result = await _channel.invokeMethod<bool>('isSupported');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}