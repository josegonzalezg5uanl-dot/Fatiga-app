import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GoogleSheetsService {
  // ⚠️ IMPORTANTE: Reemplaza esta URL con tu URL de Web App de Google Apps Script
  // Instrucciones en el archivo google_apps_script.gs
  static const String _webAppUrl = 'TU_URL_DE_GOOGLE_APPS_SCRIPT_AQUI';
  
  /// Envía los datos completos a Google Sheets
  /// 
  /// [fatigueLevel] - Nivel de fatiga del 0 al 100
  /// [capacityLevel] - Nivel de capacidad para continuar del 0 al 100
  /// [suspensionReason] - Motivo de suspensión (1, 2, 3, o 4)
  /// [userId] - Identificador de usuario (1-4 letras)
  /// 
  /// Retorna `true` si el envío fue exitoso, `false` en caso contrario
  Future<bool> sendFatigueData(
    int fatigueLevel,
    int capacityLevel,
    int suspensionReason,
    String userId,
  ) async {
    try {
      // Validación de la URL
      if (_webAppUrl == 'TU_URL_DE_GOOGLE_APPS_SCRIPT_AQUI') {
        if (kDebugMode) {
          debugPrint('⚠️  ERROR: Debes configurar la URL de Google Apps Script');
          debugPrint('📝 Lee las instrucciones en google_apps_script.gs');
        }
        return false;
      }

      if (kDebugMode) {
        debugPrint('📤 Enviando datos a Google Sheets...');
        debugPrint('   Usuario: $userId');
        debugPrint('   Nivel de fatiga: $fatigueLevel (0-100)');
        debugPrint('   Nivel de capacidad: $capacityLevel (0-100)');
        debugPrint('   Motivo de suspensión: $suspensionReason (1-4)');
      }

      // Preparar los datos para enviar
      final Map<String, dynamic> payload = {
        'user_id': userId.toUpperCase(),
        'fatigue_level': fatigueLevel,
        'capacity_level': capacityLevel,
        'suspension_reason': suspensionReason,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Realizar petición POST
      final response = await http.post(
        Uri.parse(_webAppUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout: La petición tardó más de 10 segundos');
        },
      );

      if (kDebugMode) {
        debugPrint('📥 Respuesta del servidor:');
        debugPrint('   Status Code: ${response.statusCode}');
        debugPrint('   Body: ${response.body}');
      }

      // Verificar si la respuesta fue exitosa
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['status'] == 'success') {
          if (kDebugMode) {
            debugPrint('✅ Datos guardados exitosamente en Google Sheets');
          }
          return true;
        } else {
          if (kDebugMode) {
            debugPrint('❌ Error: ${responseData['message']}');
          }
          return false;
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ Error HTTP: ${response.statusCode}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Excepción al enviar datos: $e');
      }
      rethrow;
    }
  }
  
  /// Verifica si la conexión con Google Sheets está configurada correctamente
  Future<bool> testConnection() async {
    try {
      if (_webAppUrl == 'TU_URL_DE_GOOGLE_APPS_SCRIPT_AQUI') {
        return false;
      }
      
      final response = await http.get(
        Uri.parse(_webAppUrl),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error al probar conexión: $e');
      }
      return false;
    }
  }
}
