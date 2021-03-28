import 'dart:ui';

import 'package:fhir/r4.dart';

import '../../fhir_types/fhir_types_extensions.dart';

extension WoFQuestionnaireAnswerOptionExtensions on QuestionnaireAnswerOption {
  /// Localized access to  display value
  String localizedDisplay(Locale locale) {
    return valueString ?? valueCoding?.localizedDisplay(locale) ?? toString();
  }

  /// The coded value for the option, taken from either valueString or valueCoding
  String get optionCode {
    return valueString ?? valueCoding!.code.toString();
  }
}

extension WoFQuestionnaireItemExtension on QuestionnaireItem {
  bool isItemControl(String itemControl) {
    return extension_
            ?.extensionOrNull(
                'http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl')
            ?.valueCodeableConcept
            ?.containsCoding('http://hl7.org/fhir/questionnaire-item-control',
                itemControl) ??
        false;
  }
}