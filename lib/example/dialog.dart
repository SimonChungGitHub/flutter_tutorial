import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogExample extends StatefulWidget {
  const DialogExample({super.key});

  @override
  State<DialogExample> createState() => _DialogExampleState();
}

class _DialogExampleState extends State<DialogExample> {
  final country = const [
    "基隆",
    "台北",
    "新北",
    "桃園",
    "新竹",
    "苗栗",
    "台中",
    "彰化",
    "南投",
    "雲林",
    "嘉義",
    "台南",
    "高雄",
    "屏東",
    "宜蘭",
    "花蓮",
    "台東",
    "澎湖",
    "金門",
    "馬祖"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'DialogExample',
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          ///地名選單
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: ElevatedButton(
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                child: const Text('地名選單'),
                onPressed: () {
                  _showModalBottomSheet().then((value) => _showSnackBar(value!));
                }),
          ),

          ///提示視窗
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('提示視窗'),
                onPressed: () => _showAlertDialogWithButton()),
          ),

          ///進度條
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('進度條'),
                onPressed: () => _showLoadingDialog()),
          ),

          ///日期選單
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('日期選單_1'),
                onPressed: () => _showDatePicker1()),
          ),

          ///日期選單
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('日期選單_2'),
                onPressed: () => _showDatePicker2()),
          ),

          ///listDialog
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('list dialog'),
                onPressed: () => listDialog()),
          ),

          ///simpleDialog
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('simple dialog'),
                onPressed: () {
                  simpleDialog().then((value) => _showSnackBar(value));
                }),
          ),

          ///alertDialog
          Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('alert dialog'),
                onPressed: () => alertDialog()),
          ),
        ],
      ),
    );
  }

  _showSnackBar(text) {
    final snackBar = SnackBar(
      content: Text(text),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          debugPrint("\u001b[31m snackBar action \u001b[0m");
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  ///地名選單
  Future<String?> _showModalBottomSheet() {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.blue[900],
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: country.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(
                country[index],
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              onTap: () => Navigator.of(context).pop(country[index]),
            );
          },
        );
      },
    );
  }

  ///提示視窗
  Future<bool?> _showAlertDialogWithButton() {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //背景陰影
            elevation: 2,
            backgroundColor: Colors.green[500],
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            title: const Text("提示"),
            content: const Text('檔案即將被刪除'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    _showSnackBar('檔案被刪除');
                    Navigator.of(context).pop(true); //返回值=true
                  },
                  child: Text("確定",
                      style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w500,
                          fontSize: 18))),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showSnackBar('刪除取消');
                  },
                  child: Text("取消",
                      style: TextStyle(
                          color: Colors.blue[900],
                          fontWeight: FontWeight.w500,
                          fontSize: 18)))
            ],
          );
        });
  }

  ///進度條
  _showLoadingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false, //點擊遮罩不關閉對話框
        builder: (context) {
          return const UnconstrainedBox(
            constrainedAxis: Axis.vertical,
            child: SizedBox(
              width: 280,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.only(top: 26.0),
                      child: Text("下載中"),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  ///日期選單_1
  Future<DateTime?> _showDatePicker1() {
    var date = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: date,
      firstDate: date,
      lastDate: date.add(
        const Duration(days: 360),
      ),
    );
  }

  ///日期選單_2
  Future<DateTime?> _showDatePicker2() {
    var date = DateTime.now();
    return showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: 200,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            minimumDate: date,
            maximumDate: date.add(
              const Duration(days: 360),
            ),
            maximumYear: date.year + 1,
            onDateTimeChanged: (DateTime value) {
              debugPrint(value.toString());
            },
          ),
        );
      },
    );
  }

  Future<String?> simpleDialog() {
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            //背景灰色程度
            elevation: 5,
            backgroundColor: Colors.blue,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24.0))),
            title: const Text("Simple Dialog"),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () =>
                    Navigator.of(context).pop('SimpleDialogOption_01'),
                child: const Text('SimpleDialogOption_01'),
              ),
              SimpleDialogOption(
                onPressed: () =>
                    Navigator.of(context).pop('SimpleDialogOption_02'),
                child: const Text('SimpleDialogOption_02'),
              ),
              SimpleDialogOption(
                onPressed: () =>
                    Navigator.of(context).pop('SimpleDialogOption_03'),
                child: const Text('SimpleDialogOption_03'),
              ),
              ListTile(
                  title: const Text('選項一'),
                  onTap: () => Navigator.of(context).pop('選項一')),
              ListTile(
                  title: const Text('選項二'),
                  onTap: () => Navigator.of(context).pop('選項二')),
              ListTile(
                  title: const Text('選項三'),
                  onTap: () => Navigator.of(context).pop('選項三')),
            ],
            // ),
          );
        });
  }

  Future<void> listDialog() async {
    int? index = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        var child = Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const ListTile(title: Text("請選擇")),
            Expanded(
                flex: 50,
                child: ListView.builder(
                  itemCount: 30,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text("$index"),
                      onTap: () => Navigator.of(context).pop(index),
                    );
                  },
                )),
          ],
        );
        //使用AlertDialog会报错
        //return AlertDialog(content: child);
        // return Dialog(shape: const RoundedRectangleBorder(
        // borderRadius: BorderRadius.all(Radius.circular(24.0))),child: child,);
        return UnconstrainedBox(
          constrainedAxis: Axis.vertical,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300, maxHeight: 200),
            child: Material(
              type: MaterialType.card,
              child: child,
            ),
          ),
        );
      },
    );
    if (index != null) {
      _showSnackBar('選擇 $index');
    }
  }

  alertDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            //背景陰影
            elevation: 5,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24.0))),
            title: Text("Shape"),
            content: Text("this is a alert dialog"),
          );
        });
  }
}
