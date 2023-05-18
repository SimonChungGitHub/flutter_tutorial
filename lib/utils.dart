import 'package:android_id/android_id.dart';

String identifierToHex(var identifier) {
  var hex = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F"
  ];
  String id = "";
  late int i;
  for (var data in identifier) {
    data = data & 0xff;
    i = (data >> 4) & 0x0f;
    id += hex[i];
    i = data & 0x0f;
    id += hex[i];
  }
  return id;
}

Future<String?> getAndroidID() async {
  const androidIdPlugin = AndroidId();
  return await androidIdPlugin.getId();
}
