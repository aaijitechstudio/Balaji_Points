import 'package:balaji_points/features/wallet/domain/entities/bill.dart';
import 'package:balaji_points/features/wallet/domain/repositories/wallet_repository.dart';

/// Use case to get bills stream
/// 
/// Follows Clean Architecture principles - each use case has a single responsibility
class GetBillsStreamUseCase {
  final WalletRepository repository;
  
  GetBillsStreamUseCase(this.repository);
  
  Stream<List<Bill>> call(String userId) {
    return repository.getBillsStream(userId);
  }
}
