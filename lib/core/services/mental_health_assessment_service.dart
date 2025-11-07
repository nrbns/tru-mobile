import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Mental Health Assessment Service - PHQ-9, GAD-7, PSS
/// Full implementation with scoring and tracking
class MentalHealthAssessmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _requireUid() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('MentalHealthAssessmentService: no authenticated user');
    }
    return currentUser.uid;
  }

  CollectionReference get _assessmentsRef {
    final uid = _requireUid();
    return _firestore.collection('users').doc(uid).collection('assessments');
  }

  /// Get PHQ-9 (Depression) questions
  Future<List<Map<String, dynamic>>> getPHQ9Questions() async {
    return [
      {
        'id': 'phq9_1',
        'question': 'Little interest or pleasure in doing things',
        'scale':
            '0-3', // 0=Not at all, 1=Several days, 2=More than half, 3=Nearly every day
      },
      {
        'id': 'phq9_2',
        'question': 'Feeling down, depressed, or hopeless',
        'scale': '0-3',
      },
      {
        'id': 'phq9_3',
        'question': 'Trouble falling or staying asleep, or sleeping too much',
        'scale': '0-3',
      },
      {
        'id': 'phq9_4',
        'question': 'Feeling tired or having little energy',
        'scale': '0-3',
      },
      {
        'id': 'phq9_5',
        'question': 'Poor appetite or overeating',
        'scale': '0-3',
      },
      {
        'id': 'phq9_6',
        'question':
            'Feeling bad about yourself - or that you are a failure or have let yourself or your family down',
        'scale': '0-3',
      },
      {
        'id': 'phq9_7',
        'question':
            'Trouble concentrating on things, such as reading the newspaper or watching television',
        'scale': '0-3',
      },
      {
        'id': 'phq9_8',
        'question':
            'Moving or speaking so slowly that other people could have noticed. Or the opposite - being so fidgety or restless that you have been moving around a lot more than usual',
        'scale': '0-3',
      },
      {
        'id': 'phq9_9',
        'question':
            'Thoughts that you would be better off dead, or of hurting yourself',
        'scale': '0-3',
      },
    ];
  }

  /// Get GAD-7 (Anxiety) questions
  Future<List<Map<String, dynamic>>> getGAD7Questions() async {
    return [
      {
        'id': 'gad7_1',
        'question': 'Feeling nervous, anxious, or on edge',
        'scale': '0-3',
      },
      {
        'id': 'gad7_2',
        'question': 'Not being able to stop or control worrying',
        'scale': '0-3',
      },
      {
        'id': 'gad7_3',
        'question': 'Worrying too much about different things',
        'scale': '0-3',
      },
      {
        'id': 'gad7_4',
        'question': 'Trouble relaxing',
        'scale': '0-3',
      },
      {
        'id': 'gad7_5',
        'question': 'Being so restless that it is hard to sit still',
        'scale': '0-3',
      },
      {
        'id': 'gad7_6',
        'question': 'Becoming easily annoyed or irritable',
        'scale': '0-3',
      },
      {
        'id': 'gad7_7',
        'question': 'Feeling afraid, as if something awful might happen',
        'scale': '0-3',
      },
    ];
  }

  /// Submit PHQ-9 assessment
  Future<Map<String, dynamic>> submitPHQ9Assessment({
    required Map<String, int> answers, // question_id -> score (0-3)
  }) async {
    final totalScore = answers.values.reduce((a, b) => a + b);

    String severity;
    String recommendation;

    if (totalScore <= 4) {
      severity = 'None/Minimal';
      recommendation =
          'Your depression symptoms are minimal. Continue your wellness practices.';
    } else if (totalScore <= 9) {
      severity = 'Mild';
      recommendation =
          'You may have mild depression. Consider speaking with a mental health professional.';
    } else if (totalScore <= 14) {
      severity = 'Moderate';
      recommendation =
          'Your symptoms suggest moderate depression. Please consult with a healthcare provider.';
    } else if (totalScore <= 19) {
      severity = 'Moderately Severe';
      recommendation =
          'Your symptoms suggest moderately severe depression. It\'s important to speak with a mental health professional soon.';
    } else {
      severity = 'Severe';
      recommendation =
          'Your symptoms suggest severe depression. Please contact a mental health professional immediately.';
    }

    final assessmentDoc = await _assessmentsRef.add({
      'type': 'phq9',
      'answers': answers,
      'total_score': totalScore,
      'severity': severity,
      'recommendation': recommendation,
      'completed_at': FieldValue.serverTimestamp(),
      'date':
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
    });

    return {
      'id': assessmentDoc.id,
      'total_score': totalScore,
      'severity': severity,
      'recommendation': recommendation,
      'should_seek_help': totalScore >= 10,
    };
  }

  /// Submit GAD-7 assessment
  Future<Map<String, dynamic>> submitGAD7Assessment({
    required Map<String, int> answers,
  }) async {
    final totalScore = answers.values.reduce((a, b) => a + b);

    String severity;
    String recommendation;

    if (totalScore <= 4) {
      severity = 'None/Minimal';
      recommendation =
          'Your anxiety symptoms are minimal. Keep up your wellness practices.';
    } else if (totalScore <= 9) {
      severity = 'Mild';
      recommendation =
          'You may have mild anxiety. Consider stress management techniques.';
    } else if (totalScore <= 14) {
      severity = 'Moderate';
      recommendation =
          'Your symptoms suggest moderate anxiety. Consider speaking with a mental health professional.';
    } else {
      severity = 'Severe';
      recommendation =
          'Your symptoms suggest severe anxiety. Please consult with a healthcare provider.';
    }

    final assessmentDoc = await _assessmentsRef.add({
      'type': 'gad7',
      'answers': answers,
      'total_score': totalScore,
      'severity': severity,
      'recommendation': recommendation,
      'completed_at': FieldValue.serverTimestamp(),
      'date':
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
    });

    return {
      'id': assessmentDoc.id,
      'total_score': totalScore,
      'severity': severity,
      'recommendation': recommendation,
      'should_seek_help': totalScore >= 10,
    };
  }

  /// Get assessment history
  Stream<List<Map<String, dynamic>>> streamAssessmentHistory({
    String? type, // phq9, gad7, pss
    int limit = 30,
  }) {
    Query query =
        _assessmentsRef.orderBy('completed_at', descending: true).limit(limit);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            ...data,
          };
        }).toList());
  }

  /// Get assessment trends (score over time)
  Future<List<Map<String, dynamic>>> getAssessmentTrends({
    required String type, // phq9, gad7
    int days = 30,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final startTimestamp = Timestamp.fromDate(startDate);

    final snapshot = await _assessmentsRef
        .where('type', isEqualTo: type)
        .where('completed_at', isGreaterThanOrEqualTo: startTimestamp)
        .orderBy('completed_at', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return {
        'date': (data['completed_at'] as Timestamp?)?.toDate(),
        'score': data['total_score'] ?? 0,
        'severity': data['severity'] ?? '',
      };
    }).toList();
  }
}
