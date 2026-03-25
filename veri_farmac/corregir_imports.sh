#!/bin/bash
# Ejecutar desde la raíz del proyecto: bash corregir_imports.sh

PROJECT="lib"
echo "🔧 Corrigiendo imports..."

cat > $PROJECT/core/network/dio_client.dart << 'EOF'
import 'package:dio/dio.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioClient {
  late final Dio dio;
  DioClient() {
    dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
    dio.interceptors.addAll([AuthInterceptor(), RetryInterceptor(dio)]);
  }
}
EOF

cat > $PROJECT/core/network/network_info.dart << 'EOF'
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class INetworkInfo {
  Future<bool> get estaConectado;
}

class NetworkInfo implements INetworkInfo {
  const NetworkInfo(this._connectivity);
  final Connectivity _connectivity;

  @override
  Future<bool> get estaConectado async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
EOF

cat > $PROJECT/core/network/interceptors/auth_interceptor.dart << 'EOF'
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }
}
EOF

cat > $PROJECT/core/network/interceptors/retry_interceptor.dart << 'EOF'
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);
  final Dio _dio;
  static const _maxReintentos = 2;

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    final esErrorDeRed = error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionTimeout;
    final intentos = error.requestOptions.extra['intentos'] ?? 0;
    if (esErrorDeRed && intentos < _maxReintentos) {
      error.requestOptions.extra['intentos'] = intentos + 1;
      try {
        final respuesta = await _dio.fetch(error.requestOptions);
        handler.resolve(respuesta);
        return;
      } catch (_) {}
    }
    handler.next(error);
  }
}
EOF

cat > $PROJECT/shared/widgets/offline_banner.dart << 'EOF'
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _conectividadProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    (result) => result != ConnectivityResult.none,
  );
});

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conectividad = ref.watch(_conectividadProvider);
    return conectividad.when(
      data: (estaConectado) => estaConectado
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              color: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: const Text('Sin conexión a internet',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
EOF

cat > $PROJECT/features/auth/data/datasources/auth_remote_datasource.dart << 'EOF'
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/app_user.dart';
import '../models/app_user_model.dart';

class AuthRemoteDataSource {
  final _supabase = Supabase.instance.client;

  Future<void> signInWithGoogle() async {
    await _supabase.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> signOut() async => await _supabase.auth.signOut();

  AppUser? get usuarioActual {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return AppUserModel.fromSupabase(user.toJson());
  }

  Stream<AppUser?> get cambiosDeAuth {
    return _supabase.auth.onAuthStateChange.map((evento) {
      final user = evento.session?.user;
      if (user == null) return null;
      return AppUserModel.fromSupabase(user.toJson());
    });
  }
}
EOF

cat > $PROJECT/features/auth/presentation/providers/auth_provider.dart << 'EOF'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';

enum AuthEstado { inicial, cargando, autenticado, noAutenticado, error }

class AuthState {
  const AuthState({this.estado = AuthEstado.inicial, this.usuario, this.error});
  final AuthEstado estado;
  final AppUser?   usuario;
  final String?    error;
  bool get estaAutenticado => estado == AuthEstado.autenticado;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._signIn, this._signOut) : super(const AuthState());
  final SignInWithGoogleUseCase _signIn;
  final SignOutUseCase          _signOut;

  Future<void> signInWithGoogle() async {
    state = const AuthState(estado: AuthEstado.cargando);
    try {
      await _signIn();
      state = const AuthState(estado: AuthEstado.autenticado);
    } catch (e) {
      state = const AuthState(estado: AuthEstado.error, error: 'Error al iniciar sesión.');
    }
  }

  Future<void> signOut() async {
    state = const AuthState(estado: AuthEstado.cargando);
    try {
      await _signOut();
      state = const AuthState(estado: AuthEstado.noAutenticado);
    } catch (e) {
      state = const AuthState(estado: AuthEstado.error, error: 'Error al cerrar sesión.');
    }
  }
}

final _dataSourceProvider = Provider((_) => AuthRemoteDataSource());
final _repositoryProvider = Provider((ref) => AuthRepositoryImpl(ref.read(_dataSourceProvider)));
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    SignInWithGoogleUseCase(ref.read(_repositoryProvider)),
    SignOutUseCase(ref.read(_repositoryProvider)),
  ),
);
EOF

cat > $PROJECT/features/auth/presentation/pages/login_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/google_sign_in_button.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState   = ref.watch(authProvider);
    final estaCargando = authState.estado == AuthEstado.cargando;

    ref.listen(authProvider, (_, actual) {
      if (actual.estaAutenticado) context.go(AppRoutes.dashboard);
      if (actual.estado == AuthEstado.error && actual.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(actual.error!)));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.medication_rounded, size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text('Bienvenido',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Inicia sesión para verificar\ntus medicamentos',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 48),
              GoogleSignInButton(
                estaCargando: estaCargando,
                alPresionar: () => ref.read(authProvider.notifier).signInWithGoogle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

cat > $PROJECT/features/splash/presentation/pages/splash_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});
  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirigir();
  }

  Future<void> _redirigir() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final prefs        = await SharedPreferences.getInstance();
    final yaEligioIdioma = prefs.getString('locale') != null;
    final haySession   = Supabase.instance.client.auth.currentSession != null;
    if (!yaEligioIdioma) {
      context.go(AppRoutes.idioma);
    } else if (haySession) {
      context.go(AppRoutes.dashboard);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.medication_rounded, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text('VeriFarmac',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Verificación de medicamentos',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}
EOF

cat > $PROJECT/features/scanner/data/datasources/barcode_datasource.dart << 'EOF'
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeDataSource {
  final MobileScannerController controlador = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  Future<void> toggleLinterna() async => await controlador.toggleTorch();
  void dispose() => controlador.dispose();
}
EOF

cat > $PROJECT/features/scanner/data/datasources/ocr_datasource.dart << 'EOF'
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrDataSource {
  final _reconocedor = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extraerTexto(String rutaImagen) async {
    final imagen    = InputImage.fromFilePath(rutaImagen);
    final resultado = await _reconocedor.processImage(imagen);
    return resultado.text;
  }

  Future<void> dispose() async => await _reconocedor.close();
}
EOF

cat > $PROJECT/features/scanner/data/datasources/claude_ai_datasource.dart << 'EOF'
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class ClaudeAiDataSource {
  ClaudeAiDataSource(this._dio);
  final Dio _dio;
  static const _apiKey = 'TU_CLAUDE_API_KEY';
  static const _url    = 'https://api.anthropic.com/v1/messages';
  static const _modelo = 'claude-opus-4-5';

  Future<Map<String, dynamic>> analizarEmpaque(String rutaImagen) async {
    final bytes        = await File(rutaImagen).readAsBytes();
    final imagenBase64 = base64Encode(bytes);
    final respuesta    = await _dio.post(
      _url,
      options: Options(headers: {
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      }),
      data: {
        'model': _modelo,
        'max_tokens': 500,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'image', 'source': {'type': 'base64', 'media_type': 'image/jpeg', 'data': imagenBase64}},
              {'type': 'text', 'text': 'Analiza este empaque de medicamento colombiano.\nResponde SOLO en JSON:\n{"esAudentico": true/false, "confianza": 0.0-1.0, "observaciones": "texto"}'},
            ],
          },
        ],
      },
    );
    final texto = respuesta.data['content'][0]['text'] as String;
    return jsonDecode(texto) as Map<String, dynamic>;
  }
}
EOF

cat > $PROJECT/features/scanner/data/repositories/scanner_repository_impl.dart << 'EOF'
import 'package:uuid/uuid.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/i_scanner_repository.dart';
import '../datasources/claude_ai_datasource.dart';
import '../datasources/invima_datasource.dart';
import '../datasources/ocr_datasource.dart';
import '../models/scan_result_model.dart';

class ScannerRepositoryImpl implements IScannerRepository {
  const ScannerRepositoryImpl({required this.invima, required this.ocr, required this.claude});
  final InvimaDataSource   invima;
  final OcrDataSource      ocr;
  final ClaudeAiDataSource claude;

  @override
  Future<ScanResult> procesarBarcode(String barcode) async {
    final datos = await invima.buscarPorBarcode(barcode);
    return ScanResultModel(
      id: const Uuid().v4(), valorEscaneado: barcode,
      metodo: MetodoEscaneo.barcode, escaneadoEn: DateTime.now(),
      confianza: datos != null ? 0.95 : 0.0,
      nombreMedicamento: datos?['nombre'] as String?,
      registroSanitario: datos?['registro'] as String?,
      estado: datos?['estado'] as String?,
      error: datos == null ? 'Medicamento no encontrado' : null,
    );
  }

  @override
  Future<ScanResult> procesarOcr(String texto) async {
    final codigoInvima = _extraerCodigoInvima(texto);
    Map<String, dynamic>? datos;
    if (codigoInvima != null) {
      datos = await invima.buscarPorRegistro(codigoInvima);
    } else {
      final resultados = await invima.buscarPorTexto(texto);
      datos = resultados.isNotEmpty ? resultados.first : null;
    }
    return ScanResultModel(
      id: const Uuid().v4(), valorEscaneado: texto,
      metodo: MetodoEscaneo.ocr, escaneadoEn: DateTime.now(),
      confianza: datos != null ? 0.80 : 0.0,
      nombreMedicamento: datos?['nombre'] as String?,
      registroSanitario: datos?['registro'] as String?,
      estado: datos?['estado'] as String?,
      error: datos == null ? 'No se encontró información' : null,
    );
  }

  @override
  Future<ScanResult> analizarImagen(String rutaImagen) async {
    final analisis    = await claude.analizarEmpaque(rutaImagen);
    final esAutentico = analisis['esAudentico'] as bool? ?? false;
    final confianza   = (analisis['confianza'] as num?)?.toDouble() ?? 0.0;
    final observacion = analisis['observaciones'] as String? ?? '';
    return ScanResultModel(
      id: const Uuid().v4(), valorEscaneado: rutaImagen,
      metodo: MetodoEscaneo.visual, escaneadoEn: DateTime.now(),
      confianza: confianza,
      estado: esAutentico ? 'vigente' : 'sospechoso',
      error: esAutentico ? null : observacion,
    );
  }

  String? _extraerCodigoInvima(String texto) {
    final regex = RegExp(r'INVIMA\s*\d{4}[A-Z]-?\d{6,7}', caseSensitive: false);
    return regex.firstMatch(texto)?.group(0);
  }
}
EOF

cat > $PROJECT/features/scanner/presentation/providers/scanner_provider.dart << 'EOF'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/claude_ai_datasource.dart';
import '../../data/datasources/invima_datasource.dart';
import '../../data/datasources/ocr_datasource.dart';
import '../../data/repositories/scanner_repository_impl.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/usecases/analyze_image_usecase.dart';
import '../../domain/usecases/scan_by_barcode_usecase.dart';
import '../../domain/usecases/scan_by_ocr_usecase.dart';
import '../../../../core/network/dio_client.dart';

enum EstadoScanner { inactivo, escaneando, analizando, exitoso, error }

class ScannerState {
  const ScannerState({this.estado = EstadoScanner.inactivo, this.resultado, this.error});
  final EstadoScanner estado;
  final ScanResult?   resultado;
  final String?       error;
}

class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier(this._porBarcode, this._porOcr, this._porImagen) : super(const ScannerState());
  final ScanByBarcodeUseCase _porBarcode;
  final ScanByOcrUseCase     _porOcr;
  final AnalyzeImageUseCase  _porImagen;

  Future<void> escanearBarcode(String barcode) async {
    state = const ScannerState(estado: EstadoScanner.analizando);
    try {
      state = ScannerState(estado: EstadoScanner.exitoso, resultado: await _porBarcode(barcode));
    } catch (_) {
      state = const ScannerState(estado: EstadoScanner.error, error: 'Error al procesar el código');
    }
  }

  Future<void> escanearOcr(String texto) async {
    state = const ScannerState(estado: EstadoScanner.analizando);
    try {
      state = ScannerState(estado: EstadoScanner.exitoso, resultado: await _porOcr(texto));
    } catch (_) {
      state = const ScannerState(estado: EstadoScanner.error, error: 'Error al procesar el texto');
    }
  }

  Future<void> analizarImagen(String rutaImagen) async {
    state = const ScannerState(estado: EstadoScanner.analizando);
    try {
      state = ScannerState(estado: EstadoScanner.exitoso, resultado: await _porImagen(rutaImagen));
    } catch (_) {
      state = const ScannerState(estado: EstadoScanner.error, error: 'Error al analizar la imagen');
    }
  }

  void reiniciar() => state = const ScannerState();
}

final _dioProvider        = Provider((ref) => DioClient().dio);
final _repositoryProvider = Provider((ref) => ScannerRepositoryImpl(
  invima: InvimaDataSource(),
  ocr:    OcrDataSource(),
  claude: ClaudeAiDataSource(ref.read(_dioProvider)),
));

final scannerProvider = StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  final repo = ref.read(_repositoryProvider);
  return ScannerNotifier(ScanByBarcodeUseCase(repo), ScanByOcrUseCase(repo), AnalyzeImageUseCase(repo));
});
EOF

cat > $PROJECT/features/scanner/presentation/pages/scanner_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../providers/scanner_provider.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/scan_mode_toggle.dart';

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});
  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  final _controlador = MobileScannerController(detectionSpeed: DetectionSpeed.normal, facing: CameraFacing.back);
  ModoEscaneo _modo = ModoEscaneo.barcode;
  bool _lintErnaEncendida = false;
  bool _yaProceso = false;

  @override
  void dispose() { _controlador.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerProvider);
    ref.listen(scannerProvider, (_, actual) {
      if (actual.estado == EstadoScanner.exitoso && actual.resultado != null) {
        context.push(AppRoutes.medicamento, extra: actual.resultado);
        ref.read(scannerProvider.notifier).reiniciar();
        _yaProceso = false;
      }
    });
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Escanear'),
        actions: [IconButton(
          onPressed: _toggleLinterna,
          icon: Icon(_lintErnaEncendida ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: Colors.white),
        )],
      ),
      body: Stack(children: [
        MobileScanner(controller: _controlador, onDetect: _alDetectar),
        ScannerOverlay(mensaje: _modo == ModoEscaneo.barcode ? 'Apunta al código de barras' : 'Apunta al texto del empaque'),
        Positioned(top: 16, left: 0, right: 0,
          child: Center(child: ScanModeToggle(modoActual: _modo, alCambiar: (modo) => setState(() => _modo = modo)))),
        if (scannerState.estado == EstadoScanner.analizando)
          Container(color: Colors.black.withOpacity(0.5), child: const AppLoading(mensaje: 'Analizando...')),
        if (scannerState.estado == EstadoScanner.error)
          Positioned(bottom: 40, left: 24, right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade800, borderRadius: BorderRadius.circular(10)),
              child: Text(scannerState.error ?? 'Error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            )),
      ]),
    );
  }

  void _alDetectar(BarcodeCapture captura) {
    if (_yaProceso) return;
    final barcode = captura.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;
    _yaProceso = true;
    if (_modo == ModoEscaneo.barcode) {
      ref.read(scannerProvider.notifier).escanearBarcode(barcode);
    } else {
      ref.read(scannerProvider.notifier).escanearOcr(barcode);
    }
  }

  void _toggleLinterna() {
    _controlador.toggleTorch();
    setState(() => _lintErnaEncendida = !_lintErnaEncendida);
  }
}
EOF

cat > $PROJECT/features/medicine_detail/presentation/widgets/status_badge.dart << 'EOF'
import 'package:flutter/material.dart';
import '../../domain/entities/medicine.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.estado, this.grande = false});
  final EstadoMedicamento estado;
  final bool              grande;

  @override
  Widget build(BuildContext context) {
    final color = _color(estado);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: grande ? 16 : 10, vertical: grande ? 8 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(grande ? 12 : 8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_icono(estado), size: grande ? 18 : 14, color: color),
        SizedBox(width: grande ? 8 : 5),
        Text(estado.etiqueta, style: TextStyle(fontSize: grande ? 15 : 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }

  Color _color(EstadoMedicamento e) => switch (e) {
    EstadoMedicamento.vigente     => const Color(0xFF2E7D32),
    EstadoMedicamento.vencido     => const Color(0xFFC62828),
    EstadoMedicamento.invalido    => const Color(0xFFE65100),
    EstadoMedicamento.sospechoso  => const Color(0xFF6A1B9A),
    EstadoMedicamento.desconocido => const Color(0xFF546E7A),
  };

  IconData _icono(EstadoMedicamento e) => switch (e) {
    EstadoMedicamento.vigente     => Icons.check_circle_rounded,
    EstadoMedicamento.vencido     => Icons.cancel_rounded,
    EstadoMedicamento.invalido    => Icons.block_rounded,
    EstadoMedicamento.sospechoso  => Icons.warning_rounded,
    EstadoMedicamento.desconocido => Icons.help_rounded,
  };
}
EOF

cat > $PROJECT/features/medicine_detail/presentation/providers/medicine_provider.dart << 'EOF'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/invima_mock_datasource.dart';
import '../../data/repositories/medicine_repository_impl.dart';
import '../../domain/entities/medicine.dart';
import '../../domain/usecases/get_medicine_usecase.dart';

enum EstadoMedicina { inicial, cargando, cargado, noEncontrado, error }

class MedicineState {
  const MedicineState({this.estado = EstadoMedicina.inicial, this.medicamento, this.error});
  final EstadoMedicina estado;
  final Medicamento?   medicamento;
  final String?        error;
}

class MedicineNotifier extends StateNotifier<MedicineState> {
  MedicineNotifier(this._porBarcode, this._porRegistro) : super(const MedicineState());
  final GetMedicineByBarcodeUseCase  _porBarcode;
  final GetMedicineByRegistroUseCase _porRegistro;

  Future<void> cargarPorBarcode(String barcode) async {
    state = const MedicineState(estado: EstadoMedicina.cargando);
    try {
      final m = await _porBarcode(barcode);
      state = m != null ? MedicineState(estado: EstadoMedicina.cargado, medicamento: m)
                        : const MedicineState(estado: EstadoMedicina.noEncontrado);
    } catch (e) {
      state = MedicineState(estado: EstadoMedicina.error, error: e.toString());
    }
  }

  Future<void> cargarPorRegistro(String registro) async {
    state = const MedicineState(estado: EstadoMedicina.cargando);
    try {
      final m = await _porRegistro(registro);
      state = m != null ? MedicineState(estado: EstadoMedicina.cargado, medicamento: m)
                        : const MedicineState(estado: EstadoMedicina.noEncontrado);
    } catch (e) {
      state = MedicineState(estado: EstadoMedicina.error, error: e.toString());
    }
  }
}

final _datasourceProvider = Provider((_) => InvimaMockDataSource());
final _repositoryProvider = Provider((ref) => MedicineRepositoryImpl(ref.read(_datasourceProvider)));
final medicineProvider = StateNotifierProvider<MedicineNotifier, MedicineState>((ref) {
  final repo = ref.read(_repositoryProvider);
  return MedicineNotifier(GetMedicineByBarcodeUseCase(repo), GetMedicineByRegistroUseCase(repo));
});
EOF

cat > $PROJECT/features/medicine_detail/presentation/pages/medicine_detail_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/confidence_bar.dart';
import '../../domain/entities/medicine.dart';
import '../providers/medicine_provider.dart';
import '../widgets/status_badge.dart';

class MedicineDetailPage extends ConsumerStatefulWidget {
  const MedicineDetailPage({super.key, required this.medicineId});
  final String medicineId;
  @override
  ConsumerState<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends ConsumerState<MedicineDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(medicineProvider.notifier).cargarPorBarcode(widget.medicineId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicineProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: switch (state.estado) {
        EstadoMedicina.cargando     => const AppLoading(mensaje: 'Consultando INVIMA...'),
        EstadoMedicina.error        => AppErrorWidget(
            mensaje: state.error ?? 'Error',
            alReintentar: () => ref.read(medicineProvider.notifier).cargarPorBarcode(widget.medicineId)),
        EstadoMedicina.noEncontrado => const AppEmptyState(
            titulo: 'Medicamento no encontrado',
            descripcion: 'No se encontró información en la base de datos del INVIMA.'),
        EstadoMedicina.cargado      => _Detalle(medicamento: state.medicamento!),
        _                           => const SizedBox.shrink(),
      },
    );
  }
}

class _Detalle extends StatelessWidget {
  const _Detalle({required this.medicamento});
  final Medicamento medicamento;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: StatusBadge(estado: medicamento.estado, grande: true)),
        const SizedBox(height: 20),
        Text(medicamento.nombre,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        const ConfidenceBar(confianza: 0.95),
        const SizedBox(height: 24),
        _SeccionInfo(titulo: 'Registro sanitario', children: [
          _FilaInfo(etiqueta: 'Código',      valor: medicamento.registroSanitario),
          _FilaInfo(etiqueta: 'Estado',      valor: medicamento.estado.etiqueta),
          _FilaInfo(etiqueta: 'Laboratorio', valor: medicamento.laboratorio),
          if (medicamento.titular != null) _FilaInfo(etiqueta: 'Titular', valor: medicamento.titular!),
        ]),
        const SizedBox(height: 16),
        _SeccionInfo(titulo: 'Información del medicamento', children: [
          if (medicamento.ingredienteActivo != null) _FilaInfo(etiqueta: 'Principio activo', valor: medicamento.ingredienteActivo!),
          if (medicamento.concentracion != null)     _FilaInfo(etiqueta: 'Concentración',    valor: medicamento.concentracion!),
          if (medicamento.formaFarmaceutica != null)  _FilaInfo(etiqueta: 'Forma',            valor: medicamento.formaFarmaceutica!),
        ]),
        const SizedBox(height: 24),
        if (!medicamento.estado.esSeguro)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(children: [
              Icon(Icons.warning_rounded, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(child: Text('Este medicamento no debería comercializarse. Reporta este caso al INVIMA.',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
            ]),
          ),
      ]),
    );
  }
}

class _SeccionInfo extends StatelessWidget {
  const _SeccionInfo({required this.titulo, required this.children});
  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
      const SizedBox(height: 10),
      Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(children: children))),
    ]);
  }
}

class _FilaInfo extends StatelessWidget {
  const _FilaInfo({required this.etiqueta, required this.valor});
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 130,
          child: Text(etiqueta, style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)))),
        Expanded(child: Text(valor, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500))),
      ]),
    );
  }
}
EOF

cat > $PROJECT/features/history/data/datasources/history_local_datasource.dart << 'EOF'
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_entry_model.dart';

class HistoryLocalDataSource {
  static const _clave = 'historial_escaneos';

  Future<void> guardar(HistoryEntryModel entrada) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await _obtenerTodos();
    lista.insert(0, entrada.toJson());
    await prefs.setString(_clave, jsonEncode(lista));
  }

  Future<List<HistoryEntryModel>> obtener({int pagina = 0, int porPagina = 20}) async {
    final lista  = await _obtenerTodos();
    final inicio = pagina * porPagina;
    if (inicio >= lista.length) return [];
    final fin = (inicio + porPagina).clamp(0, lista.length);
    return lista.sublist(inicio, fin).map((j) => HistoryEntryModel.fromJson(j)).toList();
  }

  Future<void> eliminar(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await _obtenerTodos();
    lista.removeWhere((e) => e['id'] == id);
    await prefs.setString(_clave, jsonEncode(lista));
  }

  Future<List<HistoryEntryModel>> obtenerNoSincronizados() async {
    final lista = await _obtenerTodos();
    return lista.where((e) => e['sincronizado'] == false).map((j) => HistoryEntryModel.fromJson(j)).toList();
  }

  Future<void> marcarSincronizado(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = await _obtenerTodos();
    for (final e in lista) { if (e['id'] == id) { e['sincronizado'] = true; break; } }
    await prefs.setString(_clave, jsonEncode(lista));
  }

  Future<Map<String, int>> obtenerEstadisticas() async {
    final lista = await _obtenerTodos();
    final stats = <String, int>{};
    for (final e in lista) { final est = e['estado'] as String; stats[est] = (stats[est] ?? 0) + 1; }
    return stats;
  }

  Future<List<Map<String, dynamic>>> _obtenerTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final json  = prefs.getString(_clave);
    if (json == null) return [];
    return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
  }
}
EOF

cat > $PROJECT/features/history/presentation/providers/history_provider.dart << 'EOF'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/history_local_datasource.dart';
import '../../data/datasources/history_remote_datasource.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/history_entry.dart';
import '../../domain/usecases/history_usecases.dart';

class HistoryState {
  const HistoryState({this.entradas = const [], this.cargando = false, this.error, this.filtro});
  final List<HistoryEntry> entradas;
  final bool               cargando;
  final String?            error;
  final String?            filtro;

  List<HistoryEntry> get entradasFiltradas =>
      filtro == null ? entradas : entradas.where((e) => e.estado == filtro).toList();
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this._obtener, this._eliminar, this._sincronizar) : super(const HistoryState());
  final ObtenerHistorialUseCase     _obtener;
  final EliminarHistorialUseCase    _eliminar;
  final SincronizarHistorialUseCase _sincronizar;

  Future<void> cargar() async {
    state = const HistoryState(cargando: true);
    try {
      state = HistoryState(entradas: await _obtener());
    } catch (_) {
      state = const HistoryState(error: 'Error al cargar el historial');
    }
  }

  Future<void> eliminar(String id) async {
    try {
      await _eliminar(id);
      state = HistoryState(entradas: state.entradas.where((e) => e.id != id).toList(), filtro: state.filtro);
    } catch (_) {
      state = HistoryState(entradas: state.entradas, error: 'Error al eliminar');
    }
  }

  void filtrar(String? estado) =>
      state = HistoryState(entradas: state.entradas, filtro: estado);

  Future<void> sincronizar(String userId) async {
    try { await _sincronizar(userId); } catch (_) {}
  }
}

final _localProvider      = Provider((_) => HistoryLocalDataSource());
final _remotoProvider     = Provider((_) => HistoryRemoteDataSource());
final _repositoryProvider = Provider((ref) => HistoryRepositoryImpl(ref.read(_localProvider), ref.read(_remotoProvider)));

final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final repo = ref.read(_repositoryProvider);
  return HistoryNotifier(ObtenerHistorialUseCase(repo), EliminarHistorialUseCase(repo), SincronizarHistorialUseCase(repo));
});
EOF

cat > $PROJECT/features/history/presentation/pages/history_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../providers/history_provider.dart';
import '../widgets/history_entry_tile.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});
  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(historyProvider.notifier).cargar());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _FiltroEstado(
            filtroActual: state.filtro,
            alCambiar: (f) => ref.read(historyProvider.notifier).filtrar(f),
          ),
        ),
      ),
      body: Builder(builder: (context) {
        if (state.cargando) return const AppLoading(mensaje: 'Cargando historial...');
        if (state.error != null) return AppErrorWidget(
          mensaje: state.error!,
          alReintentar: () => ref.read(historyProvider.notifier).cargar(),
        );
        if (state.entradasFiltradas.isEmpty) return const AppEmptyState(
          titulo: 'Sin registros',
          descripcion: 'Los medicamentos escaneados aparecerán aquí',
        );
        return ListView.separated(
          itemCount: state.entradasFiltradas.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final entrada = state.entradasFiltradas[i];
            return HistoryEntryTile(
              entrada: entrada,
              alEliminar: () => _confirmarEliminar(context, entrada.id),
            );
          },
        );
      }),
    );
  }

  void _confirmarEliminar(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: const Text('¿Seguro que quieres eliminar este registro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () { Navigator.pop(context); ref.read(historyProvider.notifier).eliminar(id); },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _FiltroEstado extends StatelessWidget {
  const _FiltroEstado({required this.filtroActual, required this.alCambiar});
  final String?               filtroActual;
  final ValueChanged<String?> alCambiar;

  @override
  Widget build(BuildContext context) {
    final filtros = [
      (label: 'Todos', valor: null), (label: 'Vigentes', valor: 'vigente'),
      (label: 'Vencidos', valor: 'vencido'), (label: 'Inválidos', valor: 'invalido'),
      (label: 'Sospechosos', valor: 'sospechoso'),
    ];
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: filtros.map((f) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(label: Text(f.label), selected: filtroActual == f.valor, onSelected: (_) => alCambiar(f.valor)),
        )).toList(),
      ),
    );
  }
}
EOF

cat > $PROJECT/features/dashboard/presentation/providers/dashboard_provider.dart << 'EOF'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../history/data/datasources/history_local_datasource.dart';
import '../../../history/data/datasources/history_remote_datasource.dart';
import '../../../history/data/repositories/history_repository_impl.dart';
import '../../domain/usecases/get_stats_usecase.dart';

class DashboardState {
  const DashboardState({this.stats = const {}, this.cargando = false, this.error});
  final Map<String, int> stats;
  final bool             cargando;
  final String?          error;

  int get total       => stats.values.fold(0, (a, b) => a + b);
  int get vigentes    => stats['vigente']    ?? 0;
  int get vencidos    => stats['vencido']    ?? 0;
  int get invalidos   => stats['invalido']   ?? 0;
  int get sospechosos => stats['sospechoso'] ?? 0;
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(this._getStats) : super(const DashboardState());
  final GetStatsUseCase _getStats;

  Future<void> cargar() async {
    state = const DashboardState(cargando: true);
    try {
      state = DashboardState(stats: await _getStats());
    } catch (_) {
      state = const DashboardState(error: 'Error al cargar estadísticas');
    }
  }
}

final _localProvider      = Provider((_) => HistoryLocalDataSource());
final _remotoProvider     = Provider((_) => HistoryRemoteDataSource());
final _repositoryProvider = Provider((ref) => HistoryRepositoryImpl(ref.read(_localProvider), ref.read(_remotoProvider)));

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>(
  (ref) => DashboardNotifier(GetStatsUseCase(ref.read(_repositoryProvider))));
EOF

cat > $PROJECT/features/dashboard/presentation/widgets/stats_donut_chart.dart << 'EOF'
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../providers/dashboard_provider.dart';

class StatsDonutChart extends StatelessWidget {
  const StatsDonutChart({super.key, required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    if (state.total == 0) return const SizedBox(height: 200, child: Center(child: Text('Sin escaneos aún')));
    return SizedBox(
      height: 200,
      child: Row(children: [
        Expanded(child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 50, sections: _secciones()))),
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _ItemLeyenda(color: const Color(0xFF2E7D32), etiqueta: 'Vigentes',    cantidad: state.vigentes),
          _ItemLeyenda(color: const Color(0xFFC62828), etiqueta: 'Vencidos',    cantidad: state.vencidos),
          _ItemLeyenda(color: const Color(0xFFE65100), etiqueta: 'Inválidos',   cantidad: state.invalidos),
          _ItemLeyenda(color: const Color(0xFF6A1B9A), etiqueta: 'Sospechosos', cantidad: state.sospechosos),
        ]),
      ]),
    );
  }

  List<PieChartSectionData> _secciones() => [
    if (state.vigentes > 0)    PieChartSectionData(value: state.vigentes.toDouble(),    color: const Color(0xFF2E7D32), title: '', radius: 30),
    if (state.vencidos > 0)    PieChartSectionData(value: state.vencidos.toDouble(),    color: const Color(0xFFC62828), title: '', radius: 30),
    if (state.invalidos > 0)   PieChartSectionData(value: state.invalidos.toDouble(),   color: const Color(0xFFE65100), title: '', radius: 30),
    if (state.sospechosos > 0) PieChartSectionData(value: state.sospechosos.toDouble(), color: const Color(0xFF6A1B9A), title: '', radius: 30),
  ];
}

class _ItemLeyenda extends StatelessWidget {
  const _ItemLeyenda({required this.color, required this.etiqueta, required this.cantidad});
  final Color color; final String etiqueta; final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$etiqueta: $cantidad', style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}
EOF

cat > $PROJECT/features/dashboard/presentation/pages/dashboard_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/offline_banner.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/quick_scan_button.dart';
import '../widgets/stats_donut_chart.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() { super.initState(); Future.microtask(() => ref.read(dashboardProvider.notifier).cargar()); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Column(children: [
        const OfflineBanner(),
        Expanded(child: state.cargando ? const AppLoading() : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            QuickScanButton(alPresionar: () => context.push(AppRoutes.scanner)),
            const SizedBox(height: 28),
            Text('Resumen de escaneos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(children: [
              _TarjetaEstado(etiqueta: 'Total',    cantidad: state.total,    color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              _TarjetaEstado(etiqueta: 'Vigentes', cantidad: state.vigentes, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              _TarjetaEstado(etiqueta: 'Vencidos', cantidad: state.vencidos, color: const Color(0xFFC62828)),
            ]),
            const SizedBox(height: 24),
            Text('Distribución',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: StatsDonutChart(state: state))),
          ]),
        )),
      ]),
    );
  }
}

class _TarjetaEstado extends StatelessWidget {
  const _TarjetaEstado({required this.etiqueta, required this.cantidad, required this.color});
  final String etiqueta; final int cantidad; final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text('$cantidad', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        Text(etiqueta,    style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
      ]),
    ));
  }
}
EOF

cat > $PROJECT/features/map/data/datasources/location_datasource.dart << 'EOF'
import 'package:geolocator/geolocator.dart';
import '../../domain/usecases/get_location_usecase.dart';

class LocationDataSource {
  Future<PosicionGeo?> obtenerPosicion() async {
    final tienePermiso = await solicitarPermiso();
    if (!tienePermiso) return null;
    final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return PosicionGeo(latitud: p.latitude, longitud: p.longitude);
  }

  Future<bool> solicitarPermiso() async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) p = await Geolocator.requestPermission();
    return p == LocationPermission.always || p == LocationPermission.whileInUse;
  }
}
EOF

cat > $PROJECT/features/map/presentation/providers/map_provider.dart << 'EOF'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/location_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/usecases/get_location_usecase.dart';

class MapState {
  const MapState({this.posicion, this.cargando = false, this.sinPermiso = false, this.error});
  final PosicionGeo? posicion;
  final bool         cargando;
  final bool         sinPermiso;
  final String?      error;
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier(this._getLocation) : super(const MapState());
  final GetLocationUseCase _getLocation;

  Future<void> obtenerUbicacion() async {
    state = const MapState(cargando: true);
    try {
      final posicion = await _getLocation();
      state = posicion == null ? const MapState(sinPermiso: true) : MapState(posicion: posicion);
    } catch (_) {
      state = const MapState(error: 'Error al obtener ubicación');
    }
  }
}

final _datasourceProvider = Provider((_) => LocationDataSource());
final _repositoryProvider = Provider((ref) => LocationRepositoryImpl(ref.read(_datasourceProvider)));
final mapProvider = StateNotifierProvider<MapNotifier, MapState>(
  (ref) => MapNotifier(GetLocationUseCase(ref.read(_repositoryProvider))));
EOF

cat > $PROJECT/features/map/presentation/widgets/pharmacy_marker.dart << 'EOF'
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PharmacyMarker {
  static Set<Marker> crear({
    required List<Map<String, dynamic>> farmacias,
    required Function(String nombre) alPresionar,
  }) {
    return farmacias.asMap().entries.map((entry) {
      final f = entry.value;
      return Marker(
        markerId:   MarkerId('farmacia_${entry.key}'),
        position:   LatLng(f['latitud'] as double, f['longitud'] as double),
        infoWindow: InfoWindow(title: f['nombre'] as String, snippet: f['direccion'] as String? ?? ''),
        icon:       BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        onTap:      () => alPresionar(f['nombre'] as String),
      );
    }).toSet();
  }
}
EOF

cat > $PROJECT/features/map/presentation/pages/map_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../providers/map_provider.dart';
import '../widgets/pharmacy_marker.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});
  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _controladorMapa;
  final _farmacias = [
    {'nombre': 'Farmacia Cruz Verde', 'direccion': 'Cra 15 #93-75',       'latitud': 4.676, 'longitud': -74.048},
    {'nombre': 'Droguería La Rebaja', 'direccion': 'Cll 100 #15-10',      'latitud': 4.678, 'longitud': -74.050},
    {'nombre': 'Farmatodo',           'direccion': 'Av El Dorado #68C-61', 'latitud': 4.674, 'longitud': -74.052},
  ];

  @override
  void initState() { super.initState(); Future.microtask(() => ref.read(mapProvider.notifier).obtenerUbicacion()); }

  @override
  void dispose() { _controladorMapa?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Farmacias cercanas')),
      body: Builder(builder: (context) {
        if (state.cargando)   return const AppLoading(mensaje: 'Obteniendo ubicación...');
        if (state.sinPermiso) return Center(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.location_off_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('Se necesita acceso a tu ubicación', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(mapProvider.notifier).obtenerUbicacion(),
              child: const Text('Permitir ubicación'),
            ),
          ]),
        ));
        if (state.error != null) return Center(child: Text(state.error!));
        final pos = state.posicion!;
        return GoogleMap(
          onMapCreated:            (c) => _controladorMapa = c,
          initialCameraPosition:   CameraPosition(target: LatLng(pos.latitud, pos.longitud), zoom: 15),
          myLocationEnabled:       true,
          myLocationButtonEnabled: true,
          markers: PharmacyMarker.crear(
            farmacias:   _farmacias,
            alPresionar: (n) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(n))),
          ),
        );
      }),
    );
  }
}
EOF

cat > $PROJECT/features/settings/presentation/pages/settings_page.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temaActual   = ref.watch(themeNotifierProvider);
    final idiomaActual = ref.watch(localeNotifierProvider);

    final etiquetaTema = switch (temaActual) {
      ThemeMode.light  => 'Claro',
      ThemeMode.dark   => 'Oscuro',
      _                => 'Seguir el sistema',
    };
    final etiquetaIdioma = idiomaActual?.languageCode == 'en' ? 'English' : 'Español';

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(children: [
        _Seccion(titulo: 'Cuenta'),
        SettingsTile(icono: Icons.person_outline_rounded, titulo: 'Perfil',
            subtitulo: 'Ver y editar tu información',
            alPresionar: () => context.push('${AppRoutes.ajustes}/perfil')),
        const Divider(height: 1),
        _Seccion(titulo: 'Apariencia'),
        SettingsTile(icono: Icons.palette_outlined, titulo: 'Tema', subtitulo: etiquetaTema,
            alPresionar: () => context.push('${AppRoutes.ajustes}/tema')),
        SettingsTile(icono: Icons.language_rounded, titulo: 'Idioma', subtitulo: etiquetaIdioma,
            alPresionar: () => context.push('${AppRoutes.ajustes}/idioma')),
        const Divider(height: 1),
        _Seccion(titulo: 'Acerca de'),
        SettingsTile(icono: Icons.info_outline_rounded, titulo: 'Versión',
            subtitulo: '1.0.0', trailing: const SizedBox.shrink()),
      ]),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo});
  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(titulo, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary, letterSpacing: 0.5,
      )),
    );
  }
}
EOF

echo ""
echo "✅ Todos los imports corregidos."
echo "👉 Ahora corre: flutter run"
