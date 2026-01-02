# 📱 Fatigue Tracker - Aplicación de Registro de Fatiga

Aplicación móvil desarrollada en Flutter para registrar niveles de fatiga después del ejercicio físico. Los datos se envían automáticamente a Google Sheets con timestamp.

---

## 🎯 Características

- ✅ **Interfaz intuitiva** con slider interactivo (0-100%)
- ✅ **Etiquetas dinámicas** que cambian según el nivel de fatiga
- ✅ **Colores adaptativos** según la intensidad de cansancio
- ✅ **Integración con Google Sheets** mediante Google Apps Script
- ✅ **Indicador de carga** durante el envío de datos
- ✅ **Mensajes de confirmación** de éxito o error
- ✅ **Reset automático** del slider después de guardar
- ✅ **Diseño Material Design 3** moderno y responsive

---

## 🚀 Configuración del Backend (Google Sheets)

### Paso 1: Crear la Hoja de Cálculo

1. Abre [Google Sheets](https://sheets.google.com)
2. Crea una nueva hoja de cálculo
3. Nómbrala: **"Fatigue Tracker - Registros"**

### Paso 2: Configurar Google Apps Script

1. En tu hoja de Google Sheets, ve a: **Extensiones > Apps Script**

2. Borra todo el código predeterminado

3. Copia y pega el contenido completo del archivo:
   ```
   backend/google_apps_script.gs
   ```

4. **IMPORTANTE:** Verifica el nombre de la hoja en la línea 39:
   ```javascript
   const SHEET_NAME = 'Hoja1'; // Cambia esto si tu hoja tiene otro nombre
   ```

5. Guarda el proyecto: **Archivo > Guardar** (o `Ctrl+S`)

### Paso 3: Implementar como Web App

1. Haz clic en **Implementar > Nueva implementación**

2. Configuración:
   - **Tipo:** Aplicación web
   - **Ejecutar como:** Yo (tu email)
   - **Quién tiene acceso:** Cualquier persona

3. Haz clic en **Implementar**

4. **Autoriza los permisos** cuando se soliciten:
   - Google te pedirá revisar los permisos
   - Haz clic en "Ir a [nombre del proyecto] (no seguro)"
   - Haz clic en "Permitir"

5. **¡Importante!** Copia la **URL de la aplicación web** que aparece
   - Termina en `/exec`
   - Ejemplo: `https://script.google.com/macros/s/ABC123.../exec`

### Paso 4: Configurar la URL en Flutter

1. Abre el archivo: `lib/services/google_sheets_service.dart`

2. En la línea 8, reemplaza la URL:
   ```dart
   static const String _webAppUrl = 'PEGA_AQUI_TU_URL_DE_GOOGLE_APPS_SCRIPT';
   ```

3. Ejemplo:
   ```dart
   static const String _webAppUrl = 'https://script.google.com/macros/s/ABC123DEF456/exec';
   ```

4. Guarda el archivo

---

## 🔧 Instalación de la Aplicación Flutter

### Requisitos Previos

- Flutter SDK 3.35.4 o superior
- Dart 3.9.2 o superior
- Android Studio / VS Code con extensión de Flutter
- Dispositivo Android o emulador configurado

### Pasos de Instalación

1. **Instalar dependencias:**
   ```bash
   cd flutter_app
   flutter pub get
   ```

2. **Ejecutar en modo debug:**
   ```bash
   flutter run
   ```

3. **Compilar APK de release:**
   ```bash
   flutter build apk --release
   ```

4. **Compilar para Web:**
   ```bash
   flutter build web --release
   ```

---

## 📊 Estructura de Datos en Google Sheets

La aplicación crea automáticamente los siguientes campos:

| Fecha/Hora | Nivel de Fatiga (%) | Categoría | Timestamp ISO |
|------------|---------------------|-----------|---------------|
| 02/01/2025 14:30:15 | 75 | Muy cansado | 2025-01-02T14:30:15.123Z |
| 02/01/2025 15:45:22 | 25 | Algo cansado | 2025-01-02T15:45:22.456Z |

### Categorías de Fatiga

- **0-10%:** Nada cansado (Verde)
- **11-40%:** Algo cansado (Azul)
- **41-70%:** Muy cansado (Amarillo)
- **71-100%:** Muy muy cansado (Rojo)

---

## 🧪 Pruebas y Debugging

### Probar la Conexión con Google Sheets

Desde Google Apps Script, puedes ejecutar funciones de prueba:

1. En el editor de Apps Script, selecciona la función `testSaveData`
2. Haz clic en **Ejecutar**
3. Verifica que se agregue una fila de prueba en tu hoja

### Ver Logs en Flutter

Los logs se muestran automáticamente en modo debug:

```bash
flutter run --verbose
```

Busca mensajes como:
```
📤 Enviando datos a Google Sheets...
   Nivel de fatiga: 75%
📥 Respuesta del servidor:
   Status Code: 200
✅ Datos guardados exitosamente en Google Sheets
```

### Ver Logs en Google Apps Script

1. En el editor de Apps Script
2. Ve a **Ejecuciones** (ícono de reloj en el menú lateral)
3. Verás todas las ejecuciones con sus logs

---

## 🎨 Personalización

### Cambiar Colores

Edita `lib/screens/fatigue_tracker_screen.dart`:

```dart
Color _getFatigueColor() {
  if (_fatigueLevel <= 10) {
    return const Color(0xFF10B981); // Verde - Cambia aquí
  } else if (_fatigueLevel <= 40) {
    return const Color(0xFF3B82F6); // Azul - Cambia aquí
  } else if (_fatigueLevel <= 70) {
    return const Color(0xFFF59E0B); // Naranja - Cambia aquí
  } else {
    return const Color(0xFFEF4444); // Rojo - Cambia aquí
  }
}
```

### Cambiar Etiquetas

Edita el método `_getFatigueLabel()` en el mismo archivo:

```dart
String _getFatigueLabel() {
  if (_fatigueLevel <= 10) {
    return 'Nada cansado'; // Personaliza aquí
  } else if (_fatigueLevel <= 40) {
    return 'Algo cansado'; // Personaliza aquí
  } else if (_fatigueLevel <= 70) {
    return 'Muy cansado'; // Personaliza aquí
  } else {
    return 'Muy muy cansado'; // Personaliza aquí
  }
}
```

### Cambiar Rangos de Fatiga

Modifica los valores de comparación en ambas funciones:

```dart
// Ejemplo: Ajustar rangos a 25%, 50%, 75%
if (_fatigueLevel <= 25) {
  // Primer nivel
} else if (_fatigueLevel <= 50) {
  // Segundo nivel
} else if (_fatigueLevel <= 75) {
  // Tercer nivel
} else {
  // Cuarto nivel
}
```

---

## 🐛 Solución de Problemas Comunes

### Error: "Debes configurar la URL de Google Apps Script"

**Causa:** No has configurado la URL en el servicio.

**Solución:**
1. Verifica que hayas copiado la URL correcta de Google Apps Script
2. Pégala en `lib/services/google_sheets_service.dart`
3. Asegúrate de que la URL termine en `/exec`
4. Reinicia la aplicación

### Error: "Error al guardar. Verifica la configuración"

**Causa:** La URL está mal configurada o Google Apps Script no tiene permisos.

**Solución:**
1. Prueba la URL directamente en un navegador
2. Deberías ver: `{"status":"success","message":"✅ Google Apps Script Web App está funcionando correctamente"}`
3. Verifica los permisos en Google Apps Script
4. Asegúrate de que "Quién tiene acceso" esté en "Cualquier persona"

### La aplicación no guarda datos

**Causa:** Posible problema de permisos o configuración de la hoja.

**Solución:**
1. Ejecuta `setupSheet()` desde Google Apps Script
2. Verifica el nombre de la hoja (variable `SHEET_NAME`)
3. Revisa los logs en Apps Script (Ejecuciones)
4. Verifica tu conexión a Internet

### Error de timeout

**Causa:** La petición tarda más de 10 segundos.

**Solución:**
1. Verifica tu conexión a Internet
2. Prueba con datos de ejemplo más simples
3. Aumenta el timeout en `google_sheets_service.dart`:
   ```dart
   .timeout(const Duration(seconds: 20), // Aumenta aquí
   ```

---

## 📦 Dependencias Utilizadas

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: 1.5.0              # Cliente HTTP para peticiones a Google Sheets
  flutter_spinkit: ^5.2.1  # Indicadores de carga animados
```

---

## 📝 Estructura del Proyecto

```
flutter_app/
├── lib/
│   ├── main.dart                           # Punto de entrada de la app
│   ├── screens/
│   │   └── fatigue_tracker_screen.dart     # Pantalla principal con slider
│   └── services/
│       └── google_sheets_service.dart      # Servicio de integración con Google Sheets
├── backend/
│   └── google_apps_script.gs               # Código del backend en Google Apps Script
├── android/                                # Configuración Android
├── web/                                    # Configuración Web
├── pubspec.yaml                            # Dependencias y configuración
└── README.md                               # Este archivo
```

---

## 🔐 Seguridad y Privacidad

- ✅ La aplicación **NO almacena datos localmente**
- ✅ Todos los datos se envían directamente a **tu propia hoja de Google Sheets**
- ✅ Solo **tú** tienes acceso a los datos guardados
- ✅ La URL de Google Apps Script es **privada** (no la compartas públicamente)
- ✅ Puedes revocar el acceso desde Google Apps Script en cualquier momento

---

## 📈 Análisis de Datos

Una vez que tengas datos en Google Sheets, puedes:

1. **Crear gráficos:** Inserta gráficos de línea para ver tendencias
2. **Análisis estadístico:** Calcula promedios, máximos y mínimos
3. **Exportar datos:** Descarga como CSV o Excel
4. **Compartir:** Comparte la hoja con entrenadores o médicos
5. **Automatizar:** Crea reportes automáticos con Google Data Studio

### Ejemplo de Fórmulas Útiles

**Promedio de fatiga:**
```
=AVERAGE(B2:B)
```

**Máximo nivel de fatiga:**
```
=MAX(B2:B)
```

**Contar registros por categoría:**
```
=COUNTIF(C2:C,"Muy cansado")
```

**Registros del último mes:**
```
=QUERY(A2:D, "SELECT * WHERE A >= date '"&TEXT(TODAY()-30,"yyyy-mm-dd")&"'")
```

---

## 🤝 Contribuciones

Este es un proyecto de código abierto. Si deseas contribuir:

1. Haz un fork del repositorio
2. Crea una rama para tu feature: `git checkout -b feature/nueva-funcionalidad`
3. Realiza tus cambios y haz commit: `git commit -m 'Agrega nueva funcionalidad'`
4. Sube los cambios: `git push origin feature/nueva-funcionalidad`
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Puedes usarlo, modificarlo y distribuirlo libremente.

---

## 💡 Ideas de Mejoras Futuras

- [ ] Agregar gráficos de tendencias dentro de la app
- [ ] Permitir agregar notas a cada registro
- [ ] Sincronización offline con almacenamiento local
- [ ] Notificaciones para recordar registrar la fatiga
- [ ] Exportar datos a CSV desde la app
- [ ] Integración con wearables (smartwatches)
- [ ] Autenticación de usuarios
- [ ] Múltiples tipos de ejercicio

---

## 📧 Soporte

Si tienes problemas o preguntas:

1. Revisa la sección **Solución de Problemas Comunes**
2. Verifica los logs de Flutter y Google Apps Script
3. Asegúrate de que la configuración de Google Apps Script sea correcta
4. Prueba la URL del Web App directamente en el navegador

---

## ✨ Créditos

Desarrollado con ❤️ usando Flutter y Google Apps Script.

**Tecnologías utilizadas:**
- Flutter 3.35.4
- Dart 3.9.2
- Google Apps Script
- Google Sheets API
- Material Design 3

---

¡Gracias por usar Fatigue Tracker! 🚀
