import 'package:azsphere_obd_app/classes/device.dart';
import 'package:hive/hive.dart';

import '../globals.dart';
import 'fuel.dart';
import 'logdata.dart';

part 'vehicle.g.dart';

@HiveType(typeId: 2)
class Vehicle {
  Vehicle(
      {this.brand, this.model, this.vin, this.fuel = CommonFuels.undefined}) {
    // logger.v('Vehicle constructor called, opening "vehicle-data" Hive box.');
    _hiveReady = _getVehicleBox();
  }

  Future _getVehicleBox() async {
    if (!Hive.isBoxOpen('vehicle-data')) {
      storedVehicleData = await Hive.openBox('vehicle-data');
    } else {
      storedVehicleData = Hive.box('vehicle-data');
    }
  }

  @HiveField(0)
  String imagePath;

  @HiveField(1)
  String brand;
  @HiveField(2)
  String model;
  @HiveField(3)
  String vin;
  @HiveField(4)
  Fuel fuel;
  @HiveField(5)
  List<LogSession> logSessions = new List<LogSession>();
  @HiveField(6)
  List<RemoteFile> knownFiles = new List<RemoteFile>();

  List<RemoteFile> downloadQueue = new List<RemoteFile>();
  int totalDownloadSize = 0;
  int totalDownloadedBytes = 0;

  Function(double) onDownloadProgressUpdate;

  Box storedVehicleData;
  Future _hiveReady;

  Future get hiveReady => _hiveReady;

  /// Starts the download process
  void askRemoteLogs() {
    logger.i('Starting download process.');

    if (onDownloadProgressUpdate != null) onDownloadProgressUpdate(0);
    parseStarted = false;

    // Step 1: Get last file name.
    globalScanner.onLastFileNumberReceived = _fileNumberReceived;
    globalScanner.requestLastFileNumber();
  }

  /// Last file number receive handler
  void _fileNumberReceived(OBDScanner scanner, int lastFileNumber) {
    logger.d('Last file number is $lastFileNumber.');

    _fileMatchCounter = 0;

    // Step 2: Ask the last file size.
    globalScanner.onFileSizeReceived = _fileSizeReceived;
    globalScanner.requestFileSize(lastFileNumber);
  }

  int _fileMatchCounter = 0;
  void _fileSizeReceived(OBDScanner scanner, String fileName, int fileSize) {
    logger.v('Size of $fileName is $fileSize bytes.');

    bool found = false;

    // Step 3: Update file info in list
    for (RemoteFile f in knownFiles) {
      if (f.name == fileName) {
        // Same name found
        if (f.size == fileSize + 1) {
          // Same info
          _fileMatchCounter++;
        } else {
          // Same name, different size: update
          // Size is always received + 1
          f.size = fileSize == 0 ? 0 : fileSize + 1;
          f.content = '';
          _fileMatchCounter = 0;
        }
        found = true;
        break;
      }
    }

    if (!found) {
      // Add the file info to the list
      knownFiles.add(new RemoteFile(
          name: fileName, size: fileSize == 0 ? 0 : fileSize + 1));
      _fileMatchCounter = 0;
    }

    // Step 4: Ask all the other files' sizes until 0.LOG or after five same logs while all the other ones are saved.
    bool skip = false;
    List<int> fileNumbers = new List<int>();
    if (_fileMatchCounter >= 5) {
      skip = true;

      logger.v("$_fileMatchCounter matches found.");
      for (RemoteFile f in knownFiles) {
        fileNumbers.add(int.tryParse(f.name.split('.')[0]));
      }

      fileNumbers.sort((a, b) => (a.compareTo(b)));

      for (int i = 0; i < fileNumbers.length; i++) {
        if (fileNumbers[i] != i) {
          skip = false;
        }
      }

      if (skip) logger.i('All file info present. Other files can be skipped.');
    }

    if (fileName.toUpperCase() != '0.LOG' && !skip) {
      int nextFileNumber = int.parse(fileName.split('.')[0]) - 1;
      globalScanner.requestFileSize(nextFileNumber);
    } else {
      // Step 5: At the end, sort list and compute download
      knownFiles.sort((a, b) => (int.tryParse(a.name.split('.')[0])
          .compareTo(int.tryParse(b.name.split('.')[0]))));
      logger.i(
          '${knownFiles.length} files\' info downloaded. Computing download queue.');

      downloadQueue.clear();
      totalDownloadSize = 0;
      for (RemoteFile f in knownFiles) {
        if (f.downloadedBytes * 1.1 < f.size) {
          totalDownloadSize += f.size;
          f.downloadedBytes = 0;
          downloadQueue.add(f);
        }
      }

      logger.i(
          '${downloadQueue.length} files put in the download queue. Total download size is ${OBDScanner.byteSizeToString(totalDownloadSize)}.');

      // Step 6: Start downloading the first file
      globalScanner.onFileContentReceived = _fileContentReceived;
      globalScanner.requestFileContent(
          int.tryParse(downloadQueue.first.name.split('.')[0]));
    }
  }

  bool parseStarted = false;
  int lastFileNumber = 0;
  void _fileContentReceived(OBDScanner scanner, RemoteFile file) {
    logger.v('${file.name} received.');

    if (onDownloadProgressUpdate != null)
      onDownloadProgressUpdate(totalDownloadedBytes / totalDownloadSize);
    totalDownloadedBytes += file.downloadedBytes;

    // Step 7: Consolidate with downloadQueue list
    for (RemoteFile f in downloadQueue) {
      if (f.name.toUpperCase() == file.name.toUpperCase()) {
        if (f.downloadedBytes > 0) break;

        f
          ..content = file.content
          ..downloadedBytes = file.downloadedBytes;
        logger.v('${f.downloadedBytes} out of ${f.size} bytes downloaded.');
        break;
      }
    }

    // Step 8: Ask next file or end
    int nextFileNumber;
    for (RemoteFile f in downloadQueue) {
      if (f.downloadedBytes == 0 && !f.asked) {
        f.asked = true;
        nextFileNumber = int.tryParse(f.name.split('.')[0]);
        lastFileNumber = nextFileNumber ?? lastFileNumber;
        break;
      }
    }

    // Step 9: Check when all the files have been downloaded
    int notDownloadedFiles = 0;
    for (RemoteFile f in downloadQueue) {
      if (!f.asked || !(f.downloadedBytes > 0)) {
        notDownloadedFiles++;
        break;
      }
    }

    if (nextFileNumber != null) {
      logger.v('Asking $nextFileNumber.log\'s contents.');
      globalScanner.requestFileContent(nextFileNumber);

      // We received the last available file
    } else if (notDownloadedFiles <= 1) {
      logger.i('Download finished.');

      // Consolidate download list with knownFiles
      for (RemoteFile source in downloadQueue) {
        int destIndex = knownFiles.indexWhere((RemoteFile f) =>
            (f.name.toUpperCase() == source.name.toUpperCase()));
        knownFiles[destIndex] = source;
      }

      // Create a buffer with the contents of all the downloaded files
      StringBuffer stringBuffer = new StringBuffer();

      for (RemoteFile f in downloadQueue) {
        stringBuffer.write(f.content);
      }

      if (!parseStarted) {
        parseAndSave(stringBuffer);
      }

      if (onDownloadProgressUpdate != null) onDownloadProgressUpdate(1);
    }
  }

  void parseAndSave(StringBuffer stringBuffer) {
    // Convert to sessions
    logSessions.addAll(SessionImporter.logSessionListFromString(
        stringBuffer.toString(), checkItemDateTime));
    parseStarted = true;
    // Save to hive
    save();
  }

  bool checkItemDateTime(DateTime input) {
    for (LogSession ls in logSessions) {
      if (input.compareTo(ls.stopGmtDateTime) < 0 &&
          input.compareTo(ls.startGmtDateTime) > 0) {
        return false;
      }
    }
    return true;
  }

  void save() async {
    logger.v('Saving vehicle data');

    // Wait for hive initialization
    await this.hiveReady;

    await storedVehicleData.put('vehicle', this);

    logger.d('Image path is "${this.imagePath}.');
  }

  void restore() async {
    logger.v('Restoring vehicle data.');

    // Wait for hive initialization
    Vehicle v = new Vehicle();

    await this.hiveReady;
    await v.hiveReady;

    v = await storedVehicleData.get('vehicle', defaultValue: new Vehicle());

    this
      ..fuel = v.fuel
      ..brand = v.brand
      ..model = v.model
      ..imagePath = v.imagePath
      ..knownFiles = v.knownFiles
      ..logSessions = v.logSessions
      ..vin = v.vin;

    // CommonFuel index
    if (this.fuel.name == null) {
      this.fuel = CommonFuels.undefined;
    }

    logger.d('Restored fuel is ${this.fuel.name}.');

    logger.d('Restored image path is ${this.imagePath}.');
  }
}

/// A class that represents a file on the remote device's SD card.
@HiveType(typeId: 5)
class RemoteFile {
  RemoteFile({this.name, this.size});

  @HiveField(0)
  String name;
  @HiveField(1)
  int size;
  @HiveField(2)
  int downloadedBytes = 0;
  @HiveField(3)
  bool parsed = false;
  @HiveField(4)
  String content = '';

  bool asked = false;
}
