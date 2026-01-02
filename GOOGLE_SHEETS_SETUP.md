# Configuración de Google Sheets

## Paso 1: Crear una Hoja de Google Sheets

1. Ve a [Google Sheets](https://sheets.google.com)
2. Crea una nueva hoja de cálculo
3. Ponle un nombre significativo (ej: "Fatigue Tracker - Datos")

## Paso 2: Configurar Google Apps Script

1. En tu hoja de Google Sheets, ve a **Extensiones** → **Apps Script**
2. Borra el código de ejemplo que aparece
3. Copia TODO el código del archivo `google_apps_script_CORS_FIXED.gs`
4. Pégalo en el editor de Apps Script
5. **IMPORTANTE:** Verifica que la constante `SHEET_NAME` coincida con el nombre de tu pestaña:
   ```javascript
   const SHEET_NAME = 'Hoja1';  // Cambia esto si tu pestaña tiene otro nombre
   ```

## Paso 3: Guardar el Proyecto

1. Click en el icono de **disco** (guardar) o presiona `Ctrl+S` (Windows/Linux) o `Cmd+S` (Mac)
2. Pon un nombre al proyecto: "Fatigue Tracker Backend"

## Paso 4: Implementar como Web App

1. Click en **Implementar** → **Nueva implementación**
2. En "Seleccionar tipo", elige: **Aplicación web**
3. Configuración:
   - **Descripción:** "Fatigue Tracker API"
   - **Ejecutar como:** **Yo** (tu cuenta de Google)
   - **Quién tiene acceso:** **Cualquier persona** ⚠️ IMPORTANTE
4. Click en **Implementar**

## Paso 5: Autorizar Permisos

1. Aparecerá una ventana pidiendo autorización
2. Click en **Revisar permisos**
3. Selecciona tu cuenta de Google
4. Si aparece "Esta aplicación no está verificada":
   - Click en **Opciones avanzadas**
   - Click en **Ir a Fatigue Tracker Backend (no seguro)**
5. Click en **Permitir**

## Paso 6: Copiar la URL del Web App

1. Una vez implementado, Google te mostrará una URL que termina en `/exec`
2. **COPIA esta URL completa**
3. Se verá algo así:
   ```
   https://script.google.com/macros/s/AKfycbxXXXXXXXXXXXXXXXXX/exec
   ```

## Paso 7: Configurar la URL en Flutter

1. Abre el archivo `lib/services/google_sheets_service.dart`
2. Busca la línea que dice:
   ```dart
   static const String _webAppUrl = 'TU_URL_AQUI';
   ```
3. Reemplaza `'TU_URL_AQUI'` con la URL que copiaste en el paso anterior
4. Ejemplo:
   ```dart
   static const String _webAppUrl = 'https://script.google.com/macros/s/AKfycbxXXXXXXXXXXXXXXXXX/exec';
   ```
5. **Guarda el archivo**

## Paso 8: Recompilar la Aplicación

Después de configurar la URL, debes recompilar:

```bash
flutter clean
flutter pub get
flutter build web --release
```

## Paso 9: Probar la Conexión

1. Abre la aplicación en el navegador
2. Abre la consola del navegador (F12 → Console)
3. Completa el formulario y presiona "Guardar Registro"
4. Deberías ver en la consola:
   ```
   🔍 [GoogleSheetsService] ✅ Datos guardados exitosamente
   ```
5. Ve a tu Google Sheets y verifica que apareció una nueva fila con los datos

## Estructura de la Hoja de Cálculo

El script creará automáticamente los encabezados con este formato:

| Fecha | Hora | ID | Fatiga (0-100) | Capacidad (0-100) | Motivo (1-4) |
|-------|------|-----|----------------|-------------------|--------------|

### Colores Automáticos

Los datos se colorearán automáticamente según su valor:

**Fatiga y Capacidad:**
- 🟢 Verde (0-10): Bajo
- 🔵 Azul (11-40): Moderado
- 🟠 Naranja (41-70): Alto
- 🔴 Rojo (71-100): Muy alto

**Motivo:**
- 🔵 Azul: Falta de aire (1)
- 🟡 Amarillo: Fatiga en piernas (2)
- 🔴 Rojo: Ambas (3)
- 🟣 Morado: Otra razón (4)

## Solución de Problemas

### Error: "Debes configurar la URL de Google Apps Script"

**Causa:** La URL no está configurada o es incorrecta.

**Solución:**
1. Verifica que copiaste la URL completa (debe terminar en `/exec`)
2. Verifica que no dejaste comillas extras o espacios
3. Recompila la aplicación

### Error: "fetch failed" o "Network Error"

**Causa:** Problemas de CORS o el script no está implementado correctamente.

**Solución:**
1. Asegúrate de usar el archivo `google_apps_script_CORS_FIXED.gs` (con soporte GET)
2. Re-implementa el Web App:
   - Ve a **Implementar** → **Administrar implementaciones**
   - Click en el icono de **lápiz** (editar)
   - Cambia la versión a **"Nueva versión"**
   - Click en **Implementar**

### Error: "No se guardan los datos en Sheets"

**Causa:** El nombre de la hoja no coincide con `SHEET_NAME`.

**Solución:**
1. Verifica el nombre de tu pestaña en Google Sheets
2. Actualiza la constante en Apps Script:
   ```javascript
   const SHEET_NAME = 'TU_NOMBRE_DE_PESTAÑA';
   ```
3. Guarda y re-implementa

### Error: "Permission denied"

**Causa:** No has autorizado los permisos correctamente.

**Solución:**
1. Ve a **Implementar** → **Probar implementaciones**
2. Ejecuta una función de prueba (ej: `testSaveData`)
3. Autoriza los permisos cuando se solicite

## Funciones de Prueba

El script incluye funciones para probar sin usar la app:

### Probar guardado de datos:
1. En Apps Script, selecciona la función: **testSaveData**
2. Click en **Ejecutar**
3. Verifica en Sheets que se creó una fila con datos de prueba

### Ver estadísticas:
1. En Apps Script, selecciona la función: **getStatistics**
2. Click en **Ejecutar**
3. Ve a **Ejecuciones** para ver las estadísticas

## Seguridad

⚠️ **IMPORTANTE:**

Este script está configurado con acceso público ("Cualquier persona") para facilitar el uso desde la aplicación web. Esto significa:

- ✅ Cualquiera con la URL puede enviar datos
- ✅ Los datos se guardan en tu hoja de Google Sheets
- ⚠️ No hay autenticación de usuarios

**Para proyectos en producción:**

Considera añadir un sistema de tokens de seguridad:

```javascript
const VALID_TOKEN = 'tu_token_secreto_aqui';

function saveData(params) {
  if (params.security_token !== VALID_TOKEN) {
    throw new Error('Token inválido');
  }
  // ... resto del código
}
```

## Mantenimiento

### Actualizar la implementación:

Si haces cambios en el código de Apps Script:

1. Guarda los cambios
2. Ve a **Implementar** → **Administrar implementaciones**
3. Click en el icono de **lápiz** (editar) en la implementación activa
4. En "Versión", selecciona **"Nueva versión"**
5. Click en **Implementar**
6. La URL permanecerá igual

### Hacer backup de los datos:

1. En Google Sheets, ve a **Archivo** → **Descargar** → **Valores separados por comas (.csv)**
2. O simplemente haz una copia de la hoja: **Archivo** → **Hacer una copia**

## Soporte

Si tienes problemas con la configuración de Google Sheets:

1. Revisa esta guía paso a paso
2. Verifica los logs en Apps Script: **Ejecuciones**
3. Abre un Issue en GitHub con los detalles del error
