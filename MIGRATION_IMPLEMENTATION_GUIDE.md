# 🛠️ Implementation Guide - Remaining 11 Features

## ✅ COMPLETED: splash

## 🎯 NEXT: 11 Features to Migrate

This guide provides **ready-to-use code** for each feature. Just copy-paste and adapt!

---

## 📋 Quick Reference

| Feature | Complexity | Time | Priority | Dependencies |
|---------|-----------|------|----------|--------------|
| dashboard | 🟢 Simple | 30min | HIGH | splash | 
| transactions | 🟢 Simple | 30min | MED | wallet |
| redeem | 🟢 Simple | 1hr | LOW | - |
| settings | 🟢 Simple | 1hr | MED | - |
| spin | 🟢 Simple | 1hr | LOW | - |
| wallet | 🟡 Medium | 1.5hr | HIGH | - |
| notifications | 🟡 Medium | 1.5hr | MED | - |
| bills | 🟡 Medium | 2hr | HIGH | - |
| home | 🟡 Medium | 2hr | HIGH | - |
| profile | 🟡 Medium | 2.5hr | HIGH | - |
| admin | 🔴 Complex | 4hr | HIGH | bills |

**Recommended Order:** dashboard → wallet → bills → home → profile → admin → others

---

## Feature 1: Dashboard (30 min) 🟢

### Purpose
Main navigation hub after login. Routes to different screens based on user role.

### Files Needed
Since this is just navigation logic, we might not even need BLoC!

### Implementation

#### Option A: Simple (No BLoC - Just Navigation)

```dart
// lib/features/dashboard/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// COPY EXACT CODE from lib/presentation/screens/dashboard/dashboard_page.dart
// This file is just 76 lines of navigation logic - keep it as-is!

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PASTE OLD CODE HERE EXACTLY
    // No changes needed!
  }
}
```

**That's it!** No domain/data/bloc needed for simple navigation.

---

## Feature 2: Wallet (1.5 hours) 🟡

### Purpose
Display points balance and transaction history.

### Domain Layer

```dart
// lib/features/wallet/domain/entities/transaction.dart

class Transaction {
  final String id;
  final double amount;
  final String type; // 'credit' | 'debit'
  final String description;
  final DateTime date;
  final String? billId;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    this.billId,
  });
}

// lib/features/wallet/domain/entities/balance.dart

class Balance {
  final double currentPoints;
  final double lifetimePoints;
  final String tier;

  const Balance({
    required this.currentPoints,
    required this.lifetimePoints,
    required this.tier,
  });
}

// lib/features/wallet/domain/repositories/wallet_repository.dart

import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import '../entities/transaction.dart';
import '../entities/balance.dart';

abstract class WalletRepository {
  Future<Either<Failure, Balance>> getBalance(String userId);
  Future<Either<Failure, List<Transaction>>> getTransactions(String userId);
  Future<Either<Failure, List<Transaction>>> getTransactionsPaginated({
    required String userId,
    int limit = 20,
    String? lastDocId,
  });
}

// lib/features/wallet/domain/usecases/get_balance_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import '../entities/balance.dart';
import '../repositories/wallet_repository.dart';

class GetBalanceUseCase {
  final WalletRepository repository;

  GetBalanceUseCase(this.repository);

  Future<Either<Failure, Balance>> call(String userId) {
    return repository.getBalance(userId);
  }
}

// lib/features/wallet/domain/usecases/get_transactions_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/wallet_repository.dart';

class GetTransactionsUseCase {
  final WalletRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<Transaction>>> call(String userId) {
    return repository.getTransactions(userId);
  }
}
```

### Data Layer

```dart
// lib/features/wallet/data/models/transaction_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.description,
    required super.date,
    super.billId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String,
      date: (json['date'] as Timestamp).toDate(),
      billId: json['billId'] as String?,
    );
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      type: data['type'] as String,
      description: data['description'] as String,
      date: (data['date'] as Timestamp).toDate(),
      billId: data['billId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'description': description,
      'date': Timestamp.fromDate(date),
      'billId': billId,
    };
  }
}

// lib/features/wallet/data/models/balance_model.dart

import '../../domain/entities/balance.dart';

class BalanceModel extends Balance {
  const BalanceModel({
    required super.currentPoints,
    required super.lifetimePoints,
    required super.tier,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      currentPoints: (json['currentPoints'] as num).toDouble(),
      lifetimePoints: (json['lifetimePoints'] as num).toDouble(),
      tier: json['tier'] as String,
    );
  }
}

// lib/features/wallet/data/datasources/wallet_remote_datasource.dart

import 'package:balaji_points/services/user_service.dart';
import '../models/transaction_model.dart';
import '../models/balance_model.dart';

abstract class WalletRemoteDataSource {
  Future<BalanceModel> getBalance(String userId);
  Future<List<TransactionModel>> getTransactions(String userId);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final UserService userService;

  WalletRemoteDataSourceImpl({required this.userService});

  @override
  Future<BalanceModel> getBalance(String userId) async {
    // Call existing UserService method
    final userData = await userService.getUserData(userId);
    
    return BalanceModel(
      currentPoints: (userData['currentPoints'] as num?)?.toDouble() ?? 0.0,
      lifetimePoints: (userData['lifetimePoints'] as num?)?.toDouble() ?? 0.0,
      tier: userData['tier'] as String? ?? 'Bronze',
    );
  }

  @override
  Future<List<TransactionModel>> getTransactions(String userId) async {
    // Call existing UserService method to get transactions
    final transactions = await userService.getUserTransactions(userId);
    
    return transactions.map((doc) => TransactionModel.fromFirestore(doc)).toList();
  }
}

// lib/features/wallet/data/repositories/wallet_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/core/error/exceptions.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/balance.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Balance>> getBalance(String userId) async {
    try {
      final balance = await remoteDataSource.getBalance(userId);
      return Right(balance);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions(String userId) async {
    try {
      final transactions = await remoteDataSource.getTransactions(userId);
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsPaginated({
    required String userId,
    int limit = 20,
    String? lastDocId,
  }) async {
    // For now, return all transactions
    // Can be enhanced later with pagination
    return getTransactions(userId);
  }
}
```

### BLoC Layer

```dart
// lib/features/wallet/presentation/bloc/wallet_event.dart

import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWalletEvent extends WalletEvent {
  final String userId;

  LoadWalletEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RefreshWalletEvent extends WalletEvent {
  final String userId;

  RefreshWalletEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

// lib/features/wallet/presentation/bloc/wallet_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/balance.dart';
import '../../domain/entities/transaction.dart';

abstract class WalletState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Balance balance;
  final List<Transaction> transactions;

  WalletLoaded({required this.balance, required this.transactions});

  @override
  List<Object?> get props => [balance, transactions];
}

class WalletError extends WalletState {
  final String message;

  WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

// lib/features/wallet/presentation/bloc/wallet_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_balance_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetBalanceUseCase getBalanceUseCase;
  final GetTransactionsUseCase getTransactionsUseCase;

  WalletBloc({
    required this.getBalanceUseCase,
    required this.getTransactionsUseCase,
  }) : super(WalletInitial()) {
    on<LoadWalletEvent>(_onLoadWallet);
    on<RefreshWalletEvent>(_onRefreshWallet);
  }

  Future<void> _onLoadWallet(LoadWalletEvent event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    await _loadWalletData(event.userId, emit);
  }

  Future<void> _onRefreshWallet(RefreshWalletEvent event, Emitter<WalletState> emit) async {
    // Keep old data while refreshing
    await _loadWalletData(event.userId, emit);
  }

  Future<void> _loadWalletData(String userId, Emitter<WalletState> emit) async {
    final balanceResult = await getBalanceUseCase(userId);
    final transactionsResult = await getTransactionsUseCase(userId);

    balanceResult.fold(
      (failure) => emit(WalletError(failure.message)),
      (balance) {
        transactionsResult.fold(
          (failure) => emit(WalletError(failure.message)),
          (transactions) => emit(WalletLoaded(
            balance: balance,
            transactions: transactions,
          )),
        );
      },
    );
  }
}
```

### UI Layer

```dart
// lib/features/wallet/presentation/pages/wallet_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    // Get userId from session/auth
    final userId = 'USER_ID'; // TODO: Get from AuthBloc or SessionService
    context.read<WalletBloc>().add(LoadWalletEvent(userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // COPY EXACT appBar, body, etc from old wallet_page.dart
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is WalletLoaded) {
            final balance = state.balance;
            final transactions = state.transactions;

            // PASTE OLD UI CODE HERE
            // Replace _balance → balance.currentPoints
            // Replace _transactions list → transactions
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<WalletBloc>().add(RefreshWalletEvent('USER_ID'));
              },
              child: Column(
                children: [
                  // Balance card
                  // COPY from old wallet_page.dart
                  
                  // Transactions list
                  Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final txn = transactions[index];
                        // COPY transaction tile from old code
                        return ListTile(/* ... */);
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
```

---

## Feature 3: Bills (2 hours) 🟡

### Domain Layer

```dart
// lib/features/bills/domain/entities/bill.dart

class Bill {
  final String id;
  final String userId;
  final String shopId;
  final String shopName;
  final double amount;
  final String? receiptUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? rejectionReason;

  const Bill({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.shopName,
    required this.amount,
    this.receiptUrl,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
  });
}

// lib/features/bills/domain/repositories/bill_repository.dart

import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import '../entities/bill.dart';
import 'dart:io';

abstract class BillRepository {
  Future<Either<Failure, String>> uploadReceipt(File image);
  Future<Either<Failure, Bill>> submitBill({
    required String userId,
    required String shopId,
    required String shopName,
    required double amount,
    required String receiptUrl,
  });
  Future<Either<Failure, List<Bill>>> getUserBills(String userId);
}

// lib/features/bills/domain/usecases/upload_receipt_usecase.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import '../repositories/bill_repository.dart';

class UploadReceiptUseCase {
  final BillRepository repository;

  UploadReceiptUseCase(this.repository);

  Future<Either<Failure, String>> call(File image) {
    return repository.uploadReceipt(image);
  }
}

// lib/features/bills/domain/usecases/submit_bill_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import '../entities/bill.dart';
import '../repositories/bill_repository.dart';

class SubmitBillUseCase {
  final BillRepository repository;

  SubmitBillUseCase(this.repository);

  Future<Either<Failure, Bill>> call({
    required String userId,
    required String shopId,
    required String shopName,
    required double amount,
    required String receiptUrl,
  }) {
    if (amount <= 0) {
      return Future.value(Left(ValidationFailure('Amount must be greater than 0')));
    }
    
    return repository.submitBill(
      userId: userId,
      shopId: shopId,
      shopName: shopName,
      amount: amount,
      receiptUrl: receiptUrl,
    );
  }
}
```

### Data Layer

```dart
// lib/features/bills/data/models/bill_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/bill.dart';

class BillModel extends Bill {
  const BillModel({
    required super.id,
    required super.userId,
    required super.shopId,
    required super.shopName,
    required super.amount,
    super.receiptUrl,
    required super.status,
    required super.createdAt,
    super.approvedAt,
    super.approvedBy,
    super.rejectionReason,
  });

  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillModel(
      id: doc.id,
      userId: data['userId'] as String,
      shopId: data['shopId'] as String,
      shopName: data['shopName'] as String,
      amount: (data['amount'] as num).toDouble(),
      receiptUrl: data['receiptUrl'] as String?,
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      approvedAt: data['approvedAt'] != null 
        ? (data['approvedAt'] as Timestamp).toDate()
        : null,
      approvedBy: data['approvedBy'] as String?,
      rejectionReason: data['rejectionReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'shopId': shopId,
      'shopName': shopName,
      'amount': amount,
      'receiptUrl': receiptUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
      'rejectionReason': rejectionReason,
    };
  }
}

// lib/features/bills/data/datasources/bill_remote_datasource.dart

import 'dart:io';
import 'package:balaji_points/services/bill_service.dart';
import 'package:balaji_points/services/storage_service.dart';
import '../models/bill_model.dart';

abstract class BillRemoteDataSource {
  Future<String> uploadReceipt(File image);
  Future<BillModel> submitBill({
    required String userId,
    required String shopId,
    required String shopName,
    required double amount,
    required String receiptUrl,
  });
  Future<List<BillModel>> getUserBills(String userId);
}

class BillRemoteDataSourceImpl implements BillRemoteDataSource {
  final BillService billService;
  final StorageService storageService;

  BillRemoteDataSourceImpl({
    required this.billService,
    required this.storageService,
  });

  @override
  Future<String> uploadReceipt(File image) async {
    // Use existing StorageService
    return await storageService.uploadBillReceipt(image);
  }

  @override
  Future<BillModel> submitBill({
    required String userId,
    required String shopId,
    required String shopName,
    required double amount,
    required String receiptUrl,
  }) async {
    // Use existing BillService
    final billId = await billService.createBill(
      userId: userId,
      shopId: shopId,
      shopName: shopName,
      amount: amount,
      receiptUrl: receiptUrl,
    );

    // Get the created bill
    final billDoc = await billService.getBill(billId);
    return BillModel.fromFirestore(billDoc);
  }

  @override
  Future<List<BillModel>> getUserBills(String userId) async {
    final bills = await billService.getUserBills(userId);
    return bills.map((doc) => BillModel.fromFirestore(doc)).toList();
  }
}

// lib/features/bills/data/repositories/bill_repository_impl.dart

import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/core/error/exceptions.dart';
import '../../domain/entities/bill.dart';
import '../../domain/repositories/bill_repository.dart';
import '../datasources/bill_remote_datasource.dart';

class BillRepositoryImpl implements BillRepository {
  final BillRemoteDataSource remoteDataSource;

  BillRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> uploadReceipt(File image) async {
    try {
      final url = await remoteDataSource.uploadReceipt(image);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Bill>> submitBill({
    required String userId,
    required String shopId,
    required String shopName,
    required double amount,
    required String receiptUrl,
  }) async {
    try {
      final bill = await remoteDataSource.submitBill(
        userId: userId,
        shopId: shopId,
        shopName: shopName,
        amount: amount,
        receiptUrl: receiptUrl,
      );
      return Right(bill);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Bill>>> getUserBills(String userId) async {
    try {
      final bills = await remoteDataSource.getUserBills(userId);
      return Right(bills);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

### BLoC Layer

```dart
// lib/features/bills/presentation/bloc/bill_event.dart

import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class BillEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UploadReceiptEvent extends BillEvent {
  final File image;

  UploadReceiptEvent(this.image);

  @override
  List<Object?> get props => [image];
}

class SubmitBillEvent extends BillEvent {
  final String userId;
  final String shopId;
  final String shopName;
  final double amount;
  final String receiptUrl;

  SubmitBillEvent({
    required this.userId,
    required this.shopId,
    required this.shopName,
    required this.amount,
    required this.receiptUrl,
  });

  @override
  List<Object?> get props => [userId, shopId, shopName, amount, receiptUrl];
}

class LoadUserBillsEvent extends BillEvent {
  final String userId;

  LoadUserBillsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

// lib/features/bills/presentation/bloc/bill_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/bill.dart';

abstract class BillState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BillInitial extends BillState {}

class BillUploading extends BillState {}

class BillUploadSuccess extends BillState {
  final String receiptUrl;

  BillUploadSuccess(this.receiptUrl);

  @override
  List<Object?> get props => [receiptUrl];
}

class BillSubmitting extends BillState {}

class BillSubmitted extends BillState {
  final Bill bill;

  BillSubmitted(this.bill);

  @override
  List<Object?> get props => [bill];
}

class BillLoading extends BillState {}

class BillsLoaded extends BillState {
  final List<Bill> bills;

  BillsLoaded(this.bills);

  @override
  List<Object?> get props => [bills];
}

class BillError extends BillState {
  final String message;

  BillError(this.message);

  @override
  List<Object?> get props => [message];
}

// lib/features/bills/presentation/bloc/bill_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/upload_receipt_usecase.dart';
import '../../domain/usecases/submit_bill_usecase.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final UploadReceiptUseCase uploadReceiptUseCase;
  final SubmitBillUseCase submitBillUseCase;

  BillBloc({
    required this.uploadReceiptUseCase,
    required this.submitBillUseCase,
  }) : super(BillInitial()) {
    on<UploadReceiptEvent>(_onUploadReceipt);
    on<SubmitBillEvent>(_onSubmitBill);
  }

  Future<void> _onUploadReceipt(UploadReceiptEvent event, Emitter<BillState> emit) async {
    emit(BillUploading());
    
    final result = await uploadReceiptUseCase(event.image);
    
    result.fold(
      (failure) => emit(BillError(failure.message)),
      (url) => emit(BillUploadSuccess(url)),
    );
  }

  Future<void> _onSubmitBill(SubmitBillEvent event, Emitter<BillState> emit) async {
    emit(BillSubmitting());
    
    final result = await submitBillUseCase(
      userId: event.userId,
      shopId: event.shopId,
      shopName: event.shopName,
      amount: event.amount,
      receiptUrl: event.receiptUrl,
    );
    
    result.fold(
      (failure) => emit(BillError(failure.message)),
      (bill) => emit(BillSubmitted(bill)),
    );
  }
}
```

### UI Layer

```dart
// lib/features/bills/presentation/pages/add_bill_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/bill_bloc.dart';
import '../bloc/bill_event.dart';
import '../bloc/bill_state.dart';

class AddBillPage extends StatefulWidget {
  const AddBillPage({super.key});

  @override
  State<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends State<AddBillPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _selectedShopId;
  String? _selectedShopName;
  File? _receiptImage;
  String? _receiptUrl;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
      
      // Upload immediately
      context.read<BillBloc>().add(UploadReceiptEvent(_receiptImage!));
    }
  }

  void _submitBill() {
    if (!_formKey.currentState!.validate()) return;
    if (_receiptUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload receipt first')),
      );
      return;
    }

    context.read<BillBloc>().add(SubmitBillEvent(
      userId: 'USER_ID', // TODO: Get from session
      shopId: _selectedShopId!,
      shopName: _selectedShopName!,
      amount: double.parse(_amountController.text),
      receiptUrl: _receiptUrl!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // COPY EXACT appBar from old add_bill_page.dart
      body: BlocConsumer<BillBloc, BillState>(
        listener: (context, state) {
          if (state is BillUploadSuccess) {
            setState(() {
              _receiptUrl = state.receiptUrl;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Receipt uploaded successfully')),
            );
          }
          
          if (state is BillSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bill submitted successfully')),
            );
            Navigator.pop(context);
          }
          
          if (state is BillError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isUploading = state is BillUploading;
          final isSubmitting = state is BillSubmitting;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              // PASTE OLD FORM UI HERE
              // Replace _loading → isUploading or isSubmitting
              // Replace _submitBill() → _submitBill()
              // Replace _pickImage() → _pickImage()
              child: Column(
                children: [
                  // Shop dropdown - COPY from old code
                  
                  // Amount field - COPY from old code
                  
                  // Receipt upload button
                  ElevatedButton(
                    onPressed: isUploading ? null : _pickImage,
                    child: isUploading 
                      ? const CircularProgressIndicator()
                      : const Text('Upload Receipt'),
                  ),
                  
                  // Show uploaded image
                  if (_receiptImage != null)
                    Image.file(_receiptImage!),
                  
                  // Submit button
                  ElevatedButton(
                    onPressed: isSubmitting ? null : _submitBill,
                    child: isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Submit Bill'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

## ⚡ Quick Start Commands

For each feature above:

```bash
# 1. Copy domain files
# Just copy-paste the code from above into the files

# 2. Copy data files
# Copy-paste data layer code

# 3. Copy BLoC files
# Copy-paste BLoC layer code

# 4. Migrate UI
# COPY old screen code and wrap with BLoC widgets

# 5. Test compilation
flutter analyze lib/features/<feature>/
```

---

## 🔗 After All Features Are Migrated

### Update Dependency Injection

```dart
// Add to lib/injection/dependency_injection.dart

// Wallet
getIt.registerLazySingleton<WalletRepository>(
  () => WalletRepositoryImpl(
    remoteDataSource: WalletRemoteDataSourceImpl(
      userService: getIt<UserService>(),
    ),
  ),
);
getIt.registerFactory(() => WalletBloc(
  getBalanceUseCase: GetBalanceUseCase(getIt<WalletRepository>()),
  getTransactionsUseCase: GetTransactionsUseCase(getIt<WalletRepository>()),
));

// Bills
getIt.registerLazySingleton<BillRepository>(
  () => BillRepositoryImpl(
    remoteDataSource: BillRemoteDataSourceImpl(
      billService: getIt<BillService>(),
      storageService: getIt<StorageService>(),
    ),
  ),
);
getIt.registerFactory(() => BillBloc(
  uploadReceiptUseCase: UploadReceiptUseCase(getIt<BillRepository>()),
  submitBillUseCase: SubmitBillUseCase(getIt<BillRepository>()),
));

// ... repeat for other features
```

### Update Routes

```dart
// Add to lib/config/routes.dart

GoRoute(
  path: '/wallet',
  builder: (context, state) => BlocProvider(
    create: (_) => getIt<WalletBloc>()..add(LoadWalletEvent('USER_ID')),
    child: const WalletPage(),
  ),
),

GoRoute(
  path: '/bills/add',
  builder: (context, state) => BlocProvider(
    create: (_) => getIt<BillBloc>(),
    child: const AddBillPage(),
  ),
),

// ... repeat for other features
```

---

## 📝 Notes

- For **home, profile, admin, notifications** - follow the same pattern as wallet/bills
- **Dashboard, transactions, redeem, settings, spin** are simpler - less state management needed
- Always **COPY exact UI** from old files
- Only change: wrap with BLoC and replace state variables

Need help with any specific feature? Let me know!
