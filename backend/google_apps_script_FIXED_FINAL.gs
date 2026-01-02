/**
 * =====================================================
 * GOOGLE APPS SCRIPT - FATIGUE TRACKER BACKEND
 * VERSIÓN FINAL CON LOGGING MEJORADO
 * =====================================================
 * 
 * ESTRUCTURA DE DATOS:
 * - Fecha: DD/MM/YYYY
 * - Hora: HH:MM:SS
 * - ID: 1-4 letras
 * - Fatiga: 0-100
 * - Capacidad: 0-100
 * - Motivo: 1-4
 * =====================================================
 */

const SHEET_NAME = 'Hoja1';

/**
 * Maneja peticiones GET
 */
function doGet(e) {
  try {
    // Log de depuración
    Logger.log('📥 Petición GET recibida');
    Logger.log('Parámetros: ' + JSON.stringify(e.parameter));
    
    // Verificar si es una petición de guardado
    if (e.parameter && e.parameter.action === 'save') {
      Logger.log('✅ Acción detectada: save');
      return saveData(e.parameter);
    }
    
    // Si tiene user_id pero no action, asumir que es guardado
    if (e.parameter && e.parameter.user_id) {
      Logger.log('✅ user_id detectado, asumiendo acción save');
      return saveData(e.parameter);
    }
    
    // Respuesta de prueba de conexión
    Logger.log('ℹ️  Sin acción específica, devolviendo respuesta de prueba');
    return ContentService.createTextOutput(
      JSON.stringify({
        status: 'success',
        message: '✅ Google Apps Script funcionando',
        estructura: 'Fecha | Hora | ID | Fatiga | Capacidad | Motivo (1-4)',
        timestamp: new Date().toISOString()
      })
    ).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    Logger.log('❌ Error en doGet: ' + error.toString());
    Logger.log('Stack: ' + error.stack);
    
    return ContentService.createTextOutput(
      JSON.stringify({
        status: 'error',
        message: error.toString(),
        timestamp: new Date().toISOString()
      })
    ).setMimeType(ContentService.MimeType.JSON);
  }
}

/**
 * Guarda datos en Google Sheets
 */
function saveData(params) {
  try {
    Logger.log('💾 Iniciando saveData');
    Logger.log('Parámetros recibidos: ' + JSON.stringify(params));
    
    // Extraer parámetros
    const userId = params.user_id || params.userId;
    const fatigueLevel = parseInt(params.fatigue_level || params.fatigueLevel);
    const capacityLevel = parseInt(params.capacity_level || params.capacityLevel);
    const suspensionReason = parseInt(params.suspension_reason || params.suspensionReason);
    
    Logger.log('Valores parseados:');
    Logger.log('  - userId: ' + userId);
    Logger.log('  - fatigueLevel: ' + fatigueLevel);
    Logger.log('  - capacityLevel: ' + capacityLevel);
    Logger.log('  - suspensionReason: ' + suspensionReason);
    
    // Validaciones
    if (!userId || userId.length < 1 || userId.length > 4) {
      throw new Error('ID debe tener 1-4 caracteres. Recibido: "' + userId + '"');
    }
    
    if (isNaN(fatigueLevel) || fatigueLevel < 0 || fatigueLevel > 100) {
      throw new Error('Fatiga debe estar entre 0-100. Recibido: ' + fatigueLevel);
    }
    
    if (isNaN(capacityLevel) || capacityLevel < 0 || capacityLevel > 100) {
      throw new Error('Capacidad debe estar entre 0-100. Recibido: ' + capacityLevel);
    }
    
    if (isNaN(suspensionReason) || suspensionReason < 1 || suspensionReason > 4) {
      throw new Error('Motivo debe ser 1-4. Recibido: ' + suspensionReason);
    }
    
    Logger.log('✅ Validaciones pasadas');
    
    // Obtener hoja
    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    let sheet = spreadsheet.getSheetByName(SHEET_NAME);
    
    // Crear hoja si no existe
    if (!sheet) {
      Logger.log('🆕 Creando hoja: ' + SHEET_NAME);
      sheet = spreadsheet.insertSheet(SHEET_NAME);
      
      // Encabezados
      sheet.appendRow([
        'Fecha',
        'Hora',
        'ID',
        'Fatiga (0-100)',
        'Capacidad (0-100)',
        'Motivo (1-4)'
      ]);
      
      // Formato
      const headerRange = sheet.getRange(1, 1, 1, 6);
      headerRange.setFontWeight('bold');
      headerRange.setBackground('#4285F4');
      headerRange.setFontColor('#FFFFFF');
      headerRange.setHorizontalAlignment('center');
      
      sheet.setColumnWidth(1, 110);
      sheet.setColumnWidth(2, 90);
      sheet.setColumnWidth(3, 70);
      sheet.setColumnWidth(4, 130);
      sheet.setColumnWidth(5, 150);
      sheet.setColumnWidth(6, 110);
      
      sheet.setFrozenRows(1);
      
      Logger.log('✨ Hoja creada y formateada');
    } else {
      Logger.log('✅ Hoja encontrada: ' + SHEET_NAME);
    }
    
    // Fecha y hora
    const now = new Date();
    const formattedDate = Utilities.formatDate(now, Session.getScriptTimeZone(), 'dd/MM/yyyy');
    const formattedTime = Utilities.formatDate(now, Session.getScriptTimeZone(), 'HH:mm:ss');
    
    Logger.log('📅 Fecha: ' + formattedDate + ' | Hora: ' + formattedTime);
    
    // Agregar fila
    sheet.appendRow([
      formattedDate,
      formattedTime,
      userId.toUpperCase(),
      fatigueLevel,
      capacityLevel,
      suspensionReason
    ]);
    
    const lastRow = sheet.getLastRow();
    Logger.log('📍 Datos guardados en fila: ' + lastRow);
    
    // Formato
    sheet.getRange(lastRow, 1, 1, 6).setHorizontalAlignment('center');
    
    // Color fatiga
    const fatigueCell = sheet.getRange(lastRow, 4);
    if (fatigueLevel <= 10) {
      fatigueCell.setBackground('#D1F2EB').setFontColor('#0D7A5F');
    } else if (fatigueLevel <= 40) {
      fatigueCell.setBackground('#D6EAF8').setFontColor('#1F618D');
    } else if (fatigueLevel <= 70) {
      fatigueCell.setBackground('#FCF3CF').setFontColor('#9C640C');
    } else {
      fatigueCell.setBackground('#F5B7B1').setFontColor('#943126');
    }
    fatigueCell.setFontWeight('bold');
    
    // Color capacidad
    const capacityCell = sheet.getRange(lastRow, 5);
    if (capacityLevel <= 10) {
      capacityCell.setBackground('#D1F2EB').setFontColor('#0D7A5F');
    } else if (capacityLevel <= 40) {
      capacityCell.setBackground('#D6EAF8').setFontColor('#1F618D');
    } else if (capacityLevel <= 70) {
      capacityCell.setBackground('#FCF3CF').setFontColor('#9C640C');
    } else {
      capacityCell.setBackground('#F5B7B1').setFontColor('#943126');
    }
    capacityCell.setFontWeight('bold');
    
    // Color motivo
    const reasonCell = sheet.getRange(lastRow, 6);
    const reasonColors = {
      1: {bg: '#DBEAFE', fg: '#1E40AF'},
      2: {bg: '#FEF3C7', fg: '#92400E'},
      3: {bg: '#FECACA', fg: '#991B1B'},
      4: {bg: '#DDD6FE', fg: '#5B21B6'}
    };
    
    const colorScheme = reasonColors[suspensionReason];
    if (colorScheme) {
      reasonCell.setBackground(colorScheme.bg).setFontColor(colorScheme.fg);
    }
    reasonCell.setFontWeight('bold');
    
    Logger.log('✅ Guardado exitoso!');
    Logger.log('   ID: ' + userId + ' | Fatiga: ' + fatigueLevel);
    Logger.log('   Capacidad: ' + capacityLevel + ' | Motivo: ' + suspensionReason);
    
    // Respuesta
    return ContentService.createTextOutput(
      JSON.stringify({
        status: 'success',
        message: '✅ Datos guardados correctamente',
        data: {
          row: lastRow,
          date: formattedDate,
          time: formattedTime,
          user_id: userId.toUpperCase(),
          fatigue_level: fatigueLevel,
          capacity_level: capacityLevel,
          suspension_reason: suspensionReason
        },
        timestamp: new Date().toISOString()
      })
    ).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    Logger.log('❌ Error en saveData: ' + error.toString());
    Logger.log('Stack trace: ' + error.stack);
    
    return ContentService.createTextOutput(
      JSON.stringify({
        status: 'error',
        message: 'Error al guardar: ' + error.toString(),
        timestamp: new Date().toISOString()
      })
    ).setMimeType(ContentService.MimeType.JSON);
  }
}

/**
 * Maneja peticiones POST
 */
function doPost(e) {
  try {
    Logger.log('📥 Petición POST recibida');
    Logger.log('Body: ' + e.postData.contents);
    
    const data = JSON.parse(e.postData.contents);
    
    return saveData({
      user_id: data.user_id,
      fatigue_level: String(data.fatigue_level),
      capacity_level: String(data.capacity_level),
      suspension_reason: String(data.suspension_reason)
    });
    
  } catch (error) {
    Logger.log('❌ Error en doPost: ' + error.toString());
    
    return ContentService.createTextOutput(
      JSON.stringify({
        status: 'error',
        message: error.toString(),
        timestamp: new Date().toISOString()
      })
    ).setMimeType(ContentService.MimeType.JSON);
  }
}

/**
 * Función de prueba manual
 */
function testSaveData() {
  Logger.log('🧪 Ejecutando test manual');
  
  const result = saveData({
    user_id: 'TEST',
    fatigue_level: '75',
    capacity_level: '45',
    suspension_reason: '3'
  });
  
  Logger.log('Resultado: ' + result.getContent());
  return result.getContent();
}

/**
 * Configurar hoja manualmente
 */
function setupSheet() {
  const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
  let sheet = spreadsheet.getSheetByName(SHEET_NAME);
  
  if (!sheet) {
    sheet = spreadsheet.insertSheet(SHEET_NAME);
  }
  
  sheet.clear();
  
  sheet.appendRow([
    'Fecha',
    'Hora',
    'ID',
    'Fatiga (0-100)',
    'Capacidad (0-100)',
    'Motivo (1-4)'
  ]);
  
  const headerRange = sheet.getRange(1, 1, 1, 6);
  headerRange.setFontWeight('bold');
  headerRange.setBackground('#4285F4');
  headerRange.setFontColor('#FFFFFF');
  headerRange.setHorizontalAlignment('center');
  
  sheet.setColumnWidth(1, 110);
  sheet.setColumnWidth(2, 90);
  sheet.setColumnWidth(3, 70);
  sheet.setColumnWidth(4, 130);
  sheet.setColumnWidth(5, 150);
  sheet.setColumnWidth(6, 110);
  
  sheet.setFrozenRows(1);
  
  Logger.log('✅ Hoja configurada');
  return 'Hoja configurada: ' + SHEET_NAME;
}

/**
 * Obtener estadísticas
 */
function getStatistics() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_NAME);
  
  if (!sheet || sheet.getLastRow() <= 1) {
    return 'No hay datos registrados';
  }
  
  const lastRow = sheet.getLastRow();
  const fatigueData = sheet.getRange(2, 4, lastRow - 1, 1).getValues().flat();
  const capacityData = sheet.getRange(2, 5, lastRow - 1, 1).getValues().flat();
  const reasonData = sheet.getRange(2, 6, lastRow - 1, 1).getValues().flat();
  
  const total = fatigueData.length;
  
  const stats = {
    total: total,
    fatiga: {
      promedio: (fatigueData.reduce((a,b) => a+b, 0) / total).toFixed(2),
      max: Math.max(...fatigueData),
      min: Math.min(...fatigueData)
    },
    capacidad: {
      promedio: (capacityData.reduce((a,b) => a+b, 0) / total).toFixed(2),
      max: Math.max(...capacityData),
      min: Math.min(...capacityData)
    },
    motivos: {
      'Falta de aire': reasonData.filter(r => r === 1).length,
      'Fatiga en piernas': reasonData.filter(r => r === 2).length,
      'Ambas': reasonData.filter(r => r === 3).length,
      'Otra razón': reasonData.filter(r => r === 4).length
    }
  };
  
  Logger.log('📊 Estadísticas generadas');
  Logger.log(JSON.stringify(stats, null, 2));
  
  return stats;
}
