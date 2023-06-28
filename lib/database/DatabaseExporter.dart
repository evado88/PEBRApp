import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pebrapp/database/DatabaseProvider.dart';
import 'package:pebrapp/database/R21ExportInfo.dart';
import 'package:pebrapp/database/models/Patient.dart';
import 'package:path/path.dart';
import 'package:pebrapp/database/models/R21Appointment.dart';
import 'package:pebrapp/database/models/R21Event.dart';
import 'package:pebrapp/database/models/R21Followup.dart';
import 'package:pebrapp/database/models/R21MedicationRefill.dart';
import 'package:pebrapp/database/models/R21ScreenAnalytic.dart';
import 'package:pebrapp/database/models/UserData.dart';
import 'dart:io';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

/// Exports the database as a CSV file an uploads it to PEBRAcloud.
class DatabaseExporter {
  static const EXCEL_FILENAME = 'PEBRA_Data.xlsx';
  static const _EXCEL_TEMPLATE_PATH = 'assets/excel/PEBRA_Data_template.xlsx';

  /// Writes database data to Excel (xlsx) file and returns that file.
  static Future<R21ExportInfo> exportDatabaseToExcelFile(
      UserData loginData) async {
    // these are the name of the sheets in the template excel file
    const String userDataSheet = 'User Data';
    const String patientSheet = 'Participant';

    const String eventsSheet = 'Events';
    const String appointmentsSheet = 'Appointments';
    const String followupsSheet = 'Followups';
    const String medicationRefilsSheet = 'Medication Refils';
    const String analyticsSheet = 'Analytics';

    // open database
    final DatabaseProvider dbp = DatabaseProvider();
    // open excel template file
    final String filepath =
        join(await dbp.databasesDirectoryPath, EXCEL_FILENAME);
    ByteData data = await rootBundle.load(_EXCEL_TEMPLATE_PATH);
    final File excelFile = await File(filepath).writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    final List<int> bytes = excelFile.readAsBytesSync();
    final decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);

    void _writeRowsToExcel(
        String sheetName, List<String> headerRow, List<IExcelExportable> rows) {
      // make enough rows
      for (var i = 0; i < rows.length; i++) {
        decoder.insertRow(sheetName, i + 1);
      }

      // make enough columns
      for (var i = 1; i < headerRow.length; i++) {
        decoder.insertColumn(sheetName, i);
      }

      // write header row
      for (var i = 0; i < headerRow.length; i++) {
        decoder.updateCell(sheetName, i, 0, headerRow[i]);
      }

      // write rows
      for (var i = 0; i < rows.length; i++) {
        List<dynamic> row = rows[i].toExcelRow();
        // write all columns of current row
        for (var j = 0; j < headerRow.length; j++) {
          decoder.updateCell(sheetName, j, i + 1, row[j]);
        }
      }
    }

    String username = loginData.username;
    StringBuffer jEvents = StringBuffer();
    StringBuffer jAnalytics = StringBuffer();
    StringBuffer jParticipants = StringBuffer();
    StringBuffer jUsers = StringBuffer();
    StringBuffer jAppointments = StringBuffer();
    StringBuffer jFollowups = StringBuffer();
    StringBuffer jMedicationRefils = StringBuffer();

    final List<UserData> userDataRows = await dbp.retrieveAllUserData();
    _writeRowsToExcel(userDataSheet, UserData.excelHeaderRow, userDataRows);

    userDataRows.forEach((us) {
      if (jUsers.length != 0) {
        jUsers.write(',\n');
      }
      jUsers.write('${us.toJson(username)}\n');
    });

    final List<Patient> patientRows = await dbp.retrieveAllPatients();
    _writeRowsToExcel(patientSheet, Patient.excelHeaderRow, patientRows);

    patientRows.forEach((pt) {
      if (jParticipants.length != 0) {
        jParticipants.write(',\n');
      }
      jParticipants.write('${pt.toJson(username)}\n');
    });

    final List<R21Event> eventsRows = await dbp.retrieveAllEventData();
    _writeRowsToExcel(eventsSheet, R21Event.excelHeaderRow, eventsRows);

    eventsRows.forEach((ev) {
      if (jEvents.length != 0) {
        jEvents.write(',\n');
      }
      jEvents.write('${ev.toJson(username)}\n');
    });

    final List<R21Followup> followupsRows = await dbp.retrieveAllFollowupData();
    _writeRowsToExcel(
        followupsSheet, R21Followup.excelHeaderRow, followupsRows);

    followupsRows.forEach((fl) {
      if (jFollowups.length != 0) {
        jFollowups.write(',\n');
      }
      jFollowups.write('${fl.toJson(username)}\n');
    });

    final List<R21Appointment> appointmentsRows =
        await dbp.retrieveAllAppointmentData();
    _writeRowsToExcel(
        appointmentsSheet, R21Appointment.excelHeaderRow, appointmentsRows);

    appointmentsRows.forEach((ap) {
      if (jAppointments.length != 0) {
        jAppointments.write(',\n');
      }
      jAppointments.write('${ap.toJson(username)}\n');
    });

    final List<R21MedicationRefill> medicationRefils =
        await dbp.retrieveAllMedicationRefillData();
    _writeRowsToExcel(medicationRefilsSheet, R21MedicationRefill.excelHeaderRow,
        medicationRefils);

    medicationRefils.forEach((mf) {
      if (jMedicationRefils.length != 0) {
        jMedicationRefils.write(',\n');
      }
      jMedicationRefils.write('${mf.toJson(username)}\n');
    });

    final List<R21ScreenAnalytic> analyticRows =
        await dbp.retrieveAllAnalyticData();
    _writeRowsToExcel(
        analyticsSheet, R21ScreenAnalytic.excelHeaderRow, analyticRows);

    analyticRows.forEach((an) {
      if (jAnalytics.length != 0) {
        jAnalytics.write(',\n');
      }
      jAnalytics.write('${an.toJson(username)}\n');
    });

    // store changes to file
    excelFile.writeAsBytesSync(decoder.encode());

    String json = "{\n " +
        "\"events\": [${jEvents.toString()}],\n \"analytics\":[${jAnalytics.toString()}],\n" +
        "\"users\":[${jUsers.toString()}],\n \"patients\":[${jParticipants.toString()}],\n" +
        "\"followups\":[${jFollowups.toString()}],\n  \"appointments\":[${jAppointments.toString()}],\n" +
        "\"medicalRefils\":[${jMedicationRefils.toString()}]\n " +
        "}";

    return R21ExportInfo(excelFile, json);
  }
}

/// Interface which makes a class exportable to an excel file.
abstract class IExcelExportable {
  List<dynamic> toExcelRow();
}

abstract class IJsonExportable {
  Map<String, dynamic> toJson(String username);
}
