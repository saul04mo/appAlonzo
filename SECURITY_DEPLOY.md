# 🔒 ALONZO — Guía de Despliegue de Seguridad

## Estado actual
Tu app tiene el código de seguridad listo pero **no está desplegado**.
Esto significa que Firestore sigue con reglas abiertas y las Cloud Functions
no están corriendo. Sigue estos pasos para activar todo.

---

## Paso 1: Instalar Firebase CLI (una sola vez)

```bash
npm install -g firebase-tools
firebase login
```

Te abrirá el navegador para iniciar sesión con tu cuenta de Google
(la misma del proyecto Firebase).

---

## Paso 2: Conectar el proyecto

```bash
cd /ruta/a/appAlonzo
firebase use alozo-2633a
```

Si no funciona, ejecuta:
```bash
firebase init
```
Y selecciona:
- ✅ Firestore
- ✅ Functions
- Proyecto existente → alozo-2633a

---

## Paso 3: Desplegar Firestore Rules

```bash
firebase deploy --only firestore:rules
```

Esto activa las reglas de seguridad que protegen:
- Productos: solo lectura pública, escritura solo admin
- Clientes: solo el dueño puede leer/escribir su perfil
- Facturas: solo usuarios autenticados, clientId debe coincidir
- Cupones: usuarios pueden leer + incrementar uso, solo admin crea/borra
- Wishlists: solo el dueño
- Todo lo demás: DENEGADO

### ⚠️ IMPORTANTE: Crear documento de admin
Para que el POS siga funcionando, necesitas crear un documento en Firestore:

1. Ve a la consola de Firebase → Firestore
2. Crea la colección `admins`
3. Crea un documento con ID = tu UID de Firebase Auth
4. Agrega un campo cualquiera (ej: `name: "José"`)

Tu UID lo puedes ver en Firebase Console → Authentication → Users.
Repite para cada vendedor que use el POS.

---

## Paso 4: Desplegar Cloud Functions

### Requisito: Plan Blaze (pago por uso)
Cloud Functions requiere el plan Blaze de Firebase. 
NO te cobra nada si tienes poco tráfico — los primeros 2 millones
de invocaciones al mes son gratis. Solo necesitas tener una tarjeta
vinculada.

Para activar: Firebase Console → Upgrade → Blaze

### Desplegar:
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

Esto activa la Cloud Function `validateOrder` que:
- Se ejecuta automáticamente cada vez que se crea una factura
- Verifica los precios contra los productos reales en Firestore
- Valida stock disponible
- Valida cupón si se usó
- Si el total no coincide (>$0.50 diferencia) → marca como "Rechazada"
- Si todo está bien → descuenta stock automáticamente

---

## Paso 5: Verificar

Después de desplegar, haz una compra de prueba desde la app y verifica:

1. La factura aparece en Firestore con:
   - `clientId`: tu UID
   - `serverValidated`: true
   - `serverCalculatedTotal`: el total calculado por el servidor

2. El stock del producto se descuenta automáticamente

3. Si intentas manipular el precio (desde la consola de Firestore),
   la Cloud Function marca la factura como "Rechazada"

---

## Paso 6: Release Build (Android)

Tu app está firmada con debug keys. Para producción:

### 1. Generar keystore
```bash
keytool -genkey -v -keystore alonzo-release.keystore -alias alonzo -keyalg RSA -keysize 2048 -validity 10000
```

### 2. Crear key.properties
```properties
storePassword=TU_PASSWORD
keyPassword=TU_PASSWORD
keyAlias=alonzo
storeFile=../alonzo-release.keystore
```

### 3. Actualizar build.gradle.kts
Cambia la sección `release` para usar tu keystore en vez de debug.

### 4. Activar ProGuard/R8
En `android/app/build.gradle.kts`, dentro de `release`:
```kotlin
isMinifyEnabled = true
proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"))
```

---

## Resumen de comandos

```bash
# Todo de una vez:
firebase login
firebase use alozo-2633a
firebase deploy --only firestore:rules
cd functions && npm install && cd ..
firebase deploy --only functions
```

¡Listo! Tu app está protegida.
