import 'package:flutter/material.dart';

enum QuestionType { slider, yesNo, singleChoice }
enum LifestyleCategory { biometrics, heart, toxicity, sleep, diabetes, gut, hormonal, immunity }

class ScreeningQuestion {
  final String id;
  final String text;
  final QuestionType type;
  final LifestyleCategory category;
  final double? min;
  final double? max;
  final String? unit;
  final bool isRedFlag;
  final List<String>? options;

  ScreeningQuestion({
    required this.id,
    required this.text,
    required this.type,
    required this.category,
    this.min,
    this.max,
    this.unit,
    this.isRedFlag = false,
    this.options,
  });
}

class HealthPath {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<ScreeningQuestion> specificQuestions;

  HealthPath({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.specificQuestions,
  });
}