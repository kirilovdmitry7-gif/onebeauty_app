import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

Response _cors(Response r) => r.change(headers: {
      ...r.headers,
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
    });

Future<Response> handler(Request req) async {
  if (req.method == 'OPTIONS') return _cors(Response.ok(''));
  if (req.url.path == 'ai/advice' && req.method == 'POST') {
    final j = jsonDecode(await req.readAsString());
    final done = j['today']?['done'] ?? 0;
    final total = j['today']?['total'] ?? 0;
    final streak = j['streak'] ?? 0;

    final tip = (total == 0)
        ? 'No tasks today — add 1–2 tiny items to keep momentum.'
        : (done == total)
            ? 'Perfect day! Keep the streak with light stretching before sleep.'
            : (done / (total == 0 ? 1 : total) >= 0.6)
                ? 'Almost there — a 10–15 min walk will close steps.'
                : 'Start small: a glass of water now and 5-min stretch later.';

    final resp = {
      'advice_today': tip,
      'tomorrow_plan': [
        'Water 3× 250ml before 4pm',
        'Stretch 7 min after dinner'
      ],
      'weekly_summary': streak > 0
          ? 'Streak already $streak day(s).'
          : 'Let’s build your first streak.',
      'nudges': [
        {
          'at': '21:15',
          'message': 'Get ready to sleep — tomorrow will be easier.'
        }
      ],
      'advice_tone': 'warm'
    };
    return _cors(Response.ok(jsonEncode(resp),
        headers: {'Content-Type': 'application/json'}));
  }
  return _cors(Response.notFound('Not found'));
}

void main() async {
  final server = await io.serve(handler, '127.0.0.1', 8787);
  print('Advice server on http://${server.address.host}:${server.port}');
}
