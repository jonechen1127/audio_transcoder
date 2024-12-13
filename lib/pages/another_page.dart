import 'package:flutter/material.dart';

class AnotherPage extends StatelessWidget {
  const AnotherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Another Page')),
      body: const RightClickMenuExample(),
    );
  }
}

class RightClickMenuExample extends StatefulWidget {
  const RightClickMenuExample({super.key});

  @override
  _RightClickMenuExampleState createState() => _RightClickMenuExampleState();
}

class _RightClickMenuExampleState extends State<RightClickMenuExample> {
  void _showPopupMenu(Offset offset) async {
    final double left = offset.dx;
    final double top = offset.dy;

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, left, top),
      items: <PopupMenuItem<int>>[
        const PopupMenuItem<int>(
          value: 1,
          child: Text('Option 1'),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Text('Option 2'),
        ),
      ],
      elevation: 8.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapUp: (TapUpDetails details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset offset = renderBox.globalToLocal(details.globalPosition);
        _showPopupMenu(offset);
      },
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          color: Colors.blue,
          child: const Center(
            child: Text('Right-click me!'),
          ),
        ),
      ),
    );
  }
}
