# Fatigue Tracker - Rastreador de Fatiga

Aplicación web desarrollada con Flutter para registrar niveles de fatiga post-ejercicio y capacidad de continuar durante pruebas de ejercicio físico incremental.

## 🎯 Características

- **3 Preguntas de Evaluación:**
  1. Nivel de fatiga (0-100) con visualización 0-10
  2. Capacidad para continuar 1-2 minutos más (0-100) con visualización 0-10
  3. Motivo de suspensión (opción múltiple)

- **Identificador de Usuario:** Campo de 1-4 letras para identificar participantes
- **Colores Dinámicos:** Interfaz con colores que cambian según los valores
- **Guardado en Google Sheets:** Todos los datos se guardan automáticamente con fecha y hora
- **Responsive:** Funciona en computadoras, tablets y móviles
- **Sin Instalación:** Acceso directo desde el navegador

## 🚀 Demostración

**URL de la aplicación:** [Pendiente de desplegar en Netlify]

## 📊 Estructura de Datos

Los datos se guardan en Google Sheets con la siguiente estructura:

| Fecha | Hora | ID | Fatiga (0-100) | Capacidad (0-100) | Motivo (1-4) |
|-------|------|-----|----------------|-------------------|--------------|
| 02/01/25 | 14:30:15 | ABC | 75 | 45 | 3 |

**Motivos de suspensión:**
1. Falta de aire 💨
2. Fatiga en las piernas 🏃
3. Ambas ⚠️
4. Otra razón ❓

## 🛠️ Tecnologías

- **Frontend:** Flutter 3.35.4 / Dart 3.9.2
- **Backend:** Google Apps Script
- **Base de Datos:** Google Sheets
- **Hosting:** Netlify
- **Control de Versiones:** Git / GitHub

## 📦 Instalación Local

### Prerequisitos

- Flutter 3.35.4 o superior
- Dart 3.9.2 o superior
- Navegador web moderno

### Pasos

1. **Clonar el repositorio:**
```bash
git clone https://github.com/TU_USUARIO/fatigue-tracker.git
cd fatigue-tracker
```

2. **Instalar dependencias:**
```bash
flutter pub get
```

3. **Ejecutar en modo desarrollo:**
```bash
flutter run -d chrome
```

4. **Compilar para producción:**
```bash
flutter build web --release
```

Los archivos compilados estarán en `build/web/`

## ⚙️ Configuración de Google Sheets

### 1. Crear Google Apps Script

1. Abre tu hoja de Google Sheets
2. Ve a **Extensiones** → **Apps Script**
3. Copia el código de `backend/google_apps_script_CORS_FIXED.gs`
4. Guarda el proyecto

### 2. Implementar como Web App

1. Click en **Implementar** → **Nueva implementación**
2. Tipo: **Aplicación web**
3. Ejecutar como: **Yo**
4. Quién tiene acceso: **Cualquier persona**
5. Click en **Implementar**
6. Copia la URL que termina en `/exec`

### 3. Configurar URL en Flutter

Edita `lib/services/google_sheets_service.dart`:

```dart
static const String _webAppUrl = 'TU_URL_AQUI';
```

Reemplaza `TU_URL_AQUI` con la URL del paso anterior.

## 🌐 Despliegue en Netlify

### Opción 1: Desde GitHub (Recomendado)

1. Ve a [Netlify](https://app.netlify.com)
2. Click en **"Add new site"** → **"Import an existing project"**
3. Selecciona **GitHub** y autoriza
4. Elige este repositorio
5. Configuración:
   - **Base directory:** `build`
   - **Build command:** (dejar vacío)
   - **Publish directory:** `web`
6. Click en **"Deploy site"**

### Opción 2: Despliegue Manual

1. Compila el proyecto: `flutter build web --release`
2. Ve a [Netlify](https://app.netlify.com)
3. Arrastra la carpeta `build/web` a Netlify
4. ¡Listo!

## 📱 Uso

1. **Abre la aplicación** en tu navegador
2. **Ingresa tu identificador** (1-4 letras, ej: ABC, JUAN)
3. **Pregunta 1:** Desliza el slider según tu nivel de fatiga
4. **Pregunta 2:** Desliza el slider según tu capacidad para continuar
5. **Pregunta 3:** Selecciona el motivo de suspensión
6. **Click en "Guardar Registro"**
7. Los datos se guardarán automáticamente en Google Sheets

## 🎨 Capturas de Pantalla

[Agregar capturas de pantalla aquí]

## 📝 Estructura del Proyecto

```
fatigue-tracker/
├── android/              # Configuración Android
├── backend/              # Google Apps Script
│   ├── google_apps_script.gs
│   └── google_apps_script_CORS_FIXED.gs
├── build/
│   └── web/             # Build para producción (para Netlify)
├── lib/                 # Código fuente Flutter
│   ├── main.dart
│   ├── screens/
│   │   └── fatigue_tracker_screen.dart
│   └── services/
│       └── google_sheets_service.dart
├── web/                 # Configuración web
├── pubspec.yaml         # Dependencias
└── README.md
```

## 🔧 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: 1.5.0              # Peticiones HTTP
  flutter_spinkit: 5.2.1  # Indicadores de carga
```

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👤 Autor

**[Tu Nombre]**

- GitHub: [@TU_USUARIO](https://github.com/TU_USUARIO)

## 🙏 Agradecimientos

- Flutter Team por el excelente framework
- Google por Google Sheets y Apps Script
- Netlify por el hosting gratuito

## 📞 Soporte

Si tienes alguna pregunta o problema:

1. Revisa la sección de [Issues](https://github.com/TU_USUARIO/fatigue-tracker/issues)
2. Crea un nuevo Issue si es necesario
3. Contacta al autor

---

**Desarrollado con ❤️ usando Flutter**
