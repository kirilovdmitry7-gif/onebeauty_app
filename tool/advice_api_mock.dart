import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

const _cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
  'Content-Type': 'application/json',
};

Middleware _corsMw() => (inner) => (Request req) async {
      if (req.method == 'OPTIONS') {
        return Response.ok('', headers: _cors);
      }
      final res = await inner(req);
      return res.change(headers: {...res.headers, ..._cors});
    };

Future<Response> _handler(Request req) async {
  final path = '/${req.url.path}';

  // --- health check ---
  if (req.method == 'GET' && path == '/ping') {
    return Response.ok('ok', headers: {'Access-Control-Allow-Origin': '*'});
  }

  // --- AI advice (как было) ---
  if (req.method == 'POST' && path == '/ai/advice') {
    final bodyRaw = await req.readAsString();
    Map<String, dynamic> body = {};
    try {
      body = (jsonDecode(bodyRaw) as Map).cast<String, dynamic>();
    } catch (_) {}

    final today = (body['today'] as Map?) ?? const {'done': 0, 'total': 0};
    final done = (today['done'] as int?) ?? 0;
    final total = (today['total'] as int?) ?? 0;
    final streak = (body['streak'] as int?) ?? 0;

    final resp = {
      'advice_today': (total > 0 && done == total)
          ? 'Perfect day! Keep the streak with light stretching before sleep.'
          : 'Start small: a glass of water now and a 5-min stretch after breakfast.',
      'tomorrow_plan': [
        'Water 3× 250ml before 4pm',
        'Stretch 7 min after dinner',
      ],
      'weekly_summary': streak > 0
          ? 'Nice run — let’s extend the streak this week.'
          : 'Let’s build your first streak.',
      'nudges': [
        {'at': '10:30', 'message': 'Stand up and drink a glass of water.'},
        {'at': '21:15', 'message': 'Prepare for sleep — slow down screens.'},
      ],
      'advice_tone': 'warm',
    };
    return Response.ok(jsonEncode(resp), headers: _cors);
  }

  // --- NEW: Replace title with similar ---
  if (req.method == 'POST' && path == '/ai/replace-title') {
    try {
      final j =
          (jsonDecode(await req.readAsString()) as Map).cast<String, dynamic>();
      final seed = (j['seed'] as String?)?.trim() ?? '';
      final category =
          (j['category'] as String?)?.trim().toLowerCase() ?? 'misc';
      final level = (j['level'] is num) ? (j['level'] as num).toInt() : 1;

      // Простой словарик (мок). В проде здесь будет ИИ.
      final pool = <String, List<String>>{
        'water': [
          'Sip a glass now',
          'Lemon water break',
          '250ml after each call',
          'Keep bottle on desk',
        ],
        'activity': [
          '7-min stretch',
          'Walk 10 min',
          'Desk posture check',
          'Stand up & move',
        ],
        'sleep': [
          'Screens off 30 min earlier',
          'Herbal tea wind-down',
          'Brush & lights out 23:00',
          'Set soft alarm',
        ],
        'mind': [
          '2-min breathing',
          'Gratitude note',
          'Short body scan',
          'Micro-meditation',
        ],
        'misc': [
          'Tiny improvement today',
          'One easy win',
          'Tidy up 3 items',
          'Inbox to zero (5m)',
        ],
      };

      // Можно слегка учитывать level (для примера просто переставим порядок)
      final list = List<String>.from(pool[category] ?? pool['misc']!);
      if (level == 2) {
        list
          ..add('Add a medium challenge')
          ..shuffle();
      } else if (level >= 3) {
        list
          ..add('Try a harder variant')
          ..shuffle();
      } else {
        list.shuffle();
      }

      // Выбрать не совпадающее с seed (по возможности)
      String pick = list.first;
      for (final s in list) {
        if (s.toLowerCase().trim() != seed.toLowerCase().trim()) {
          pick = s;
          break;
        }
      }

      final resp = jsonEncode({'title': pick});
      return Response.ok(resp, headers: _cors);
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'replace-title fail', 'details': '$e'}),
        headers: _cors,
      );
    }
  }

  return Response.notFound(jsonEncode({'error': 'Not found'}), headers: _cors);
}

void main(List<String> args) async {
  final port = int.tryParse(
        (args.isNotEmpty ? args.first : Platform.environment['PORT'] ?? '8787'),
      ) ??
      8787;

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMw())
      .addHandler(_handler);

  final server = await serve(handler, InternetAddress.loopbackIPv4, port);
  print(
      'Advice API mock listening on http://${server.address.address}:${server.port}');
}
