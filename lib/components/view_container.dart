import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/colors.dart' as app_colors;

class ViewContainer extends StatefulWidget {
  
  final Widget child;
  final Color? color;

  const ViewContainer({
    super.key,
    this.child = const Text("Placeholder View"),
    this.color = app_colors.Colors.surface,
    });


  @override
  State<ViewContainer> createState() => _ViewContainerState();
}

class _ViewContainerState extends State<ViewContainer> {

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(builder: (builder, constraints) {
      final width = constraints.maxWidth * 0.95;  // 60% del ancho del padre
      final height = constraints.maxHeight * 0.95;
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
        width: width,
        height: height,
        padding: const EdgeInsets.all(5),
        child: widget.child,
        ),
      ); 
    });
    
  }
}