import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/view_container.dart';

class AppView extends StatefulWidget {

  final Widget title;
  final Widget? subtitle;
  final Widget? child;
  final Widget? footer;

  const AppView({
    super.key,
    this.title = const Text("Pantalla"),
    this.subtitle,
    this.child,
    this.footer
    });

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {

  Widget _setSubtitle(double height){
    if (widget.subtitle == null) return SizedBox(height: height * 0.02);

    return Column(
      children:[
        SizedBox(height: height * 0.01),
        widget.subtitle!,
        SizedBox(height: height * 0.01),
      ]
    );      
  }


  @override
  Widget build(BuildContext context) {
    
    return LayoutBuilder(
      builder: (builder, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight * 0.82;
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
        Column(
          children: [
            // TITLE
            widget.title,
            // SUBTITLE
            _setSubtitle(height)
          ],          
        ),

        // CHILD
        SizedBox.fromSize(
          size: Size(width, height),
          child: ViewContainer(
          child: widget.child ?? Text("Contenido de la vista")
          )
        ),
        
        // FOOTER
        widget.footer ?? SizedBox(height: 20)
          
      ],
        )
      )
    );
    });
  }
}