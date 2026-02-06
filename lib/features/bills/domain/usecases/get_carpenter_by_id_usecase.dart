import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/bills/domain/entities/carpenter.dart';
import 'package:balaji_points/features/bills/domain/repositories/bill_repository.dart';

/// Use case for getting carpenter by ID
class GetCarpenterByIdUseCase {
  final BillRepository repository;

  GetCarpenterByIdUseCase(this.repository);

  Future<Either<Failure, Carpenter>> call(String carpenterId) async {
    if (carpenterId.isEmpty) {
      return const Left(ValidationFailure(message: 'Carpenter ID is required'));
    }

    return await repository.getCarpenterById(carpenterId);
  }
}
