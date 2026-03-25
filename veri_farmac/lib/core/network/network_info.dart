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
    return !result.contains(ConnectivityResult.none);
  }
}
