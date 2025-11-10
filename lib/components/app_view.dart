import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/styles.dart' as app_styles;

class AppView extends StatefulWidget {

  final String title;
  final String? subtitle;
  final List<Widget>? child;

  const AppView({
    super.key,
    this.title = "Pantalla",
    this.subtitle = "",
    this.child
    });

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  Widget build(BuildContext context) {
    return Center(
    child: Column(
      children: [
        Text(
          widget.title,
          style: app_styles.Styles.titleText
        ),
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
          
        ...(widget.child ?? [])
          
      ],
    )
          );
  }
}