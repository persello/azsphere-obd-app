import 'dart:async';
import 'dart:core';

import 'dart:io';

import 'package:azsphere_obd_app/globals.dart';

const String MessageHeader_Ping = "PING";
const String MessageHeader_ScanWiFiNetworks = "WISC";
const String MessageHeader_KnownWiFiNetworks = "WISA";
const String MessageHeader_AddNetwork = "WIAD";
const String MessageHeader_RemoveNetwork = "WIRM";
const String MessageHeader_OOBE = "OOBE";
const String MessageHeader_ButtonA = "BTNA";
const String MessageHeader_ButtonB = "BTNB";
const String MessageHeader_OBDModuleConnected = "OBDC";
const String MessageHeader_CarConnected = "CARC";
const String MessageHeader_SDMounted = "SDMN";
const String MessageHeader_SDSize = "SDSZ";
const String MessageHeader_LastFileName = "LFNM";
const String MessageHeader_GetFileSize = "GFSZ";
const String MessageHeader_GetFileContent = "GFIL";

/// A TCP Message class.
///
/// It is simply a wrapper for two strings that can also set them
/// from the parameters given in the constructor or from a string.
/// A message is composed by 4 header characters and n argument
/// characters. When using [TCPMessage.fromString()], be sure to
/// not include the trailing \r\n.
class TCPMessage {
  TCPMessage({this.arguments, this.header});
  TCPMessage.fromString(String s) {
    this.header = s.trim().substring(0, 4);
    this.arguments = s.trim().substring(4);
  }
  String header;
  String arguments;
}

enum OBDScannerConnectionStatus {
  STATUS_UNKNOWN,
  STATUS_DISCONNECTED,
  STATUS_CONNECTED,

  // TODO: add other status items
}

/// The main class for describing a wireless OBD scanner.
class OBDScanner {
  /// The status of the Wi-Fi connection.
  OBDScannerConnectionStatus status = OBDScannerConnectionStatus.STATUS_UNKNOWN;

  /// The private socket for communicating via TCP.
  Socket _socket; // Underscore = private

  /// The IP address of the interface used to connect the scanner to the network (usually wlan0).
  String ipAddress;

  /// The list of all the Wi-Fi networks saved or scanned by the device.
  List<WiFiNetwork> networks = new List<WiFiNetwork>();

  /// A timer that periodically calls a ping function in order to detect connection status changes.
  Timer _pingTimer;

  /// The moment in which the last successful ping with the scanner happened.
  DateTime lastSuccessfulPing;

  /// Indicates whether the app is waiting for a ping response.
  ///
  /// If the response is received after the following ping request, the connection is closed automatically.
  bool _pingResponsePending = false;

  /// Callback function for connection changed events.
  Function(OBDScanner, OBDScannerConnectionStatus) onConnectionChanged;

  /// Callback function for new messages.
  Function(OBDScanner, TCPMessage) onMessageReceived;

  /// Callback function for button A press event (on board).
  Function(OBDScanner) onButtonAPressed;

  /// Callback function for button B press event (on board).
  Function(OBDScanner) onButtonBPressed;

  /// The raw TCP receive buffer. Simply an unprocessed result of a stream of characters.
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
    Socket.connect(ipAddress, 15500, timeout: Duration(milliseconds: 50))
        .then((Socket s) {
      _socket = s;
      _socket.listen(_newTCPData, onError: _socketError);

      _pingTimer = Timer.periodic(Duration(seconds: 10), (Timer t) => _ping());
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
    if (!_pingResponsePending) {
      TCPMessage message = TCPMessage.fromString(MessageHeader_Ping);
      sendMessage(message);
      _pingResponsePending = true;
    } else {
      closeConnection();
    }
  }

  /// Sends a [TCPMessage] object after converting it to a string and adding a trailing \r\n
  void sendMessage(TCPMessage message) {
    this._socket.write(message.header + (message.arguments ?? "") + "\r\n");
  }

  /// Called when all the operations on the socket are complete and it should be closed.
  void _socketDone() {
    closeConnection();
  }

  /// Called when an error happens during socket-related I/O actions.
  void _socketError(error, StackTrace trace) {
    closeConnection();
  }

  /// Closes the connection with the scanner and cancels the ping timer.
  ///
  /// Calls [onConnectionChanged] after actually closing the socket.
  void closeConnection() {
    if (_pingTimer != null) {
      _pingTimer.cancel();
    }
    if (_socket != null) {
      _socket.destroy();
    }

    // In order to allow reconnection
    _pingResponsePending = false;
    status = OBDScannerConnectionStatus.STATUS_DISCONNECTED;
    if (onConnectionChanged != null) onConnectionChanged(this, status);
  }

  /// Called when new raw TCP data is available.
  ///
  /// Converts the received data into one or more message strings first,
  /// then to messages which will be parsed internally. Finally calls the
  /// [onMessageReceived] callback function and passes the latest message
  /// as an argument.
  void _newTCPData(data) {
    // First we need to convert the array of characters into a string object
    String received = new String.fromCharCodes(data);

    // Then, if the value corresponds to an initialization message, we change the connection status if not already done.
    if (status == OBDScannerConnectionStatus.STATUS_UNKNOWN &&
        received.startsWith("Azure Sphere OBD Scanner")) {
      status = OBDScannerConnectionStatus.STATUS_CONNECTED;
      onConnectionChanged(this, status);
      return;
    }

    print(
        "OBDScanner class - newTCPData: Received data from the device: $received.");

    // We save the received data into the general buffer.
    // This way an eventual previously incomplete message gets completed.
    _receiveBuffer.write(received);

    // Now we work directly on the entire buffer.

    // When it contains a \r\n sequence, we have a message for sure...
    while(_receiveBuffer.toString().contains("\r\n")) {
      print(
          "OBDScanner class - newTCPData: The receive buffer contains a message.");
      int indexOfReturn = _receiveBuffer.toString().indexOf("\r\n");

      // We consider the current message's string as the first part of the buffer, until the \r character
      String currentMessageString =
          _receiveBuffer.toString().substring(0, indexOfReturn);

      // Then we consider the remaining part
      String temp = _receiveBuffer.toString().substring(indexOfReturn + 2);

      // And we reset the buffer by re-adding only that
      _receiveBuffer.clear();
      _receiveBuffer.write(temp);

      // We create a message with the extracted part...
      TCPMessage message = TCPMessage.fromString(currentMessageString);

      parse(message);
      if (onMessageReceived != null) onMessageReceived(this, message);
    }
  }

  /// Filters messages such as ping because are not useful for the user.
  ///
  /// Returns true if filtered, false if not.
  bool parse(TCPMessage message) {
    bool ret = true;

    switch (message.header) {
      case MessageHeader_Ping:
        _pingResponsePending = false;
        lastSuccessfulPing = DateTime.now();
        if (status != OBDScannerConnectionStatus.STATUS_CONNECTED) {
          status = OBDScannerConnectionStatus.STATUS_CONNECTED;
          onConnectionChanged(this, status);
        }
        break;

      case MessageHeader_ButtonA:
        onButtonAPressed(this);
        break;

      case MessageHeader_ButtonB:
        onButtonBPressed(this);
        break;

      case MessageHeader_KnownWiFiNetworks:

        // WISA - F = found
        // TODO: Catch WISAN and WISAE
        if (message.arguments.startsWith("F")) {
          /* We are receiving a list of known networks in the following format:
            WISAF[^]<SSID1>#<SSID2>#...#<SSIDN> */

          // The received arguments splitted by #
          List<String> splitArguments = new List<String>();

          // Splits the arguments
          splitArguments = message.arguments.substring(1).split("#");

          // And for each one
          for (String s in splitArguments) {
            WiFiNetwork n =  WiFiNetwork();

            // It is saved for sure
            n.isSaved = true;

            // If it has the ^ marker, it means that it is connected (and available)
            if (s.startsWith("^")) {
              s = s.substring(1);
              n.isConnected = true;
              n.isCurrentlyAvailable = true;
            }

            // If it still has a * marker after removing ^, it means that the network is protected
            if (s.startsWith("*")) {
              s = s.substring(1);
              n.isProtected = true;
            }

            // After removing the eventual ^ we have our SSID
            n.ssid = s;

            // Now let's check for other items with the same SSID
            // Using contains() wouldn't work because we only need to check items with the same SSID and eventually update them

            // We keep an index for an eventual found network
            int indexWithSameSSID = -1;

            // Then, for each network we compare only the SSID and we set the index accordingly
            // This does not take into account multiple entries with the same name, since this removes duplicates by itself
            // TODO: Use BSSID instead
            for (WiFiNetwork existingNetwork in networks) {
              if (existingNetwork.ssid == n.ssid) {
                indexWithSameSSID = networks.indexOf(existingNetwork);
              }
            }

            // If there were no duplicates, we simply add the network
            if (indexWithSameSSID == -1) {
              networks.add(n);
            }
            // Otherwise we update only the parameters given by the saved network list (isConnected, isSaved, isProtected)
            else {
              networks[indexWithSameSSID].isConnected = n.isConnected;
              networks[indexWithSameSSID].isSaved = n.isSaved;
              networks[indexWithSameSSID].isProtected = n.isProtected;
            }
          }
        }
        break;
      case MessageHeader_ScanWiFiNetworks:

        // WISC - F = found
        // TODO: Catch WISCN and WISCE
        if (message.arguments.startsWith("F")) {
          /* We are receiving a list of available networks in the following format:
            WISCF<SSID1>^<RSSI1>#<SSID2>^<RSSI2>#...#<SSIDN>^<RSSIN> */

          List<String> splitArguments = new List<String>();

          // Splits the arguments
          splitArguments = message.arguments.substring(1).split("#");

          // And for each one
          for (String s in splitArguments) {
            WiFiNetwork n = WiFiNetwork();

            // It is available for sure
            n.isCurrentlyAvailable = true;

            // The RSSI is given by the second parameter (after ^)
            n.rssi = int.parse(s.split("^")[1]);

            // We get the SSID and check whether the network is protected (*)
            String ssid = s.split("^")[0];
            if (ssid.startsWith("*")) {
              ssid = ssid.substring(1);
              n.isProtected = true;
            }

            // The SSID is the first parameter
            n.ssid = ssid;

            // Now let's check for other items with the same SSID
            // Using contains() wouldn't work because we only need to check items with the same SSID and eventually update them

            // We keep an index for an eventual found network
            int indexWithSameSSID = -1;

            // Then, for each network we compare only the SSID and we set the index accordingly
            // This does not take into account multiple entries with the same name, since this removes duplicates by itself
            for (WiFiNetwork existingNetwork in networks) {
              if (existingNetwork.ssid == n.ssid) {
                indexWithSameSSID = networks.indexOf(existingNetwork);
              }
            }

            // If there were no duplicates, we simply add the network
            if (indexWithSameSSID == -1) {
              networks.add(n);
            }
            // Otherwise we update only the parameters given by the scanned network list (RSSI, isCurrentlyAvailable)
            else {
              networks[indexWithSameSSID].isCurrentlyAvailable =
                  n.isCurrentlyAvailable;
              networks[indexWithSameSSID].rssi = n.rssi;
              networks[indexWithSameSSID].isProtected = n.isProtected;
            }
          }
        }
        break;
      default:
        ret = false;
    }
    return ret;
  }
}
