import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/styles.dart' as app_styles;

class AppView extends StatefulWidget {

  final String title;
  final String? subtitle;
  final List<Widget>? child;
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
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 4, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
        // TOP
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
                  SizedBox(height: 20),
                  Text(
                    widget.subtitle ?? "",
                    style: app_styles.Styles.text
                  ),
                  SizedBox(height: 20)
                ]
            )          
            : SizedBox(height: 20),
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(15),
              children: widget.child ?? [Text("Contenido de la vista")]
            ),
          ],
        ),

        // CHILD
        

        
        // FOOTER
        widget.footer ?? SizedBox(height: 20)
          
      ],
        )
      )
    );

  }
}