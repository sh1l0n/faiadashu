import 'dart:convert';

import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';
import 'package:widgets_on_fhir/questionnaires/questionnaires.dart';

class QuestionnaireStepperPage extends StatefulWidget {
  late final QuestionnaireLocation top;
  late final Iterable<QuestionnaireLocation> locations;

  QuestionnaireStepperPage(String instrument, {Key? key}) : super(key: key) {
    top = QuestionnaireLocation(Questionnaire.fromJson(
        json.decode(instrument) as Map<String, dynamic>));

    locations = top.preOrder();
  }

  @override
  State<StatefulWidget> createState() => _QuestionnaireStepperState();
}

class _QuestionnaireStepperState extends State<QuestionnaireStepperPage> {
  static const QuestionnaireItemDecorator _decorator =
      DefaultQuestionnaireItemDecorator();

  int step = 0;

  @override
  Widget build(BuildContext context) {
    final controller = PageController();
    return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.locations.elementAt(0).questionnaire.title ?? 'Untitled'),
        ),
        body: Column(children: [
          Expanded(
            child: PageView(
              /// [PageView.scrollDirection] defaults to [Axis.horizontal].
              /// Use [Axis.vertical] to scroll vertically.
              controller: controller,
              children: widget.locations
                  .map<Widget>((location) =>
                      QuestionnaireItemWidgetFactory.fromQuestionnaireItem(
                          location, _decorator))
                  .toList(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => controller.previousPage(
                    curve: Curves.easeIn,
                    duration: const Duration(milliseconds: 250)),
              ),
              ValueListenableBuilder<Decimal?>(
                builder: (BuildContext context, Decimal? value, Widget? child) {
                  return Text(
                    'Score: ${value!.value!.round().toString()}',
                    style: Theme.of(context).textTheme.headline4,
                  );
                },
                valueListenable: widget.top.totalScoreNotifier!,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => controller.nextPage(
                    curve: Curves.easeIn,
                    duration: const Duration(milliseconds: 250)),
              ),
            ],
          ),
        ]));
  }
}