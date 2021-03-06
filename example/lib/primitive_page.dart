import 'package:fhir/primitive_types/fhir_date_time.dart';
import 'package:flutter/material.dart';
import 'package:widgets_on_fhir/primitive_types/date_time_widget.dart';
import 'package:widgets_on_fhir_example/exhibit_page.dart';

class PrimitivePage extends ExhibitPage {
  const PrimitivePage({Key? key}) : super(key: key);

  @override
  Widget buildExhibit(BuildContext context) {
    return Column(children: [
      FhirDateTimeWidget(FhirDateTime('2002-02-05')),
      FhirDateTimeWidget(FhirDateTime('2010-02-05 14:02')),
      FhirDateTimeWidget(FhirDateTime('2010-02')),
    ]);
  }

  @override
  String get title => 'Primitives';
}