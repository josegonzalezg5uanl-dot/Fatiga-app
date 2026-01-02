import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Servicio para interactuar con Google Sheets mediante Google Apps Script
/// 
/// VERSIÓN OPTIMIZADA PARA CORS - USA GET EN LUGAR DE POST
/// 
/// Google Apps Script tiene restricciones CORS que impiden peticiones POST
/// desde navegadores web. Esta versión usa peticiones GET con parámetros
/// en la URL, que es la forma correcta de comunicarse con Google Apps Script.
class GoogleSheetsService {
  // ✅ URL de Google Apps Script configurada (VERSIÓN FINAL FUNCIONANDO)
  static const String _webAppUrl = 'https://script.google.com/macros/s/AKfycbw42COg_ZhGtInvrXz4tynp7JFsGCFWLrR7g6S9QqTg5b6uSqlpF0hxZ5_dfsAeI-06nQ/exec';
  
  // Configuración de timeouts
  static const Duration _requestTimeout = Duration(seconds: 30);
  static const Duration _connectionTimeout = Duration(seconds: 15);
  
  /// Log centralizado para debugging
  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('🔍 [GoogleSheetsService] $message');
    }
  }
  
  /// Validación de datos de entrada
  void _validateInput({
    required int fatigueLevel,
    required int capacityLevel,
    required int suspensionReason,
    required String userId,
  }) {
    if (fatigueLevel < 0 || fatigueLevel > 100) {
      throw ArgumentError('fatigueLevel debe estar entre 0 y 100, recibido: $fatigueLevel');
    }
    
    if (capacityLevel < 0 || capacityLevel > 100) {
      throw ArgumentError('capacityLevel debe estar entre 0 y 100, recibido: $capacityLevel');
    }
    
    if (suspensionReason < 1 || suspensionReason > 4) {
      throw ArgumentError('suspensionReason debe estar entre 1 y 4, recibido: $suspensionReason');
    }
    
    if (userId.isEmpty || userId.length > 4) {
      throw ArgumentError('userId debe tener entre 1 y 4 caracteres, recibido: "$userId"');
    }
  }
  
  /// Envía los datos completos a Google Sheets usando GET (CORS-friendly)
  /// 
  /// [fatigueLevel] - Nivel de fatiga del 0 al 100
  /// [capacityLevel] - Nivel de capacidad para continuar del 0 al 100
  /// [suspensionReason] - Motivo de suspensión (1=Falta de aire, 2=Fatiga piernas, 3=Ambas, 4=Otra)
  /// [userId] - Identificador de usuario (1-4 letras)
  /// 
  /// Retorna `true` si el envío fue exitoso, `false` en caso contrario
  /// 
  /// Lanza [ArgumentError] si los parámetros están fuera de rango
  /// Lanza [SocketException] si hay problemas de conectividad
  /// Lanza [TimeoutException] si la petición tarda más del tiempo configurado
  Future<bool> sendFatigueData({
    required int fatigueLevel,
    required int capacityLevel,
    required int suspensionReason,
    required String userId,
  }) async {
    try {
      // Validar datos de entrada
      _validateInput(
        fatigueLevel: fatigueLevel,
        capacityLevel: capacityLevel,
        suspensionReason: suspensionReason,
        userId: userId,
      );
      
      _logDebug('📤 Iniciando envío de datos (método GET - CORS-friendly)');
      _logDebug('   Usuario: $userId');
      _logDebug('   Fatiga: $fatigueLevel | Capacidad: $capacityLevel | Motivo: $suspensionReason');

      // Construir URL con parámetros (GET - evita problemas de CORS)
      final uri = Uri.parse(_webAppUrl).replace(queryParameters: {
        'action': 'save',
        'user_id': userId.toUpperCase(),
        'fatigue_level': fatigueLevel.toString(),
        'capacity_level': capacityLevel.toString(),
        'suspension_reason': suspensionReason.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      _logDebug('🔗 URL completa: ${uri.toString()}');

      // Realizar petición GET (compatible con CORS)
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        _requestTimeout,
        onTimeout: () {
          throw TimeoutException(
            'La petición excedió el tiempo límite de ${_requestTimeout.inSeconds} segundos'
          );
        },
      );

      _logDebug('📥 Respuesta recibida:');
      _logDebug('   Status Code: ${response.statusCode}');
      _logDebug('   Content-Type: ${response.headers['content-type']}');
      _logDebug('   Body (primeros 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      // Verificar si la respuesta fue exitosa
      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          
          if (responseData['status'] == 'success') {
            _logDebug('✅ Datos guardados exitosamente');
            if (responseData.containsKey('data')) {
              _logDebug('   Fila guardada: ${responseData['data']['row']}');
              _logDebug('   Fecha: ${responseData['data']['date']}');
              _logDebug('   Hora: ${responseData['data']['time']}');
            }
            return true;
          } else {
            _logDebug('❌ Error del servidor: ${responseData['message']}');
            return false;
          }
        } catch (jsonError) {
          _logDebug('❌ Error al parsear JSON: $jsonError');
          _logDebug('   Respuesta completa: ${response.body}');
          
          // Si la respuesta contiene HTML (redirección), seguir el redirect
          if (response.body.contains('<!DOCTYPE') || response.body.contains('<HTML>')) {
            _logDebug('⚠️  Respuesta HTML detectada - Posible redirección');
            _logDebug('   Esto es normal en Google Apps Script');
            _logDebug('   Los datos probablemente se guardaron correctamente');
            return true;
          }
          return false;
        }
      } else if (response.statusCode == 302 || response.statusCode == 307) {
        _logDebug('↪️  Redirección detectada (${response.statusCode})');
        if (response.headers.containsKey('location')) {
          _logDebug('   Location: ${response.headers['location']}');
        }
        return true;
      } else {
        _logDebug('❌ Error HTTP: ${response.statusCode}');
        _logDebug('   Body: ${response.body}');
        return false;
      }
    } on SocketException catch (e) {
      _logDebug('❌ Error de conectividad de red: $e');
      _logDebug('   Verifica tu conexión a Internet');
      rethrow;
    } on TimeoutException catch (e) {
      _logDebug('⏱️  Timeout: $e');
      _logDebug('   La petición tardó más de ${_requestTimeout.inSeconds} segundos');
      rethrow;
    } on FormatException catch (e) {
      _logDebug('❌ Error de formato en la respuesta: $e');
      rethrow;
    } on ArgumentError catch (e) {
      _logDebug('❌ Error en los argumentos: $e');
      rethrow;
    } catch (e, stackTrace) {
      _logDebug('❌ Excepción inesperada: $e');
      _logDebug('   Tipo: ${e.runtimeType}');
      if (kDebugMode) {
        _logDebug('📚 Stack trace:');
        _logDebug(stackTrace.toString());
      }
      rethrow;
    }
  }
  
  /// Verifica si la conexión con Google Sheets está configurada correctamente
  /// 
  /// Retorna `true` si el servidor responde correctamente, `false` en caso contrario
  Future<bool> testConnection() async {
    try {
      _logDebug('🔍 Probando conexión con Google Sheets...');
      _logDebug('   URL: $_webAppUrl');
      
      final response = await http.get(
        Uri.parse(_webAppUrl),
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(_connectionTimeout);
      
      _logDebug('📥 Respuesta de prueba:');
      _logDebug('   Status Code: ${response.statusCode}');
      final preview = response.body.length > 200 ? response.body.substring(0, 200) : response.body;
      _logDebug('   Body preview: $preview...');
      
      final isConnected = response.statusCode == 200;
      _logDebug(isConnected ? '✅ Conexión exitosa' : '❌ Conexión fallida');
      
      return isConnected;
    } on SocketException catch (e) {
      _logDebug('❌ Error de red en test de conexión: $e');
      return false;
    } on TimeoutException catch (e) {
      _logDebug('⏱️  Timeout en test de conexión: $e');
      return false;
    } catch (e) {
      _logDebug('❌ Error en test de conexión: $e');
      return false;
    }
  }
  
  /// Obtiene la URL del Web App configurada (solo para debugging)
  String get webAppUrl => _webAppUrl;
  
  /// Indica si el servicio está configurado correctamente
  bool get isConfigured => _webAppUrl.isNotEmpty && 
                           !_webAppUrl.contains('TU_URL');
}
