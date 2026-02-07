import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'ai_service.dart';

/// Service for communicating with the Tiny Steps backend API
class BackendService {
  static const String _baseUrl = 'https://tinysteps-api.pardom-89.workers.dev';
  static const String _tokenKey = 'backend_token';
  static const String _deviceIdKey = 'backend_device_id';
  
  String? _token;
  String? _deviceId;
  bool _initialized = false;
  
  /// Initialize the service and register if needed
  Future<void> initialize() async {
    if (_initialized) return;
    
    final box = await Hive.openBox<String>('backend');
    _token = box.get(_tokenKey);
    _deviceId = box.get(_deviceIdKey);
    
    // Register if we don't have a token
    if (_token == null) {
      await _register();
    }
    
    _initialized = true;
  }
  
  /// Register a new device and get a token
  Future<void> _register() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/register'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _deviceId = data['deviceId'];
        
        // Save to storage
        final box = await Hive.openBox<String>('backend');
        await box.put(_tokenKey, _token!);
        await box.put(_deviceIdKey, _deviceId!);
      }
    } catch (e) {
      // Registration failed - will use mock data
    }
  }
  
  /// Decompose a task using the backend API
  /// Returns null if backend is unavailable (caller should fall back to mock)
  Future<Map<String, dynamic>?> decomposeTask(
    String taskDescription, {
    DecompositionStyle style = DecompositionStyle.standard,
  }) async {
    await initialize();
    
    if (_token == null) return null;
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/decompose'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'task': taskDescription,
          'style': style.name,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        }
      } else if (response.statusCode == 429) {
        // Rate limited
        final data = jsonDecode(response.body);
        throw RateLimitException(
          data['error'] ?? 'Rate limit exceeded',
          data['remaining'] ?? 0,
          data['resetAt'] != null 
              ? DateTime.parse(data['resetAt']) 
              : DateTime.now().add(const Duration(hours: 24)),
        );
      } else if (response.statusCode == 401) {
        // Token expired - re-register
        _token = null;
        await _register();
        // Retry once
        return decomposeTask(taskDescription, style: style);
      }
      
      return null;
    } catch (e) {
      if (e is RateLimitException) rethrow;
      return null;
    }
  }
  
  /// Get current usage stats
  Future<UsageStats?> getUsage() async {
    await initialize();
    
    if (_token == null) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/usage'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UsageStats(
          used: data['used'] ?? 0,
          limit: data['limit'] ?? 3,
          remaining: data['remaining'] ?? 3,
          isPremium: data['isPremium'] ?? false,
          resetAt: data['resetAt'] != null 
              ? DateTime.parse(data['resetAt']) 
              : null,
        );
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Verify a subscription purchase with the backend
  Future<bool> verifySubscription({
    required String userId,
    required String productId,
    required String transactionId,
    required String platform,
  }) async {
    await initialize();
    
    if (_token == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/verify-subscription'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'userId': userId,
          'productId': productId,
          'transactionId': transactionId,
          'platform': platform,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Update token if we got a new one (with premium status)
        if (data['token'] != null) {
          _token = data['token'];
          final box = await Hive.openBox<String>('backend');
          await box.put(_tokenKey, _token!);
        }
        
        return data['isPremium'] == true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Usage statistics from the backend
class UsageStats {
  final int used;
  final int limit;
  final int remaining;
  final bool isPremium;
  final DateTime? resetAt;
  
  UsageStats({
    required this.used,
    required this.limit,
    required this.remaining,
    required this.isPremium,
    this.resetAt,
  });
}

/// Exception thrown when rate limit is exceeded
class RateLimitException implements Exception {
  final String message;
  final int remaining;
  final DateTime resetAt;
  
  RateLimitException(this.message, this.remaining, this.resetAt);
  
  @override
  String toString() => message;
}
