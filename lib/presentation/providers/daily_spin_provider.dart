import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailySpinState {
  final bool canSpin;
  final DateTime? lastSpinDate;
  final bool isLoading;
  final int? pointsWon;
  final bool isCarpenter;

  DailySpinState({
    required this.canSpin,
    this.lastSpinDate,
    required this.isLoading,
    this.pointsWon,
    required this.isCarpenter,
  });

  DailySpinState copyWith({
    bool? canSpin,
    DateTime? lastSpinDate,
    bool? isLoading,
    int? pointsWon,
    bool? isCarpenter,
  }) {
    return DailySpinState(
      canSpin: canSpin ?? this.canSpin,
      lastSpinDate: lastSpinDate ?? this.lastSpinDate,
      isLoading: isLoading ?? this.isLoading,
      pointsWon: pointsWon ?? this.pointsWon,
      isCarpenter: isCarpenter ?? this.isCarpenter,
    );
  }
}

class DailySpinNotifier extends Notifier<DailySpinState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  DailySpinState build() {
    // Initialize state asynchronously
    Future.microtask(() => _initializeSpinState());
    // For testing: show widget even if not carpenter, set canSpin to true by default
    return DailySpinState(canSpin: true, isLoading: false, isCarpenter: true);
  }

  Future<void> _initializeSpinState() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        // For testing: allow spin even without user
        state = state.copyWith(
          isLoading: false,
          isCarpenter: true,
          canSpin: true,
        );
        return;
      }

      // Check if user is a carpenter
      // final userDoc = await _firestore.collection('users').doc(user.uid).get();
      // final userData = userDoc.data();
      // final userRole = userData?['role'] as String? ?? '';
      // final isCarpenter = userRole.toLowerCase() == 'carpenter';

      // For testing: allow even if not carpenter in Firestore
      // Uncomment above and below for production
      // if (!isCarpenter) {
      //   state = state.copyWith(isLoading: false, isCarpenter: false);
      //   return;
      // }

      // Check last spin date
      final lastSpinDoc = await _firestore
          .collection('daily_spins')
          .doc(user.uid)
          .get();

      DateTime? lastSpinDate;
      if (lastSpinDoc.exists) {
        final lastSpinData = lastSpinDoc.data();
        final timestamp = lastSpinData?['lastSpinDate'] as Timestamp?;
        lastSpinDate = timestamp?.toDate();
      }

      final now = DateTime.now();
      final canSpin =
          lastSpinDate == null ||
          lastSpinDate.year != now.year ||
          lastSpinDate.month != now.month ||
          lastSpinDate.day != now.day;

      state = state.copyWith(
        canSpin: canSpin,
        lastSpinDate: lastSpinDate,
        isLoading: false,
        isCarpenter: true, // Always true for testing
      );
    } catch (e) {
      // On error, still allow spin for testing
      state = state.copyWith(
        isLoading: false,
        isCarpenter: true,
        canSpin: true,
      );
    }
  }

  Future<int> performSpin() async {
    if (!state.canSpin) {
      return 0;
    }

    state = state.copyWith(isLoading: true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return 0;
      }

      // Generate random points (you can customize the rewards)
      final random = DateTime.now().millisecondsSinceEpoch % 1000;
      final pointsWon = (random % 6) * 10 + 10; // Points between 10-60

      // Update last spin date
      await _firestore.collection('daily_spins').doc(user.uid).set({
        'lastSpinDate': FieldValue.serverTimestamp(),
        'pointsWon': pointsWon,
      }, SetOptions(merge: true));

      // Update user points (if you have a points system)
      await _firestore.collection('users').doc(user.uid).update({
        'points': FieldValue.increment(pointsWon),
      });

      state = state.copyWith(
        canSpin: false,
        lastSpinDate: DateTime.now(),
        isLoading: false,
        pointsWon: pointsWon,
      );

      return pointsWon;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return 0;
    }
  }

  void refresh() {
    _initializeSpinState();
  }
}

final dailySpinProvider = NotifierProvider<DailySpinNotifier, DailySpinState>(
  () => DailySpinNotifier(),
);
