import "dart:convert";
import "dart:developer";

import "package:flutter/material.dart";
import "package:gap/gap.dart";
import "package:http/http.dart";
import "package:intl/intl.dart";
import "package:jbl_pills_reminder_app/src/api/apis.dart";
import "package:jbl_pills_reminder_app/src/screens/add_reminder/model/reminder_model.dart";
import "package:jbl_pills_reminder_app/src/widgets/medication_card.dart";

class HistoryPage extends StatefulWidget {
  final String phone;
  const HistoryPage({super.key, required this.phone});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My History"),
      ),
      body: FutureBuilder(
        future: get(Uri.parse("${baseAPI}history/${widget.phone}")),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasData) {
              final response = snapshot.data!;
              if (response.statusCode == 200) {
                List decoded = jsonDecode(response.body);
                Map<DateTime, ReminderModel> data = arrangeAndSortData(decoded);
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${index + 1}.",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const Gap(10),
                            Text(
                              "${TimeOfDay(hour: data.keys.elementAt(index).hour, minute: data.keys.elementAt(index).minute).format(context)},",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(5),
                            Text(
                              DateFormat.yMMMMEEEEd().format(
                                data.keys.elementAt(index),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Gap(5),
                        cardOfReminderForSummary(
                            data.values.elementAt(index), context),
                        const Gap(15),
                      ],
                    );
                  },
                );
              } else {
                log(response.statusCode.toString());
                return const Text("Unable to load: 404");
              }
            } else {
              return const Center(
                child: Text("Unable to load"),
              );
            }
          }
        },
      ),
    );
  }

  Map<DateTime, ReminderModel> arrangeAndSortData(List rawData) {
    Map<DateTime, ReminderModel> sortedData = {};

    for (int i = 0; i < rawData.length; i++) {
      String date = rawData[i]["created_at"];
      DateTime dateTime = DateTime.parse(date);
      Map<String, dynamic> data = Map<String, dynamic>.from(rawData[i]["data"]);
      sortedData.addAll({dateTime: ReminderModel.fromMap(data)});
    }
    return sortedData;
  }
}
