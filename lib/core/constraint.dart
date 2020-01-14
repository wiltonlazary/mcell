import '../core/mcell.dart';

typedef ModelMessage ConstraintMessaging(ModelCell cell, dynamic value, String label);

final minLengthConstraint = (int length, {String name = "minLength", String label, ConstraintMessaging messaging}) => ModelConstraint(
    name: name,
    validate: (cell, snapshot) {
      return snapshot.value.toString().length >= length;
    },
    messaging: (cell, snapshot) {
      return messaging != null
          ? messaging(cell, snapshot, label)
          : ModelMessage(
              "mínimo ($length) caracter${length <= 1 ? "" : "es"}.",
              "${label ?? cell.label} deve ter no mínimo ($length) caracter${length <= 1 ? "" : "es"}.",
            );
    });

final maxLengthConstraint = (int length, {String name = "maxLength", String label, ConstraintMessaging messaging}) => ModelConstraint(
    name: name,
    validate: (cell, snapshot) {
      return snapshot.value.toString().length <= length;
    },
    messaging: (cell, snapshot) {
      return messaging != null
          ? messaging(cell, snapshot.value, label)
          : ModelMessage(
              "máximo ($length) caracter${length <= 1 ? "" : "es"}.",
              "${label ?? cell.label} deve ter no máximo ($length) caracter${length <= 1 ? "" : "es"}.",
            );
    });

final minValueConstraint = (num minValue, {String name = "minValue", String label, ConstraintMessaging messaging}) => ModelConstraint(
    name: name,
    validate: (cell, snapshot) {
      return snapshot.value as num >= minValue;
    },
    messaging: (cell, snapshot) {
      return messaging != null
          ? messaging(cell, snapshot, label)
          : ModelMessage(
              "valor mínimo ($minValue).",
              "${label ?? cell.label} deve ser no mínimo ($minValue).",
            );
    });

final maxValueConstraint = (num maxValue, {String name = "maxValue", String label, ConstraintMessaging messaging}) => ModelConstraint(
    name: name,
    validate: (cell, snapshot) {
      return snapshot.value as num <= maxValue;
    },
    messaging: (cell, snapshot) {
      return messaging != null
          ? messaging(cell, snapshot.value, label)
          : ModelMessage(
              "valor máximo ($maxValue).",
              "${label ?? cell.label} deve ser no máximo ($maxValue).",
            );
    });

final emailConstraint = ({String name = "email", String label = "Email", ConstraintMessaging messaging}) => ModelConstraint(
    name: "email",
    validate: (cell, snapshot) {
      final parts = snapshot.value.split("@");
      return parts.length == 2 && parts[0].length >= 1 && parts[1].length >= 3 && parts[1].contains(".");
    },
    messaging: (cell, snapshot) {
      return messaging != null
          ? messaging(cell, snapshot.value, label)
          : ModelMessage(
              "email fora do padrão.",
              "${label ?? cell.label} está fora do padrão.",
            );
    });
