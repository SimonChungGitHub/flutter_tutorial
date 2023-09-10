import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../utils.dart';

class ViewVideo extends StatefulWidget {
  // final String heroTitle;
  final int videoIndex;
  final List<dynamic> videoList;

  const ViewVideo({
    super.key,
    this.videoIndex = 0,
    required this.videoList,
  });

  @override
  ViewVideoState createState() => ViewVideoState();
}

class ViewVideoState extends State<ViewVideo> {
  late int currentIndex;
  late List<dynamic> videoList;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.videoIndex;
    videoList = widget.videoList;
    _controller = VideoPlayerController.file(File(videoList[currentIndex]))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              onPressed: () async => deleteImage(),
              icon: const Icon(Icons.delete),
              color: Colors.white,
              iconSize: 25,
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              onPressed: () async => uploadVideo(),
              icon: const Icon(Icons.upload),
              color: Colors.white,
              iconSize: 25,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        centerTitle: true,
        leading: Container(),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          VideoPlayer(_controller),
                          VideoProgressIndicator(_controller,
                              allowScrubbing: true),
                        ],
                      ),
                    ),
                  ),
                  _videoPlayerControlRowWidget(),
                ],
              )
            : Container(),
      ),
    );
  }

  Widget _videoPlayerControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: _controller.value.isPlaying
              ? const Icon(Icons.pause_circle)
              : const Icon(Icons.play_circle_fill_outlined),
          color: Colors.blue,
          iconSize: 50,
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
        ),
      ],
    );
  }

  Future<void> deleteImage() async {
    bool? result =
        await showAlertDialogWithButton(context, Icons.delete, '此部影片將被刪除');
    if (result!) {
      File file = File(videoList[currentIndex]);
      file.deleteSync(); //todo 移到tmp
      setState(() => Navigator.of(context).pop(videoList));
    }
  }

  Future<void> uploadVideo() async {
    debugPrint(
        '\u001b[31m ===== upload... ${videoList[currentIndex]} =====\u001b[0m');
    File file = File(videoList[currentIndex]);
    var result = await dioUpload(context, file);
    debugPrint('$result =====================================================');
    if (result) {
      file.deleteSync(); //todo 移到tmp
      setState(() => Navigator.of(context).pop(videoList));
    }
  }
}
