import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionStatus {
  //Hook into flutter_connectivity's Stream to listen for changes
  //And check the connection status out of the gate
  ConnectionStatus() {
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    checkConnection();
  }

  //This tracks the current connection status
  bool hasConnection = false;

  //This is how we'll allow subscribing to connection changes
  StreamController<bool> connectionChangeController =
      StreamController<bool>.broadcast();

  //flutter_connectivity
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get connectionChange => connectionChangeController.stream;

  //A clean up method to close our StreamController
  void dispose() {
    connectionChangeController.close();
  }

  //flutter_connectivity's listener
  void _connectionChange(List<ConnectivityResult> result) {
    checkConnection();
  }

  //The test to actually see if there is a connection
  Future<bool> checkConnection() async {
    final previousConnection = hasConnection;

    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;
      } else {
        hasConnection = false;
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }

    //The connection status changed send out an update to all listeners
    if (previousConnection != hasConnection) {
      connectionChangeController.add(hasConnection);
    }

    return hasConnection;
  }
}
