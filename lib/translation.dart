import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AppTranslation extends Translations {
  static Map<String, Map<String, String>> _translations = {};

  static Future<void> init() async {
    _translations['en_US'] = Map<String, String>.from(
        json.decode(await rootBundle.loadString('assets/english.json')));
    _translations['hi_IN'] = Map<String, String>.from(
        json.decode(await rootBundle.loadString('assets/hindi.json')));
  }

  @override
  Map<String, Map<String, String>> get keys => _translations;
}
