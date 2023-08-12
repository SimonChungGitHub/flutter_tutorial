import 'package:flutter/material.dart';

class AnimationDialog extends StatelessWidget {
  const AnimationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Show Dialog'),
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => const ShowAnimDialog(success: true));
          },
        ),
      ),
    );
  }
}

class ShowAnimDialog extends StatefulWidget {
  const ShowAnimDialog({super.key, required this.success});

  final bool success;

  @override
  ShowAnimDialogState createState() => ShowAnimDialogState();
}

class ShowAnimDialogState extends State<ShowAnimDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _tween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    final animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _tween = Tween<double>(begin: 1.0, end: 0.0).animate(animation);
    _controller
      ..addListener(() {
        setState(() {
          debugPrint('${_tween.value}');
        });
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.translationValues(
          0.0,
          _tween.value *
              (MediaQuery.of(context).size.height / 2 +
                  MediaQuery.of(context).size.width / 2),
          0.0),
      child: Center(
        child: Card(
          child: widget.success ? success() : notSuccess(),
        ),
      ),
    );
  }

  Widget success() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      height: MediaQuery.of(context).size.width / 2,
      width: MediaQuery.of(context).size.width / 2,
      child:
          const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 60.0,
        ),
        Text(
          'Success',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }

  Widget notSuccess() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      height: MediaQuery.of(context).size.width / 2,
      width: MediaQuery.of(context).size.width / 2,
      child:
          const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          Icons.circle_notifications,
          color: Colors.red,
          size: 60.0,
        ),
        Text(
          'Not Success',
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }
}
