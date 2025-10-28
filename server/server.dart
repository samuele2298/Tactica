import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:redis/redis.dart';
import 'dart:math';

/// ===========================================================
/// SIMPLE SESSION SERVER
/// Endpoints:
/// - POST /createSession
/// - GET /fetchSession?code=
/// - POST /joinSession
/// - POST /sendResults
///
/// Data is stored in Redis.
/// No authentication, just fast JSON API.
/// ===========================================================

Future<void> main() async {
  final redis = RedisConnection();
  final conn = await redis.connect('127.0.0.1', 6379);
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('✅ Server started on port 8080');

  // Controllo ogni 30 secondi se sessione è chiusa
  Timer.periodic(Duration(seconds: 30), (_) async { 
    try { 
      print('🔍 Checking active sessions...');
      // Recupera tutte le sessioni
      final keys = await conn.send_object(['KEYS', 'session:*']);
      if (keys == null || keys.isEmpty) return;
      for (var key in keys) {
        final sessionJson = await conn.send_object(['GET', key]);
        if (sessionJson == null) continue;
        final session = jsonDecode(sessionJson);
        if (session['status'] == 'open') {
          final now = DateTime.now().millisecondsSinceEpoch;
          final elapsedMinutes = (now - session['createdAt']) / 60000;
          final maxTime = session['maxTime'];
          if (elapsedMinutes >= maxTime) {
            session['status'] = 'closed';
            await conn.send_object(['SET', key, jsonEncode(session)]);
            print('✅ Closed session ${session['code']} due to timeout.');
          }
        }
      }
    } catch (e) {
      print('❌ Error checking sessions: $e');
    }
  });

  await for (final req in server) {
    req.response.headers.contentType = ContentType.json;

    try {
      // ============== CREATE SESSION ==========================
      if (req.uri.path == '/createSession' && req.method == 'POST') {
        final body = await utf8.decoder.bind(req).join();
        final data = body.isNotEmpty ? jsonDecode(body) : {};

        final code = _randomCode(6);
        final session = {
          'code': code,
          'game': data['game'] ?? 1,
          'maxTime': data['maxTime'] ?? 10, // in minutes
          'numTurns': data['numTurns'] ?? 5,
          'strategy': data['strategy'] ?? 1,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'participants': [],
          'results': [],
          'status': 'open'
        };

        await conn.send_object(['SET', 'session:$code', jsonEncode(session)]);

        final url = 'http://${req.connectionInfo?.remoteAddress.host}:8080/fetchSession?code=$code';
        _ok(req, {'status': 'ok', 'code': code, 'url': url});
      }

      // ============== FETCH SESSION ===========================
      else if (req.uri.path == '/fetchSession' && req.method == 'GET') {
        final code = req.uri.queryParameters['code'];
        if (code == null) return _bad(req, 'Missing code');

        final sessionJson = await conn.send_object(['GET', 'session:$code']);
        if (sessionJson == null) return _bad(req, 'Session not found');

        final session = jsonDecode(sessionJson);

        // check if session should close
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsedMinutes = (now - session['createdAt']) / 60000;
        final maxTime = session['maxTime'];

        if (session['status'] == 'open') {
          final participants = (session['participants'] as List).length;
          final results = (session['results'] as List).length;

          // If all participants sent results OR time expired (>= maxTime)
          if ((participants > 0 && results >= participants) || elapsedMinutes >= maxTime) {
            session['status'] = 'closed';
            await conn.send_object(['SET', 'session:$code', jsonEncode(session)]);
          }
        }

        _ok(req, session);
      }

      // ============== JOIN SESSION ============================
      else if (req.uri.path == '/joinSession' && req.method == 'POST') {
        final body = await utf8.decoder.bind(req).join();
        final data = jsonDecode(body);
        final code = data['code'];
        if (code == null) return _bad(req, 'Missing code');

        final sessionJson = await conn.send_object(['GET', 'session:$code']);
        if (sessionJson == null) return _bad(req, 'Session not found');
        final session = jsonDecode(sessionJson);

        if (session['status'] != 'open') return _bad(req, 'Session closed');

        final userId = data['user'] ?? _randomCode(4);
        final participants = List<String>.from(session['participants']);
        if (!participants.contains(userId)) {
          participants.add(userId);
          session['participants'] = participants;
          await conn.send_object(['SET', 'session:$code', jsonEncode(session)]);
        }

        _ok(req, {'joined': true, 'user': userId, 'settings': session});
      }

      // ============== SEND RESULTS ============================
      else if (req.uri.path == '/sendResults' && req.method == 'POST') {
        final body = await utf8.decoder.bind(req).join();
        final data = jsonDecode(body);
        final code = data['code'];
        if (code == null) return _bad(req, 'Missing code');

        final sessionJson = await conn.send_object(['GET', 'session:$code']);
        if (sessionJson == null) return _bad(req, 'Session not found');
        final session = jsonDecode(sessionJson);

        if (session['status'] == 'closed') return _bad(req, 'Session closed');

        final results = List<Map<String, dynamic>>.from(session['results']);
        results.add(data['results']);
        session['results'] = results;
        await conn.send_object(['SET', 'session:$code', jsonEncode(session)]);

        _ok(req, {'status': 'result stored', 'count': results.length});
      }

      // ============== UNKNOWN PATH ============================
      else {
        req.response
          ..statusCode = 404
          ..write(jsonEncode({'error': 'Not Found'}));
      }
    } catch (e) {
      _bad(req, e.toString());
    } finally {
      await req.response.close();
    }
  }
}

/// =============== HELPERS ====================================

String _randomCode(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random();
  return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
}

void _ok(HttpRequest req, Map<String, dynamic> body) {
  req.response
    ..statusCode = 200
    ..write(jsonEncode(body));
}

void _bad(HttpRequest req, String msg) {
  req.response
    ..statusCode = 400
    ..write(jsonEncode({'error': msg}));
}
