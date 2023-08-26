import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils.dart';

class PickImages extends StatefulWidget {
  final List<String> imageList;
  final int index;
  final int crossAxisCount;

  const PickImages(
      {super.key,
      required this.imageList,
      required this.crossAxisCount,
      this.index = -1});

  static const MethodChannel _channel = MethodChannel('gallery_view');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  @override
  State<PickImages> createState() => _PickImagesState();
}

class _PickImagesState extends State<PickImages> {
  List<PickImage> _pickList = [];
  bool _pickAll = false;

  @override
  void initState() {
    super.initState();
    for (var path in widget.imageList) {
      if (path == widget.imageList[widget.index]) {
        _pickList.add(PickImage(path, true));
      } else {
        _pickList.add(PickImage(path, false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          '照片選取',
        ),
        actions: [
          IconButton(
            tooltip: '選照片',
            icon: const Icon(
              Icons.task_alt,
            ),
            onPressed: () {
              setState(() {
                if (!_pickAll) {
                  for (var obj in _pickList) {
                    obj.select = true;
                  }
                  _pickAll = true;
                } else {
                  for (var obj in _pickList) {
                    obj.select = false;
                  }
                  _pickAll = false;
                }
              });
            },
          ),
          IconButton(
            tooltip: '上傳',
            icon: const Icon(
              Icons.upload,
            ),
            onPressed: () async {
              List<PickImage> list = [];
              for (var obj in _pickList) {
                if (obj.select) {
                  var file = File(obj.path);
                  var result = await dioUpload(context, file);
                  if (result) {
                    file.deleteSync();
                  } else {
                    list.add(obj);
                  }
                } else {
                  list.add(obj);
                }
              }

              widget.imageList.clear();
              for (var obj in list) {
                widget.imageList.add(obj.path);
              }
              setState(() => Navigator.of(context).pop());
            },
          ),
          IconButton(
            tooltip: '刪除',
            icon: const Icon(
              Icons.delete,
            ),
            onPressed: () async {
              bool? result = await showAlertDialogWithButton(context, Icons.delete, '選取的照片將被刪除');
              setState(() {
                List<PickImage> list = [];
                for (var obj in _pickList) {
                  if (obj.select) {
                    debugPrint('\u001b[31m delete ${obj.path} \u001b[0m');
                    File(obj.path).deleteSync();
                  } else {
                    list.add(obj);
                  }
                }
                widget.imageList.clear();
                for (var obj in list) {
                  widget.imageList.add(obj.path);
                }
                Navigator.of(context).pop();
              });
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade300,
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: GridView.builder(
            itemCount: _pickList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0),
            itemBuilder: (BuildContext context, int index) {
              return _pickList[index].select ? pick(index) : notPick(index);
            }),
      ),
    );
  }

  Widget notPick(index) {
    return Stack(alignment: AlignmentDirectional.topStart, children: [
      SizedBox(
        width: 200,
        height: 200,
        child: InkWell(
          radius: 10,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          highlightColor: Colors.orange,
          onTap: () {
            setState(() {
              _pickList[index].select = !_pickList[index].select;
              _pickAll = false;
            });
          },
          child: ClipRRect(
            ///是 ClipRRect，不是 ClipRect
            borderRadius: BorderRadius.circular(5),
            child: Image.file(
              File(_pickList[index].path),
              fit: BoxFit.fill,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      ),
      Positioned(
        top: -10,
        left: -10,
        child: IconButton(
          icon: const Icon(Icons.lens_outlined),
          onPressed: () {
            setState(() {
              _pickList[index].select = !_pickList[index].select;
            });
          },
        ),
      )
    ]);
  }

  Widget pick(index) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Stack(alignment: AlignmentDirectional.topStart, children: [
        SizedBox(
          width: 200,
          height: 200,
          child: InkWell(
            radius: 10,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            highlightColor: Colors.orange,
            onTap: () {
              setState(() {
                _pickList[index].select = !_pickList[index].select;
              });
            },
            child: ClipRRect(
              ///是 ClipRRect，不是 ClipRect
              borderRadius: BorderRadius.circular(5),
              child: Image.file(
                File(_pickList[index].path),
                fit: BoxFit.fill,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: -10,
          left: -10,
          child: IconButton(
            color: Colors.green,
            icon: const Icon(Icons.task_alt_outlined),
            onPressed: () {
              setState(() {
                _pickList[index].select = !_pickList[index].select;
              });
            },
          ),
        ),
      ]),
    );
  }
}

class PickImage {
  late String path;
  bool select = false;

  PickImage(this.path, this.select);
}
