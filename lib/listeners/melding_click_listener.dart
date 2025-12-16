import "package:mapbox_maps_flutter/mapbox_maps_flutter.dart";
import "../models/melding_model.dart";

class MeldingPointClickListener implements OnPointAnnotationClickListener {
  final Map<String, Melding> annotationsMap;
  final void Function(Melding melding) onTap;

  MeldingPointClickListener(this.annotationsMap, this.onTap);

  @override
  bool onPointAnnotationClick(PointAnnotation annotation) {
    final melding = annotationsMap[annotation.id];
    if (melding == null) return false;

    onTap(melding);
    return true;
  }
}
