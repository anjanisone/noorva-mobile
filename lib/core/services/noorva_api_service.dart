import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/guide/data/guide_plan_models.dart';
import '../constants/noorva_api_config.dart';
import 'noorva_guide_session.dart';

class NoorvaApiException implements Exception {
  NoorvaApiException(this.message, {this.serverDown = false});
  final String message;
  final bool serverDown;
  @override
  String toString() => message;
}

class NoorvaChatResult {
  NoorvaChatResult({
    required this.message,
    this.sessionId,
    this.handoffJobId,
    this.expression,
  });
  final String message;
  final String? sessionId;
  final String? handoffJobId;
  final String? expression;
}

class NoorvaPlanProgressStep {
  NoorvaPlanProgressStep({required this.label, required this.state});
  final String label;
  final String state;
}

class NoorvaPlanJob {
  NoorvaPlanJob({
    required this.status,
    this.error,
    this.progressLabel,
    this.progressSteps = const [],
    this.planTitle,
    this.planBody,
    this.researchSummary,
    this.planDocument,
  });
  final String status;
  final String? error;
  final String? progressLabel;
  final List<NoorvaPlanProgressStep> progressSteps;
  final String? planTitle;
  final String? planBody;
  final String? researchSummary;
  final GuidePlanDocument? planDocument;
}

class NoorvaApiService {
  NoorvaApiService() : _dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 120),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ));

  final Dio _dio;

  String get _tz {
    try {
      return DateTime.now().timeZoneName;
    } catch (_) {
      return 'America/New_York';
    }
  }

  Future<Map<String, dynamic>> _bodyExtras() async {
    final userId = await NoorvaGuideSession.instance.userId();
    return {'userId': userId, 'timezone': _tz};
  }

  Future<void> wipeUserData(String userId) async {
    try {
      await _dio.post(
        '${NoorvaApiConfig.v1}/auth/wipe-data',
        data: {'userId': userId, 'timezone': _tz},
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  /// Server wipe for current user + new local `mobile-…` id.
  Future<String> resetAppFromScratch() async {
    final oldId = await NoorvaGuideSession.instance.userId();
    try {
      await wipeUserData(oldId);
    } on NoorvaApiException {
      /* still rotate local id if server unreachable */
    }
    return NoorvaGuideSession.instance.clearLocalIdentity();
  }

  Future<void> checkHealth() async {
    try {
      final res = await _dio.get('${NoorvaApiConfig.baseUrl}/health');
      if (res.statusCode != 200) {
        throw NoorvaApiException('Noorva server returned ${res.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('Noorva health: ${e.type} ${e.message} ${e.error}');
      throw NoorvaApiException(
        'Cannot reach Noorva. The staging server may be stopped — start EC2 (ec2-start-staging.sh) and try again.',
        serverDown: true,
      );
    }
  }

  /// Home “Ask Noorva” chat — persists server session id locally.
  Map<String, dynamic> _jsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw NoorvaApiException('Unexpected response from Noorva. Try again.');
  }

  String? _asString(dynamic v) => v == null ? null : v.toString();

  Map<String, dynamic>? _asMap(dynamic v) {
    if (v == null) return null;
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  Future<NoorvaChatResult> sendHomeChat(String text) async {
    await checkHealth();
    final stored = await NoorvaGuideSession.instance.chatSessionId();
    final sessionId =
        stored != null && stored.trim().isNotEmpty ? stored.trim() : null;
    final result = await sendChat(text, sessionId: sessionId);
    if (result.sessionId != null && result.sessionId!.trim().isNotEmpty) {
      await NoorvaGuideSession.instance.setChatSessionId(result.sessionId!);
    }
    return result;
  }

  /// Guide / HIAI thread — starts check-in once per app session, then responds.
  Future<NoorvaChatResult> sendGuideHiai(String text) async {
    await checkHealth();
    if (!await NoorvaGuideSession.instance.hiaiActive()) {
      await hiaiStart();
      await NoorvaGuideSession.instance.setHiaiActive(true);
    }
    return hiaiRespond(text);
  }

  Future<NoorvaChatResult> sendChat(String text, {String? sessionId}) async {
    final body = {...await _bodyExtras(), 'text': text};
    if (sessionId != null && sessionId.trim().isNotEmpty) {
      body['sessionId'] = sessionId.trim();
    }
    try {
      final res = await _dio.post('${NoorvaApiConfig.v1}/chat/messages', data: body);
      final data = _jsonMap(res.data);
      final handoff = _asMap(data['handoff']);
      String? jobId;
      if (handoff?['to'] == 'planning') {
        final payload = _asMap(handoff!['payload']);
        jobId = _asString(payload?['jobId']);
      }
      return NoorvaChatResult(
        message: _asString(data['message']) ?? '',
        sessionId: _asString(data['sessionId']),
        handoffJobId: jobId,
        expression: _asString(data['expression']),
      );
    } on NoorvaApiException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<void> hiaiNewSession() async {
    try {
      await _dio.post(
        '${NoorvaApiConfig.v1}/hiai/check-in/new-session',
        data: await _bodyExtras(),
      );
      await NoorvaGuideSession.instance.clearHiai();
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<NoorvaChatResult> hiaiStart() async {
    try {
      final res = await _dio.post(
        '${NoorvaApiConfig.v1}/hiai/check-in/start',
        data: await _bodyExtras(),
      );
      await NoorvaGuideSession.instance.setHiaiActive(true);
      final data = res.data as Map<String, dynamic>;
      return NoorvaChatResult(
        message: data['message'] as String? ?? '',
        expression: data['expression'] as String?,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<NoorvaChatResult> hiaiRespond(String text) async {
    try {
      final res = await _dio.post(
        '${NoorvaApiConfig.v1}/hiai/check-in/respond',
        data: {...await _bodyExtras(), 'text': text},
      );
      final data = res.data as Map<String, dynamic>;
      final handoff = data['handoff'] as Map<String, dynamic>?;
      String? jobId;
      if (handoff?['to'] == 'planning') {
        final payload = handoff!['payload'] as Map<String, dynamic>?;
        jobId = payload?['jobId'] as String?;
      }
      if (data['hiaiComplete'] == true) {
        await NoorvaGuideSession.instance.clearHiai();
      }
      return NoorvaChatResult(
        message: data['message'] as String? ?? '',
        handoffJobId: jobId,
        expression: data['expression'] as String?,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<NoorvaPlanJob> getPlanJob(String jobId) async {
    final userId = await NoorvaGuideSession.instance.userId();
    try {
      final res = await _dio.get(
        '${NoorvaApiConfig.v1}/plans/jobs/$jobId',
        queryParameters: {'userId': userId},
      );
      final data = res.data as Map<String, dynamic>;
      final progress = data['progress'] as Map<String, dynamic>?;
      final steps = <NoorvaPlanProgressStep>[];
      if (progress?['steps'] is List) {
        for (final s in progress!['steps'] as List) {
          final m = s as Map<String, dynamic>;
          steps.add(NoorvaPlanProgressStep(
            label: m['label'] as String? ?? '',
            state: m['state'] as String? ?? 'pending',
          ));
        }
      }
      final result = data['result'] as Map<String, dynamic>?;
      GuidePlanDocument? document;
      String? body;
      if (result != null) {
        final phaseList = <GuidePlanPhase>[];
        final phases = result['phases'] as List?;
        if (phases != null) {
          for (final ph in phases) {
            final p = ph as Map<String, dynamic>;
            final tasks = <GuidePlanTask>[];
            final taskRows = p['tasks'] as List?;
            if (taskRows != null) {
              for (final t in taskRows) {
                final task = t as Map<String, dynamic>;
                tasks.add(GuidePlanTask(
                  title: (task['title'] ?? task['description'] ?? 'Step').toString(),
                  description: task['description']?.toString(),
                  minutes: task['estimatedMinutes'] is num
                      ? (task['estimatedMinutes'] as num).toInt()
                      : null,
                ));
              }
            }
            phaseList.add(GuidePlanPhase(
              name: (p['name'] ?? 'Phase').toString(),
              tasks: tasks,
            ));
          }
        }
        document = GuidePlanDocument(
          title: (result['title'] ?? 'Your plan').toString(),
          intro: result['knowledgeOpening']?.toString(),
          researchSummary: result['researchSummary']?.toString(),
          phases: phaseList,
        );
        final buf = StringBuffer();
        if (document.researchSummary != null) {
          buf.writeln(document.researchSummary);
        }
        if (document.intro != null) buf.writeln(document.intro);
        for (final ph in document.phases) {
          buf.writeln('\n${ph.name}');
          for (final t in ph.tasks) {
            buf.writeln('• ${t.title}');
          }
        }
        body = buf.toString().trim();
      }
      return NoorvaPlanJob(
        status: data['status'] as String? ?? 'unknown',
        error: data['error'] as String?,
        progressLabel: progress?['label'] as String?,
        progressSteps: steps,
        planTitle: result?['title'] as String?,
        planBody: body,
        researchSummary: result?['researchSummary'] as String?,
        planDocument: document,
      );
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  NoorvaApiException _mapDio(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NoorvaApiException(
        'Cannot reach Noorva. Start the staging server (ec2-start-staging.sh) and retry.',
        serverDown: true,
      );
    }
    final msg = e.response?.data is Map
        ? (e.response!.data as Map)['message']?.toString()
        : null;
    return NoorvaApiException(msg ?? e.message ?? 'Request failed');
  }
}
