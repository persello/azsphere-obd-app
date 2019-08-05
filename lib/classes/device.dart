import 'dart:async';
import 'dart:core';

import 'dart:io';

import 'package:flutter/widgets.dart';

class TCPMessage {
  TCPMessage({this.arguments, this.header});
  TCPMessage.fromString(String s) {
    this.header = s.trim().substring(0, 4);
    this.arguments = s.trim().substring(4);
  }
  String header;
  String arguments;
}

enum OBDScannerStatus {
  STATUS_UNKNOWN,
  STATUS_DISCONNECTED,
  STATUS_IDLE,
  STATUS_OOBE,

  // TODO: add other statuses
}

class OBDScanner {
  OBDScannerStatus status = OBDScannerStatus.STATUS_UNKNOWN;
  Socket _socket; // Underscore = private
  String ipAddress;

  Timer _pingTimer;
  DateTime lastSuccessfulPing;
  bool _pingResponsePending;

  Function(OBDScanner, OBDScannerStatus) onConnectionChanged;
  Function(TCPMessage) onMessageReceived;

  Function(OBDScanner) onButtonAPressed;
  Function(OBDScanner) onButtonBPressed;

  StringBuffer _receiveBuffer = new StringBuffer();

  // Constructor
  OBDScanner(
      {this.ipAddress,
      this.onMessageReceived,
      this.onConnectionChanged,
      this.onButtonAPressed,
      this.onButtonBPressed});

  /// Tries to connect to the object's ip address.
  ///
  /// Sets the [_socket] variable and starts the [_pingTimer]
  /// if the operation is successful.
  void connect() {
    Socket.connect(ipAddress, 15500, timeout: Duration(milliseconds: 100))
        .then((Socket s) {
      _socket = s;
      _socket.listen(_newTCPData, onError: _socketError, onDone: _socketDone);

      //_pingTimer = Timer.periodic(Duration(seconds: 3), (Timer t) => _ping());
    }).catchError((e) {
      print(
          "OBDScanner class - connect: Connection to $ipAddress failed. Error: ${e.toString()}.");
      closeConnection();
    });
  }

  /// Sends a ping to the device.
  ///
  /// Sends a ping if connected and closes the connection if the previous ping is still
  /// awaiting for a response. The response will be parsed by the interpreter which
  /// will also update the [lastSuccesfulPing] variable.
  void _ping() {
    if (this.status != OBDScannerStatus.STATUS_DISCONNECTED &&
        !_pingResponsePending) {
      TCPMessage message = TCPMessage.fromString("PING");
      _sendMessage(message);
      _pingResponsePending = true;
    } else {
      closeConnection();
    }
  }

  void _sendMessage(TCPMessage message) {
    this._socket.write(message.header + message.arguments);
  }

  void _socketDone() {
    closeConnection();
  }

  void _socketError(error, StackTrace trace) {
    closeConnection();
  }

  void closeConnection() {
    if (_pingTimer != null) {
      _pingTimer.cancel();
    }
    if (_socket != null) {
      _socket.destroy();
    }
    status = OBDScannerStatus.STATUS_DISCONNECTED;
    onConnectionChanged(this, status);
  }

  void _newTCPData(data) {
   String received = new String.fromCharCodes(data);

    if (status == OBDScannerStatus.STATUS_UNKNOWN && received.startsWith("Azure Sphere OBD Scanner")) {
      status = OBDScannerStatus.STATUS_IDLE;
      onConnectionChanged(this, status);
      print("DATA RECEIVED ($ipAddress)!");
      return;
    }

    print(
        "OBDScanner class - newTCPData: Received data from the device: $received.");
    _receiveBuffer.write(received);
    if (_receiveBuffer.toString().contains("\r\n")) {
      print(
          "OBDScanner class - newTCPData: The receive buffer contains a message.");
      int indexOfReturn = _receiveBuffer.toString().indexOf("\r\n");

      // We consider the current message's string as the first part of the buffer, until the \r character
      String currentMessageString = _receiveBuffer.toString().substring(0, indexOfReturn);

      // Then we consider the remaining part
      String temp = _receiveBuffer.toString().substring(indexOfReturn + 2);

      // And we reset the buffer by re-adding only that
      _receiveBuffer.clear();
      _receiveBuffer.write(temp);

      // We create a message with the extracted part...
      TCPMessage message = TCPMessage.fromString(currentMessageString);

      if (!filterMessage(message)) {
        onMessageReceived(message);
      }
    }
  }

  /// Filters messages such as ping because are not useful for the user.
  ///
  /// Returns true if filtered, false if not.
  bool filterMessage(TCPMessage message) {
    bool ret = true;

    switch (message.header) {
      case "PING":
        _pingResponsePending = false;
        lastSuccessfulPing = DateTime.now();
        break;
      case "BTNA":
        onButtonAPressed(this);
        break;
      case "BTNB":
        onButtonBPressed(this);
        break;
      default:
        ret = false;
    }
    return ret;
  }
}
