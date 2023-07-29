import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'animation.dart';

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
  String? text;

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
          const Text(
              '对话框本质上是属于一个路由的页面route，由Navigator进行管理，所以控制对话框的显示和隐藏，也是调用Navigator.of(context)的push和pop方法。'),
          const Text(
              '在Flutter中，对话框会有两种风格，调用showDialog()方法展示的是material风格的对话框，调用showCupertinoDialog()方法展示的是ios风格的对话框。而这两个方法其实都会去调用showGeneralDialog()方法，可以从源码中看到最后是利用Navigator.of(context, rootNavigator: true).push()一个页面。'),
          const Text(
              '基本要传的参数:context上下文,builder用于创建显示的widget,barrierDismissible可以控制点击对话框以外的区域是否隐藏对话框。'),
          const Text(
              '你会注意到，showDialog()方法返回的是一个Future对象,可以通过这个future对象来获取对话框所传递的数据。比如我们想知道想知道用户是点击了对话框的确认按钮还是取消按钮,那就在退出对话框的时候，利用Navigator.of(context).pop("一些数据");'),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
            padding: const EdgeInsets.all(10),
            color: Colors.grey,
            child: text == null
                ? const Text('')
                : Text(
                    text!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange[900]),
                  ),
          ),
          Row(
            children: [
              ///地名選單
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900]),
                    child: const Text('地名選單'),
                    onPressed: () {
                      _showModalBottomSheet().then((value) {
                        setState(() {
                          text = value!;
                        });
                      });
                    }),
              ),

              ///提示視窗
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('提示視窗'),
                    onPressed: () => _showAlertDialogWithButton().then((value) {
                          setState(() {
                            value ??= false;
                            if (value!) {
                              text = '刪除檔案';
                            } else {
                              text = '取消刪除檔案';
                            }
                          });
                        })),
              ),

              ///進度條
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('進度條'),
                    onPressed: () => _showLoadingDialog()),
              ),
            ],
          ),
          Row(
            children: [
              ///日期選單
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('日期選單'),
                    onPressed: () {
                      _showDatePicker1().then((value) {
                        setState(() {
                          text = value.toString();
                        });
                      });
                    }),
              ),

              ///時間選單
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('時間選單'),
                    onPressed: () => _showDatePicker2()),
              ),

              ///動畫視窗
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('動畫視窗'),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const AnimationDialog();
                      }));
                    }),
              ),
            ],
          ),

          ///SnackBar
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('SnackBar'),
                onPressed: () => _showSnackBar(text)),
          ),
          Row(
            children: [
              ///listDialog
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('list dialog'),
                    onPressed: () => listDialog()),
              ),

              ///simpleDialog
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('simple dialog'),
                    onPressed: () {
                      simpleDialog().then((value) => _showSnackBar(value));
                    }),
              ),

              ///alertDialog
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('alert dialog'),
                    onPressed: () => alertDialog()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _showSnackBar(text) {
    final snackBar = SnackBar(
      content: text == null ? const Text('text is null') : Text(text),
      action: SnackBarAction(
        label: '提示視窗',
        onPressed: () {
          _showAlertDialogWithButton();
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

  ///提示視窗 (ios style dialog, not work)
  Future<bool?> _showAlertDialogWithButton() {
    return showCupertinoDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //背景陰影
            elevation: 2,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            title: const Text("提示"),
            content: const Text('檔案即將被刪除'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); //返回值=true
                  },
                  child: const Text("確定",
                      style: TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 18))),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("取消",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 18)))
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
      firstDate: date.add(const Duration(days: -360)),
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
          width: MediaQuery.of(context).size.width,
          height: 300,
          child: CupertinoDatePicker(
            backgroundColor: Colors.white,
            mode: CupertinoDatePickerMode.dateAndTime,
            maximumDate: date.add(
              const Duration(days: 360),
            ),
            minimumYear: date.year - 1,
            maximumYear: date.year + 1,
            use24hFormat: true,
            onDateTimeChanged: (DateTime value) {
              setState(() {
                text = value.toString();
              });
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
            elevation: 3,
            backgroundColor: Colors.blue,
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
                  itemCount: country.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                        title: Text(country[index]),
                        onTap: () {
                          Navigator.of(context).pop(index);
                        });
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
      setState(() {
        text = country[index];
      });
    }
  }

  alertDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            //背景陰影
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24.0))),
            title: Text("Shape"),
            content: Text("this is a alert dialog"),
          );
        });
  }
}
