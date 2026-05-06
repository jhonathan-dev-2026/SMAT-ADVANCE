# Sistema de Monitoreo Ambiental (SMAT) - Cliente Movil

## Informacion del Proyecto
**Estudiante:** Jhonathan Gomez  
**Curso:** Laboratorio de Desarrollo de Aplicaciones Moviles  
**Semana:** 06 - Implementacion de Autenticacion y Persistencia  

## Descripcion
Este repositorio contiene el desarrollo del cliente movil para el ecosistema SMAT. En esta fase, se ha implementado un modulo de seguridad completo que permite la autenticacion de usuarios mediante tokens JWT, la persistencia de la sesion en el dispositivo y la proteccion de rutas de navegacion.

## Caracteristicas Tecnicas (Semana 6)
* **Autenticacion JWT:** Integracion con el backend FastAPI para la generacion y validacion de tokens de acceso.
* **Persistencia de Datos:** Uso del paquete shared_preferences para almacenar el token de seguridad de forma local, permitiendo que el usuario mantenga su sesion activa tras cerrar la aplicacion.
* **Navegacion Protegida:** Implementacion de logica condicional en el punto de entrada de la aplicacion para direccionar al usuario entre la pantalla de Login o el Home segun la existencia de un token valido.
* **Gestion de Sesion:** Implementacion de funcionalidad de Logout para la eliminacion segura del token almacenado.

## Requisitos de Sistema
* Flutter SDK (Version estable)
* Dart SDK
* Backend SMAT (FastAPI) en ejecucion
* Dependencias: http, shared_preferences

## Estructura del Modulo de Seguridad
* lib/services/auth_service.dart: Logica de peticiones HTTP para login y gestion de SharedPreferences.
* lib/screens/login_screen.dart: Interfaz de usuario para la captura de credenciales.
* lib/main.dart: Configuracion del FutureBuilder para el control de acceso inicial.

## Instrucciones de Ejecucion

### 1. Preparacion del Backend
Asegurese de que el servidor FastAPI este activo y con la configuracion CORS habilitada para permitir conexiones desde el cliente Flutter.

### 2. Configuracion del Cliente
Verificar que la direccion IP en auth_service.dart coincida con la instancia del servidor (ejemplo: 127.0.0.1 para Windows/Web o 10.0.2.2 para emulador Android).

### 3. Instalacion y Lanzamiento
```bash
flutter pub get
flutter run