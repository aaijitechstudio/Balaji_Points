import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/bills/domain/entities/carpenter.dart';
import 'package:balaji_points/features/bills/domain/repositories/bill_repository.dart';

/// Use case for getting carpenters list
class GetCarpentersUseCase {
  final BillRepository repository;

  GetCarpentersUseCase(this.repository);

  Future<Either<Failure, List<Carpenter>>> call() async {
    return await repository.getCarpenters();
  }
}
