MANUAL DE USUARIO — VERIFARMAC

Este manual describe el uso de VeriFarmac para un ciudadano o personal de un
establecimiento farmacéutico. Las capturas corresponden a la versión del APK
compilada para la prueba de socialización.

1. Instalación
VeriFarmac se distribuye como archivo APK para Android 8.0 (API 26) o
superior. Para instalarlo: habilitar "Orígenes desconocidos" en Ajustes >
Seguridad, abrir el archivo .apk y confirmar la instalación.


2. Crear una cuenta
Al abrir la aplicación por primera vez se solicita correo electrónico y
contraseña para crear una cuenta. Este registro permite sincronizar el
historial de verificaciones en la nube (Supabase) y usarlo desde otro
dispositivo.


3. Iniciar sesión
Con una cuenta ya creada, basta con ingresar correo y contraseña en la
pantalla de inicio de sesión.


4. Pantalla principal
Al ingresar, la pantalla de Inicio muestra el resumen de escaneos del
usuario (total, vigentes, vencidos), el botón "Nueva Verificación", los
escaneos recientes y accesos a Mapa, Historial y Perfil.


5. Elegir el modo de verificación
Al tocar "Nueva Verificación" se abre el escáner con tres modos
seleccionables en la parte superior: Código de barras, OCR e IA Visual. El
usuario elige el que mejor se ajuste al estado del empaque:
- Código de barras: si el empaque tiene un código de barras legible.
- OCR: si se puede fotografiar el texto impreso con claridad (nombre,
  registro sanitario, fecha de vencimiento).
- IA Visual: si el empaque está deteriorado, borroso o el texto es difícil
  de leer; la inteligencia artificial interpreta la imagen completa.


6. Capturar la imagen
En los tres modos, el usuario encuadra el empaque dentro del marco guía (el
tamaño del marco cambia según el modo: pequeño para código de barras, medio
para OCR, casi pantalla completa para IA Visual) y presiona el botón de
captura. La imagen se congela en pantalla antes de analizarse, lo que
permite confirmar que el encuadre y el enfoque fueron correctos antes de
enviarla a procesar. Si el entorno tiene poca luz, el botón de flash (junto
al selector de modo) permite activar la linterna del dispositivo, que
permanece encendida hasta tomar la foto.


7. Entrada manual (si la cámara no puede leer el empaque)
Junto al botón de flash hay un ícono de teclado. Al presionarlo se abre un
cuadro para escribir directamente el código de barras (EAN/UPC) o el número
de registro INVIMA (por ejemplo, "INVIMA 2008M-0007952"), útil cuando la
cámara del dispositivo no logra enfocar o leer el empaque correctamente.


8. Resultado de la verificación
Tras procesar la imagen o el código ingresado, la aplicación muestra una de
cinco categorías de resultado: Vigente, Vencido o suspendido, Inválido
(código o información alterada), Sospechoso (posible anomalía detectada por
la IA) o No encontrado. Cada pantalla de resultado incluye el nombre del
producto, el titular del registro, y un aviso fijo que recuerda que
VeriFarmac no certifica autenticidad física, composición química ni
seguridad terapéutica del producto. Al pie de la pantalla se muestra la
fuente de los datos (INVIMA, portal datos.gov.co) y la fecha de su última
actualización.


9. Historial de verificaciones
Desde el menú principal, "Historial" lista todas las verificaciones hechas
por el usuario, con fecha, producto, método usado (código de barras, OCR o
IA Visual) y resultado. Si el usuario tiene sesión iniciada, el historial se
sincroniza automáticamente con la nube al abrir esta pantalla.

10. Farmacias cercanas
Desde la sección de ayuda en la pantalla principal, "Consultar Mapa" muestra
las farmacias y clínicas cercanas al usuario mediante geolocalización, con
la opción de obtener la ruta hacia ellas.

11. Perfil y configuración
En "Perfil" el usuario puede ver y editar su información personal y
consultar su actividad (total de escaneos, precisión en verificaciones). En
"Configuración" puede cambiar el tema (claro/oscuro/sistema) y el idioma de
la aplicación, y cerrar sesión.

