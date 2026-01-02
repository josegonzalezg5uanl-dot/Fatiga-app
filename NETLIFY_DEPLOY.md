# Despliegue en Netlify

Esta guía te ayudará a desplegar tu aplicación Fatigue Tracker en Netlify.

## 🚀 Opción 1: Despliegue desde GitHub (Recomendado)

### Requisitos Previos
- Repositorio de GitHub creado y código subido
- Cuenta de Netlify (gratuita)

### Pasos

1. **Ve a Netlify:**
   - Abre https://app.netlify.com
   - Inicia sesión con tu cuenta

2. **Crear nuevo sitio:**
   - Click en **"Add new site"** (botón verde)
   - Selecciona **"Import an existing project"**

3. **Conectar con GitHub:**
   - Click en **"Deploy with GitHub"**
   - Autoriza a Netlify si es la primera vez
   - Busca y selecciona tu repositorio: `fatigue-tracker`

4. **Configurar el build:**
   ```
   Base directory: build
   Build command: (dejar vacío)
   Publish directory: web
   ```
   
   **IMPORTANTE:** El directorio `build/web` ya contiene los archivos compilados, no necesitas comando de build.

5. **Deploy:**
   - Click en **"Deploy site"**
   - Espera 1-2 minutos mientras Netlify despliega

6. **¡Listo!** ✅
   - Tu sitio estará en una URL como: `https://random-name-123456.netlify.app`

### Actualizar el sitio

Cada vez que hagas `git push` a tu repositorio, Netlify automáticamente:
- ✅ Detecta los cambios
- ✅ Re-despliega el sitio
- ✅ Actualiza la URL (mantiene la misma URL)

---

## ⚡ Opción 2: Despliegue Manual (Más Rápido)

Si prefieres un despliegue rápido sin conectar GitHub:

### Pasos

1. **Compila el proyecto localmente:**
   ```bash
   flutter build web --release
   ```

2. **Ve a Netlify:**
   - Abre https://app.netlify.com

3. **Arrastra y suelta:**
   - Busca el área que dice: "Want to deploy a new site without connecting to Git?"
   - **Arrastra la carpeta `build/web`** (no todo el proyecto)
   - Suelta en la zona de Netlify

4. **Espera:**
   - Netlify subirá y procesará los archivos (1-2 minutos)

5. **¡Listo!** ✅

### Actualizar el sitio

Para actualizar manualmente:
1. Recompila: `flutter build web --release`
2. Ve a Netlify → tu sitio → **"Deploys"**
3. Arrastra de nuevo la carpeta `build/web`

---

## 🎨 Personalizar el Nombre del Sitio

Tu sitio tendrá un nombre aleatorio como: `funny-boba-123456.netlify.app`

**Para cambiarlo:**

1. En Netlify, ve a tu sitio
2. Click en **"Site configuration"** (menú lateral)
3. En "Site information", click en **"Change site name"**
4. Escribe un nuevo nombre (ej: `fatigue-tracker`)
5. Click en **"Save"**
6. Tu nueva URL será: `https://fatigue-tracker.netlify.app`

---

## 🔧 Configuración Avanzada

### Variables de Entorno

Si necesitas diferentes URLs de Google Apps Script para desarrollo y producción:

1. En Netlify, ve a **"Site configuration"** → **"Environment variables"**
2. Añade:
   ```
   GOOGLE_APPS_SCRIPT_URL = tu_url_aqui
   ```
3. Actualiza tu código para usar la variable

### Dominio Personalizado

Para usar tu propio dominio (ej: `app.tudominio.com`):

1. En Netlify, ve a **"Domain management"**
2. Click en **"Add custom domain"**
3. Sigue las instrucciones para configurar el DNS
4. Netlify proporciona HTTPS gratis con Let's Encrypt

### Headers Personalizados

Si necesitas configurar headers adicionales, crea un archivo `_headers` en `web/`:

```
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: no-referrer
```

### Redirects

Para configurar redirects, crea un archivo `_redirects` en `web/`:

```
# Redirect old URLs
/old-path    /new-path    301

# SPA fallback
/*    /index.html   200
```

---

## 📊 Monitoreo

### Analytics

Netlify proporciona analytics básicos gratuitos:

1. Ve a tu sitio en Netlify
2. Click en **"Analytics"** (menú lateral)
3. Verás:
   - Número de visitas
   - Páginas más vistas
   - Fuentes de tráfico

### Logs de Despliegue

Para ver los logs de cada despliegue:

1. Ve a **"Deploys"**
2. Click en un despliegue específico
3. Verás el log completo del proceso

---

## 🐛 Solución de Problemas

### Error: "Page not found"

**Causa:** Subiste la carpeta incorrecta.

**Solución:**
- Asegúrate de subir `build/web` (no `build` ni `flutter_app`)
- Verifica que `index.html` esté en la raíz de la carpeta subida

### Error: "Deploy failed"

**Causa:** Configuración de build incorrecta.

**Solución:**
- Si usas GitHub, verifica la configuración:
  ```
  Base directory: build
  Publish directory: web
  ```
- Asegúrate de que `build/web` existe en tu repositorio

### La app carga pero no guarda datos

**Causa:** URL de Google Apps Script no configurada.

**Solución:**
1. Verifica que configuraste la URL en `google_sheets_service.dart`
2. Recompila: `flutter build web --release`
3. Vuelve a desplegar en Netlify

### Error de CORS

**Causa:** Google Apps Script no tiene soporte CORS.

**Solución:**
- Asegúrate de usar el archivo `google_apps_script_CORS_FIXED.gs`
- Verifica que el método GET está implementado correctamente
- Re-implementa el Web App en Google Apps Script

---

## 📈 Mejores Prácticas

### Antes de Desplegar

✅ **Prueba localmente:**
```bash
flutter run -d chrome
```

✅ **Verifica el build de producción:**
```bash
flutter build web --release
cd build/web
python3 -m http.server 8000
```
Abre http://localhost:8000 y prueba la app

✅ **Verifica el tamaño:**
```bash
du -sh build/web
```
Debería ser ~10-15 MB

### Optimización

**Reducir tamaño del bundle:**
```bash
flutter build web --release --tree-shake-icons
```

**Análisis de dependencias:**
```bash
flutter pub deps
```

### Seguridad

✅ **HTTPS:** Netlify proporciona HTTPS automáticamente
✅ **Headers de seguridad:** Configura headers apropiados
✅ **Variables sensibles:** Nunca subas claves API al repositorio público

---

## 💰 Límites Gratuitos de Netlify

**Plan gratuito incluye:**
- ✅ 100 GB de ancho de banda/mes
- ✅ 300 minutos de build/mes
- ✅ Sitios ilimitados
- ✅ HTTPS automático
- ✅ Deploy continuo desde Git
- ✅ Formularios (100 envíos/mes)

**Más que suficiente para:**
- Proyectos personales
- Prototipos
- Apps de uso moderado
- Portafolios

---

## 🔄 Flujo de Trabajo Recomendado

### Desarrollo Local
```bash
# 1. Hacer cambios en el código
# 2. Probar localmente
flutter run -d chrome

# 3. Compilar para producción
flutter build web --release

# 4. Probar el build
cd build/web
python3 -m http.server 8000
```

### Despliegue desde GitHub
```bash
# 1. Commit cambios
git add .
git commit -m "Descripción de cambios"

# 2. Push a GitHub
git push origin main

# 3. Netlify detecta y despliega automáticamente
# ¡No necesitas hacer nada más!
```

### Despliegue Manual
```bash
# 1. Compilar
flutter build web --release

# 2. Ir a Netlify → Deploys
# 3. Arrastrar carpeta build/web
```

---

## 📞 Soporte

**Documentación de Netlify:**
- https://docs.netlify.com

**Community Forum:**
- https://answers.netlify.com

**Status de Netlify:**
- https://www.netlifystatus.com

---

## ✅ Checklist de Despliegue

Antes de desplegar, verifica:

- [ ] Google Apps Script configurado y URL copiada
- [ ] URL configurada en `google_sheets_service.dart`
- [ ] Aplicación probada localmente
- [ ] `flutter build web --release` ejecutado sin errores
- [ ] Carpeta `build/web` contiene `index.html` y otros archivos
- [ ] GitHub repositorio actualizado (si usas Opción 1)
- [ ] Cuenta de Netlify creada
- [ ] README.md actualizado con URL final

---

**¡Tu aplicación está lista para producción! 🚀**
