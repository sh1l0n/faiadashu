import 'dart:convert';

import 'package:faiadashu/questionnaires/view/item/cpg_item_image.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:simple_html_css/simple_html_css.dart';

import '../../../fhir_types/fhir_types_extensions.dart';
import '../../../logging/logging.dart';
import '../../questionnaires.dart';

class QuestionnaireItemFiller extends StatefulWidget {
  static final logger = Logger(QuestionnaireItemFiller);
  final Widget? _titleWidget;
  final QuestionnaireLocation location;
  final QuestionnaireResponseFiller _responseFiller;

  factory QuestionnaireItemFiller.fromQuestionnaireItem(
      QuestionnaireLocation location) {
    return QuestionnaireItemFiller._(
        // TODO: Error handling for failed response filler creation
        location,
        QuestionnaireResponseFiller(location));
  }

  QuestionnaireItemFiller._(this.location, this._responseFiller, {Key? key})
      : _titleWidget = QuestionnaireItemFillerTitle.forLocation(location),
        super(key: key);

  @override
  State<StatefulWidget> createState() => QuestionnaireItemFillerState();
}

class QuestionnaireItemFillerState extends State<QuestionnaireItemFiller> {
  static final logger = Logger(QuestionnaireItemFillerState);

  @override
  Widget build(BuildContext context) {
    logger.debug(
        'build ${widget.location.linkId} hidden: ${widget.location.isHidden}, enabled: ${widget.location.enabled}');

    return (!widget.location.isHidden)
        ? AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: widget.location.enabled
                ? (MediaQuery.of(context).size.width > 1000)
                    ? Table(
                        columnWidths: {
                          0: FixedColumnWidth(
                              MediaQuery.of(context).size.width / 3.2),
                          1: FixedColumnWidth(
                              MediaQuery.of(context).size.width / 3.2 * 2)
                        },
                        children: [
                          TableRow(children: [
                            if (widget._titleWidget != null)
                              Container(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: widget._titleWidget)
                            else
                              Container(),
                            widget._responseFiller
                          ])
                        ],
                      )
                    : ListTile(
                        title: widget._titleWidget,
                        subtitle: widget._responseFiller,
                      )
                : const SizedBox())
        : const SizedBox();
  }
}

class QuestionnaireItemFillerTitle extends StatelessWidget {
  final QuestionnaireLocation location;
  const QuestionnaireItemFillerTitle._(this.location, {Key? key})
      : super(key: key);

  static Widget? forLocation(QuestionnaireLocation location, {Key? key}) {
    if (location.titleText == null) {
      return null;
    } else {
      return QuestionnaireItemFillerTitle._(location, key: key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leading = QuestionnaireItemFillerTitleLeading.forLocation(location);
    final help = _QuestionnaireItemFillerHelpFactory.forLocation(location);

    final requiredTag =
        (location.questionnaireItem.required_?.value == true) ? '*' : '';

    final openStyleTag =
        (location.questionnaireItem.type == QuestionnaireItemType.group)
            ? '<h2>'
            : '<b>';

    final closeStyleTag =
        (location.questionnaireItem.type == QuestionnaireItemType.group)
            ? '</h2>'
            : '$requiredTag</b>';

    final titleText = location.titleText;
    return Container(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              if (leading != null) WidgetSpan(child: leading),
              if (titleText != null)
                HTML.toTextSpan(context,
                    '$openStyleTag${htmlEscape.convert(titleText)}$closeStyleTag',
                    defaultTextStyle: Theme.of(context).textTheme.bodyText1),
              if (help != null) WidgetSpan(child: help),
            ],
          ),
          semanticsLabel: titleText,
        ));
  }
}

class _QuestionnaireItemFillerHelpFactory {
  static Widget? forLocation(QuestionnaireLocation location, {Key? key}) {
    final helpLocation = location.helpLocation;

    if (helpLocation != null) {
      return _QuestionnaireItemFillerHelp(helpLocation, key: key);
    }

    final supportLink = location.questionnaireItem.extension_
        ?.extensionOrNull(
            'http://hl7.org/fhir/StructureDefinition/questionnaire-supportLink')
        ?.valueUri
        ?.value;

    if (supportLink != null) {
      return _QuestionnaireItemFillerSupportLink(supportLink, key: key);
    }

    return null;
  }
}

class _QuestionnaireItemFillerHelp extends StatefulWidget {
  final QuestionnaireLocation ql;

  const _QuestionnaireItemFillerHelp(this.ql, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QuestionnaireItemFillerHelpState();
}

class _QuestionnaireItemFillerHelpState
    extends State<_QuestionnaireItemFillerHelp> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      mouseCursor: SystemMouseCursors.help,
      color: Theme.of(context).accentColor,
      icon: const Icon(Icons.info_outline),
      onPressed: () {
        _showHelp(context, widget.ql);
      },
    );
  }

  Future<void> _showHelp(
      BuildContext context, QuestionnaireLocation questionnaireLocation) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Help'),
            content: HTML.toRichText(
                context, questionnaireLocation.titleText ?? '',
                defaultTextStyle: Theme.of(context).textTheme.bodyText1),
            actions: <Widget>[
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                child: const Text('Dismiss'),
              ),
            ],
          );
        });
  }
}

class _QuestionnaireItemFillerSupportLink extends StatelessWidget {
  static final logger = Logger(_QuestionnaireItemFillerSupportLink);
  final Uri supportLink;

  const _QuestionnaireItemFillerSupportLink(this.supportLink, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      mouseCursor: SystemMouseCursors.help,
      color: Theme.of(context).accentColor,
      icon: const Icon(Icons.info_outline),
      onPressed: () {
        logger.debug("supportLink '${supportLink.toString()}'");
        QuestionnaireFiller.of(context).onLinkTap?.call(context, supportLink);
      },
    );
  }
}

class QuestionnaireItemFillerTitleLeading extends StatelessWidget {
  final Widget _leadingWidget;
//  static final _logger = Logger(QuestionnaireItemFillerTitleLeading);

  const QuestionnaireItemFillerTitleLeading._(Widget leadingWidget, {Key? key})
      : _leadingWidget = leadingWidget,
        super(key: key);

  static Widget? forLocation(QuestionnaireLocation location, {Key? key}) {
    final displayCategory = location.questionnaireItem.extension_
        ?.extensionOrNull(
            'http://hl7.org/fhir/StructureDefinition/questionnaire-displayCategory')
        ?.valueCodeableConcept
        ?.coding
        ?.firstOrNull
        ?.code
        ?.value;

    if (displayCategory != null) {
      final leadingWidget = (displayCategory == 'instructions')
          ? const Icon(Icons.info)
          : (displayCategory == 'security')
              ? const Icon(Icons.lock)
              : const Icon(Icons.help_center_outlined); // Error / unclear

      return QuestionnaireItemFillerTitleLeading._(leadingWidget);
    } else {
      final itemImageWidget = CpgItemImage.forLocation(location, height: 24.0);
      if (itemImageWidget == null) {
        return null;
      }
      return QuestionnaireItemFillerTitleLeading._(itemImageWidget);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _leadingWidget;
  }
}
