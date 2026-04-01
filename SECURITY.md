# 🔒 ALONZO — Guía de Seguridad

## Estado actual

### ✅ Ya implementado (en el código)
- **Verificación de precios**: la app lee precios de Firestore al momento de comprar, no confía en el cliente
- **Validación de stock**: verifica disponibilidad antes de crear la orden
- **Sanitización de inputs**: nombre, dirección, teléfono, RIF se limpian antes de guardar
- **ClientId en facturas**: cada factura incluye el UID del comprador
- **NumericId atómico**: usa transacción con counter dedicado (sin race conditions)
- **ProGuard activado**: código ofuscado en release builds
- **Firestore Rules**: reglas de seguridad completas listas para desplegar

### ⚠️ Pendiente de desplegar (requiere acción tuya)

#### 1. Desplegar Firestore Rules
Ve a **Firebase Console → Firestore → Rules** y pega el contenido de `firestore.rules`.

O desde terminal:
```bash
firebase deploy --only firestore:rules
```

#### 2. Activar Cloud Functions (RECOMENDADO)
Esto agrega una capa de validación en el servidor. Incluso si alguien hackea la app, el servidor rechaza la orden si los precios no coinciden.

```bash
# 1. Activa plan Blaze en Firebase Console
# 2. Instala Firebase CLI
npm install -g firebase-tools
firebase login

# 3. Inicializa functions
firebase init functions
# Cuando pregunte, selecciona: JavaScript, NO ESLint, YES install dependencies

# 4. Reemplaza functions/index.js con el que ya está en este repo

# 5. Despliega
cd functions && npm install && cd ..
firebase deploy --only functions
```

#### 3. Limpiar google-services.json del historial de git
```bash
# Quitar del tracking (el archivo local se mantiene)
git rm --cached android/app/google-services.json
git commit -m "chore: stop tracking google-services.json"
git push origin main
```

#### 4. Crear keystore de producción
```bash
keytool -genkey -v -keystore alonzo-release.keystore -alias alonzo -keyalg RSA -keysize 2048 -validity 10000
```
Luego crear `android/key.properties`:
```
storePassword=TU_PASSWORD
keyPassword=TU_PASSWORD
keyAlias=alonzo
storeFile=../../alonzo-release.keystore
```
Y actualizar `android/app/build.gradle.kts` para usar el keystore en release.

## Cómo funciona la seguridad

```
Usuario abre la app
    ↓
Lee productos de Firestore (precios reales)
    ↓
Agrega al carrito (precio del servidor)
    ↓
Checkout: verifica stock Y precios otra vez
    ↓
Guarda factura en Firestore
    ↓
Cloud Function se dispara automáticamente:
  → Lee precios de productos en el servidor
  → Recalcula el total
  → Si no coincide → marca como "Rechazada"
  → Si coincide → marca como "Validada" + descuenta stock
```

Incluso sin Cloud Functions, las Firestore Rules impiden que alguien sin autenticación modifique datos, y la verificación de precios en la app hace muy difícil la manipulación.
