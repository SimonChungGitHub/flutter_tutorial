import 'package:flutter/material.dart';

class ListViewDialog extends Dialog {
  List<String> data;
  double? width;
  Function callback;

  ListViewDialog({
    Key? key,
    required this.data,
    required this.callback,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      type: MaterialType.transparency, //透明类型
      child: Center(
        child: Container(
          width: width ?? 400,
          decoration: const BoxDecoration(
            color: Color(0xff373737),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (BuildContext context, int position) {
                return itemWidget(context, position);
              }),
        ),
      ),
      // ),
    );
  }

  Widget itemWidget(BuildContext context, int index) {
    return TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith(
                (states) {
              if (states.contains(MaterialState.focused) &&
                  !states.contains(MaterialState.pressed)) {
                //获取焦点时的颜色
                return Colors.blue;
              } else if (states.contains(MaterialState.pressed)) {
                //按下时的颜色
                return const Color(0xff4D4D4D);
              }
              //默认状态使用灰色
              return Colors.white;
            },
          ),
          //背景颜色
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            //设置按下时的背景颜色
            if (states.contains(MaterialState.pressed)) {
              return const Color(0xffDCDCDC);
            }
            //默认不使用背景颜色
            return null;
          }),
          //设置水波纹颜色
          overlayColor: MaterialStateProperty.all(const Color(0xff777777)),
          elevation: MaterialStateProperty.all(0),
          shape: MaterialStateProperty.all(
              const RoundedRectangleBorder()),
        ),
        onPressed: () {
          callback(index);
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
            child: Text(data[index],
            ),
          ),
        ));
  }
}