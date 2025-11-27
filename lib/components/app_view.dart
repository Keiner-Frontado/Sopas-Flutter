import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/view_container.dart';
import 'package:flutter_application_1/core/styles.dart' as app_styles;

class AppView extends StatefulWidget {

  final String title;
  final String? subtitle;
  final Widget? child;
  final Widget? footer;

  const AppView({
    super.key,
    this.title = "Pantalla",
    this.subtitle = "",
    this.child,
    this.footer
    });

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
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
            Text(
              widget.title,
              style: app_styles.Styles.titleText
            ),
            // SUBTITLE
            (widget.subtitle != "")
            ? Column(
              children:
                [
                  SizedBox(height: height * 0.01),
                  Text(
                    widget.subtitle ?? "",
                    style: app_styles.Styles.text
                  ),
                  SizedBox(height: height * 0.01),
                ]
            )          
            : SizedBox(height: height * 0.02),
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