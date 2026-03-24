// Verifica si hay conexión a internet.
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

// Verifica si el dispositivo tiene conexión activa.
// Se usa antes de hacer llamadas a la API.
abstract class INetworkInfo {
  Future<bool> get isConnected;
}

@LazySingleton(as: INetworkInfo)
class NetworkInfo implements INetworkInfo {
  const NetworkInfo(this._connectivity);
  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final resultado = await _connectivity.checkConnectivity();
    // Hay conexión si no está en modo "none"
    return resultado != ConnectivityResult.none;
  }
}
