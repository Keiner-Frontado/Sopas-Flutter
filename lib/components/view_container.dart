import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/colors.dart' as app_colors;

class ViewContainer extends StatefulWidget {
  
  final List<Widget> child;
  final Color? color;

  const ViewContainer({
    super.key,
    this.child = const [Text("Placeholder View")],
    this.color = app_colors.Colors.surface,
    });


  @override
  State<ViewContainer> createState() => _ViewContainerState();
}

class _ViewContainerState extends State<ViewContainer> {

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: app_colors.Colors.shadow,
              blurRadius: 10,
              spreadRadius: 5,
              offset: Offset(0, 4),
            ),
          ],
        ),
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(5),
        child: ListView(
        padding: EdgeInsets.all(15),
          children: [
            ...widget.child,
          ],
        ),
      )
    );
  }
}