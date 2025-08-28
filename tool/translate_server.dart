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
  if (req.url.path == 'ai/translate' && req.method == 'POST') {
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final target = body['target_lang'] as String? ?? 'xx';
    final items = (body['items'] as List).cast<Map>();

    // Псевдо-перевод: просто помечаем [xx] и оставляем placeholders как есть
    final translations = items.map((e) {
      final key = e['key'] as String;
      final text = e['text'] as String? ?? '';
      return {'key': key, 'text': '[$target] $text'};
    }).toList();

    return _cors(Response.ok(jsonEncode({'translations': translations}),
        headers: {'Content-Type': 'application/json'}));
  }
  return _cors(Response.notFound('Not found'));
}

void main() async {
  final server = await io.serve(handler, '127.0.0.1', 8788);
  print('Translate server on http://${server.address.host}:${server.port}');
}
