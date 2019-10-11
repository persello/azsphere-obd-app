import 'package:hive/hive.dart';

import '../globals.dart';

part 'logdata.g.dart';

/// Utilities to import and convert data from raw to a structure.
class SessionImporter {
  /// Returns a list of sessions by parsing data contained into a string.
  ///
  /// [itemDateTimeChecker] should return [true] if the supplied [DateTime] is still unknown,
  /// [false] if that item is already inside the date tuples.
  static List<LogSession> logSessionListFromString(
      String input, bool Function(DateTime) itemDateTimeChecker) {
    List<RawTimedItem> temporaryItemBuffer = new List<RawTimedItem>();

    logger.i('Importing session from string. String size is ${input.length} bytes.');

    List<String> rawItems = input.split('\r\n');

    logger.i('Input splitted into ${rawItems.length} parts.');

    for (String rawItem in rawItems) {
      RawTimedItem timedItem = new RawTimedItem();
      if (timedItem.fromString(rawItem)) {
        // If the parsing succeeds, add it to the temporary list.
        temporaryItemBuffer.add(timedItem);
      }
    }

    logger.i('${temporaryItemBuffer.length} out of ${rawItems.length} were correctly parsed.');

    logger.v('Sorting log item list chronologically.');

    temporaryItemBuffer.sort((a, b) => a.gmtDateTime.compareTo(b.gmtDateTime));

    logger.v('Splitting into sessions.');

    List<LogSession> returnList = new List<LogSession>();

    LogSession currentSession = new LogSession();

    for (int i = 0; i < temporaryItemBuffer.length - 1; i++) {
      // Time difference greater than 2 minutes: split.
      if (temporaryItemBuffer[i + 1].gmtDateTime.difference(temporaryItemBuffer[i].gmtDateTime).inMinutes >
          2) {
        // Prepare
        try {
          currentSession.complete = true;
          currentSession.normalizeDateTime();
          currentSession.startGmtDateTime = currentSession.rawTimedData.first.gmtDateTime;
          currentSession.stopGmtDateTime = currentSession.rawTimedData.last.gmtDateTime;
          returnList.add(currentSession);
        } catch (ex) {
          logger.w('Error while splitting sessions: ${ex.toString}.');
        }

        // Reset the current session
        currentSession = new LogSession();
      }
      // Still current session: add data to it.
      else {
        if (itemDateTimeChecker(temporaryItemBuffer[i].gmtDateTime))
          currentSession.rawTimedData.add(temporaryItemBuffer[i]);
      }
    }

    try {
      currentSession.complete = true;
      currentSession.normalizeDateTime();
      currentSession.startGmtDateTime = currentSession.rawTimedData.first.gmtDateTime;
      currentSession.stopGmtDateTime = currentSession.rawTimedData.last.gmtDateTime;
      returnList.add(currentSession);
    } catch (ex) {
      logger.w('Error while splitting sessions: ${ex.toString}.');
    }

    logger.i('${returnList.length} sessions created.');

    return returnList;
  }
}

/// Represents all the logged data in a session.
/// A session stops when the log stops for more than 2 minutes.
@HiveType()
class LogSession {
  /// All the log items of the session with time information.
  @HiveField(0)
  List<RawTimedItem> rawTimedData = new List<RawTimedItem>();

  @HiveField(1)
  DateTime startGmtDateTime;

  @HiveField(2)
  DateTime stopGmtDateTime;

  @HiveField(3)
  bool complete;

  /// Normalizes date and time of the [rawTimedData] items.
  /// This is used to cancel time jumps when the device's clock
  /// is synced to a GPS satellite or a server.
  void normalizeDateTime() {
    logger.i('Normalizing log session date/time.');

    logger.v('Sorting timed data log items.');

    rawTimedData.sort((a, b) => (a.gmtDateTime.compareTo(b.gmtDateTime)));

    DateTime after;
    DateTime before;
    Duration delta = Duration.zero;

    for (int i = rawTimedData.length - 1; i > 0; i--) {
      if (rawTimedData[i].type == RawLogItemType.TimeUpdateAfter) {
        // Calculate delta (remember to subtract exactly one second)
        after = rawTimedData[i].gmtDateTime;
        before = rawTimedData[i - 1].gmtDateTime;
        delta += (after.difference(before) - new Duration(seconds: 1));

        // Clear time markers
        rawTimedData.removeAt(i);
        rawTimedData.removeAt(i - 1);
        i--;
      } else {
        // Align times
        rawTimedData[i].gmtDateTime = rawTimedData[i].gmtDateTime.add(delta);
      }
    }

    logger.i(
        'Normalization complete: last total delta was ${delta.inMilliseconds} milliseconds (${delta.inDays} days).');
  }
}

/// A single log item with time information, with a single piece of information (like on the SD card).
@HiveType()
class RawTimedItem {
  /// Populates the properties based on the raw string content.
  /// returns [true] if successful, [false] if not.
  bool fromString(String rawContent) {
    // logger.d('Trying to parse log line: $rawContent.');

    String rawType;
    String rawDateTime;

    try {
      // Date and time
      rawDateTime = rawContent.split('\t')[0];
      gmtDateTime = DateTime.tryParse(rawDateTime);
    } catch (ex) {
      logger.w('Error while parsing log line date/time: Input was $rawDateTime. Error: ${ex.toString}.');
      return false;
    }

    try {
      // Type
      rawType = rawContent.split('\t')[1];
      type = _typeMap[rawType];

      // Content
      switch (type) {
        // These types have textual information
        case RawLogItemType.Initializer:
        case RawLogItemType.TimeUpdateBefore:
        case RawLogItemType.TimeUpdateAfter:
          textContent = rawContent.split('\t')[2];
          break;

        // Other ones are numbers
        default:
          numericContent = double.tryParse(rawContent.split('\t')[2]);
          break;
      }
    } catch (ex) {
      logger.w('Error while parsing log line type: Input was $rawType. Error: ${ex.toString}.');
      return false;
    }

    if ((textContent == null && numericContent == null) || gmtDateTime == null) {
      return false;
    }

    return true;
  }

  /// Private map of all the log item types with relative string identifiers.
  static const Map _typeMap = {
    'ASPHEREOBD': RawLogItemType.Initializer,
    'RTCOLDTIME': RawLogItemType.TimeUpdateBefore,
    'RTCNEWTIME': RawLogItemType.TimeUpdateAfter,
    'RTLATITUDE': RawLogItemType.Latitude,
    'RTLONGITUD': RawLogItemType.Longitude,
    'GPSSPEEDKM': RawLogItemType.GPSSpeed,
    'GPSVCOURSE': RawLogItemType.GPSCourse,
    'CARECUINIT': RawLogItemType.EcuInitialization,
    'BATVOLTAGE': RawLogItemType.BatteryVoltage,
    'ENGINETEMP': RawLogItemType.EngineTemperature,
    'VEHICLERPM': RawLogItemType.EngineRPM,
    'VEHICSPEED': RawLogItemType.Speed,
    'ENGAIRFLOW': RawLogItemType.Airflow,
    'ENTHROTTLE': RawLogItemType.ThrottlePosition
  };

  /// Date and time of the log line.
  @HiveField(0)
  DateTime gmtDateTime;

  /// Type of the log line.
  @HiveField(1)
  RawLogItemType type;

  /// Content of the log line (if it is a number).
  @HiveField(2)
  double numericContent;

  /// Content of the log line (if it is not a number).
  @HiveField(3)
  String textContent;
}

/// All the types of log items that can be found on an SD card log file.
@HiveType()
enum RawLogItemType {
  @HiveField(0)
  Initializer,

  @HiveField(1)
  TimeUpdateBefore,

  @HiveField(2)
  TimeUpdateAfter,

  @HiveField(3)
  Latitude,

  @HiveField(4)
  Longitude,

  @HiveField(5)
  GPSSpeed,

  @HiveField(6)
  GPSCourse,

  @HiveField(7)
  EcuInitialization,

  @HiveField(8)
  BatteryVoltage,

  @HiveField(9)
  EngineTemperature,

  @HiveField(10)
  EngineRPM,

  @HiveField(11)
  Speed,

  @HiveField(12)
  Airflow,

  @HiveField(13)
  ThrottlePosition,

  @HiveField(14)
  None
}
