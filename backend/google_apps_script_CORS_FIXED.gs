/**
 * =====================================================
 * GOOGLE APPS SCRIPT - FATIGUE TRACKER BACKEND
 * VERSIÓN CON SOPORTE CORS (GET Parameters)
 * =====================================================
 * 
 * Esta versión usa GET en lugar de POST para evitar problemas de CORS
 * 
 * ESTRUCTURA DE DATOS:
 * - Fecha: DD/MM/YYYY
 * - Hora: HH:MM:SS
 * - ID: 1-4 letras
 * - Fatiga: 0-100 (¿Qué tan cansado?)
 * - Capacidad: 0-100 (¿Podrías continuar 1-2 min?)
 * - Motivo: 1, 2, 3, o 4 (¿Por qué suspendiste?)
 *   1 = Falta de aire
 *   2 = Fatiga en las piernas
 *   3 = Ambas
 *   4 = Otra razón
 * =====================================================
 */

// ⚙️ CONFIGURACIÓN
const SHEET_NAME = 'Hoja1';

/**
 * Maneja peticiones GET (compatible con CORS desde navegadores web)
 */
function doGet(e) {
  try {
    // Si hay parámetros, es un envío de datos
    if (e.parameter.action === 'save') {
      return saveData(e.parameter);
    }
    
    // Si no hay parámetros, es una prueba de conexión
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
 * Guarda datos en la hoja de cálculo
 */
function saveData(params) {
  try {
    Logger.log('📥 Petición recibida con parámetros');
    
    const userId = params.user_id || params.userId;
    const fatigueLevel = parseInt(params.fatigue_level || params.fatigueLevel);
    const capacityLevel = parseInt(params.capacity_level || params.capacityLevel);
    const suspensionReason = parseInt(params.suspension_reason || params.suspensionReason);
    
    // Validaciones
    if (!userId || userId.length < 1 || userId.length > 4) {
      throw new Error('ID debe tener 1-4 caracteres');
    }
    
    if (isNaN(fatigueLevel) || fatigueLevel < 0 || fatigueLevel > 100) {
      throw new Error('Fatiga debe estar entre 0-100');
    }
    
    if (isNaN(capacityLevel) || capacityLevel < 0 || capacityLevel > 100) {
      throw new Error('Capacidad debe estar entre 0-100');
    }
    
    if (isNaN(suspensionReason) || suspensionReason < 1 || suspensionReason > 4) {
      throw new Error('Motivo debe ser 1, 2, 3, o 4');
    }
    
    // Obtener hoja
    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    let sheet = spreadsheet.getSheetByName(SHEET_NAME);
    
    // Crear hoja si no existe
    if (!sheet) {
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
      
      // Formato encabezados
      const headerRange = sheet.getRange(1, 1, 1, 6);
      headerRange.setFontWeight('bold');
      headerRange.setBackground('#4285F4');
      headerRange.setFontColor('#FFFFFF');
      headerRange.setHorizontalAlignment('center');
      
      // Ancho columnas
      sheet.setColumnWidth(1, 110);
      sheet.setColumnWidth(2, 90);
      sheet.setColumnWidth(3, 70);
      sheet.setColumnWidth(4, 130);
      sheet.setColumnWidth(5, 150);
      sheet.setColumnWidth(6, 110);
      
      sheet.setFrozenRows(1);
      
      Logger.log('✨ Hoja creada: ' + SHEET_NAME);
    }
    
    // Fecha y hora
    const now = new Date();
    const formattedDate = Utilities.formatDate(
      now,
      Session.getScriptTimeZone(),
      'dd/MM/yyyy'
    );
    const formattedTime = Utilities.formatDate(
      now,
      Session.getScriptTimeZone(),
      'HH:mm:ss'
    );
    
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
    
    // Centrar todo
    sheet.getRange(lastRow, 1, 1, 6).setHorizontalAlignment('center');
    
    // Formato fatiga (columna 4)
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
    
    // Formato capacidad (columna 5)
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
    
    // Formato motivo (columna 6)
    const reasonCell = sheet.getRange(lastRow, 6);
    const reasonColors = {
      1: {bg: '#DBEAFE', fg: '#1E40AF'}, // Azul - Falta de aire
      2: {bg: '#FEF3C7', fg: '#92400E'}, // Amarillo - Fatiga piernas
      3: {bg: '#FECACA', fg: '#991B1B'}, // Rojo - Ambas
      4: {bg: '#DDD6FE', fg: '#5B21B6'}  // Morado - Otra razón
    };
    
    const colorScheme = reasonColors[suspensionReason];
    if (colorScheme) {
      reasonCell.setBackground(colorScheme.bg).setFontColor(colorScheme.fg);
    }
    reasonCell.setFontWeight('bold');
    
    Logger.log('✅ Guardado en fila: ' + lastRow);
    Logger.log('   Fecha: ' + formattedDate + ' | Hora: ' + formattedTime);
    Logger.log('   ID: ' + userId + ' | Fatiga: ' + fatigueLevel);
    Logger.log('   Capacidad: ' + capacityLevel + ' | Motivo: ' + suspensionReason);
    
    return ContentService.createTextOutput(
      JSON.stringify({
        status: 'success',
        message: 'Datos guardados',
        data: {
          row: lastRow,
          date: formattedDate,
          time: formattedTime,
          user_id: userId.toUpperCase(),
          fatigue_level: fatigueLevel,
          capacity_level: capacityLevel,
          suspension_reason: suspensionReason
        }
      })
    ).setMimeType(ContentService.MimeType.JSON);
    
  } catch (error) {
    Logger.log('❌ Error: ' + error.toString());
    
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
 * Maneja peticiones POST (mantiene compatibilidad)
 */
function doPost(e) {
  try {
    Logger.log('📥 Petición POST recibida: ' + e.postData.contents);
    
    const data = JSON.parse(e.postData.contents);
    
    // Convierte POST a formato de parámetros
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
 * Probar guardado
 */
function testSaveData() {
  const result = saveData({
    user_id: 'TEST',
    fatigue_level: '75',
    capacity_level: '45',
    suspension_reason: '3'
  });
  
  Logger.log('Test: ' + result.getContent());
  return result.getContent();
}

/**
 * Estadísticas
 */
function getStatistics() {
  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(SHEET_NAME);
  
  if (!sheet || sheet.getLastRow() <= 1) {
    return 'No hay datos';
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
      faltaAire: reasonData.filter(r => r === 1).length,
      fatigaPiernas: reasonData.filter(r => r === 2).length,
      ambas: reasonData.filter(r => r === 3).length,
      otra: reasonData.filter(r => r === 4).length
    }
  };
  
  Logger.log('📊 Estadísticas:');
  Logger.log(JSON.stringify(stats, null, 2));
  
  return stats;
}
