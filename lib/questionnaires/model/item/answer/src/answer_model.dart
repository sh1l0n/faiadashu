import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';

import '../../../../../fhir_types/fhir_types.dart';
import '../../../model.dart';

/// Models an answer within a [QuestionnaireResponseItem].
abstract class AnswerModel<I, V> {
  /// Textual depiction of an unanswered question.
  static const nullText = '—';

  final QuestionItemModel responseItemModel;
  final int answerIndex;
  V? value;

  QuestionnaireItemModel get questionnaireItemModel =>
      responseItemModel.questionnaireItemModel;

  QuestionnaireResponseModel get questionnaireResponseModel =>
      responseItemModel.questionnaireResponseModel;

  Locale get locale => questionnaireResponseModel.locale;

  QuestionnaireItem get qi => questionnaireItemModel.questionnaireItem;

  bool get isEnabled =>
      !questionnaireItemModel.isReadOnly &&
      !(questionnaireResponseModel.responseStatus ==
          QuestionnaireResponseStatus.completed);

  /// Returns the human-readable entry format.
  ///
  /// See: http://hl7.org/fhir/R4/extension-entryformat.html
  String? get entryFormat {
    return qi.extension_
        ?.extensionOrNull('http://hl7.org/fhir/StructureDefinition/entryFormat')
        ?.valueString;
  }

  AnswerModel(this.responseItemModel, this.answerIndex);

  /// Returns a human-readable, localized, textual description of the model.
  ///
  /// Returns [nullText] if the question is unanswered.
  String get display;

  QuestionnaireResponseAnswer? get answer =>
      responseItemModel.responseItem?.answer?.elementAt(answerIndex);

  /// Validates a new input value. Does not change the [value].
  ///
  /// Returns null when [inputValue] is valid, or a localized message when it is not.
  ///
  /// This is used to validate external input from a view.
  ///
  String? validateInput(I? inputValue);

  /// Returns whether the answer will pass the completeness check.
  ///
  /// Completeness means that the validity criteria are met,
  /// in order to submit a [QuestionnaireResponse] as complete.
  ///
  /// Since an individual answer does not know whether it is required, this
  /// is not taken into account.
  ///
  /// Returns null when the answer is valid, or a [QuestionnaireErrorFlag],
  /// when it is not.
  QuestionnaireErrorFlag? get isComplete;

  /// Returns whether this question is unanswered.
  bool get isUnanswered;

  String? get errorText {
    return questionnaireResponseModel
        .errorFlagForResponseUid(questionnaireItemModel.linkId)
        ?.errorText;
  }

  /// Returns a [QuestionnaireResponseAnswer] based on the current value.
  ///
  /// This is the link between the presentation model and the underlying
  /// FHIR domain model.
  QuestionnaireResponseAnswer? get filledAnswer;

  List<QuestionnaireResponseAnswer>? get filledCodingAnswers {
    throw UnimplementedError('filledCodingAnswers not implemented.');
  }

  bool get hasCodingAnswers => false;

  /// Populates the answer from the result of a FHIRPath expression.
  ///
  /// This function is designed for a very specific internal purpose and should
  /// not be invoked by application code.
  void populateFromExpression(dynamic evaluationResult) {
    throw UnimplementedError('populateFromExpression not implemented.');
  }
}
