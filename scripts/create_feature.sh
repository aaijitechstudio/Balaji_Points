#!/usr/bin/env bash
# scripts/create_feature.sh
# Purpose: Create a new feature with clean architecture structure
# Usage: ./scripts/create_feature.sh <feature_name>

set -e

FEATURE_NAME="$1"

if [ -z "$FEATURE_NAME" ]; then
  echo "Error: Feature name required"
  echo "Usage: ./scripts/create_feature.sh <feature_name>"
  echo "Example: ./scripts/create_feature.sh reward_points"
  exit 1
fi

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Creating feature: $FEATURE_NAME${NC}"
echo ""

# Create directory structure
echo "Creating directory structure..."

mkdir -p "lib/features/$FEATURE_NAME/data/datasources"
mkdir -p "lib/features/$FEATURE_NAME/data/models"
mkdir -p "lib/features/$FEATURE_NAME/data/repositories"
mkdir -p "lib/features/$FEATURE_NAME/domain/entities"
mkdir -p "lib/features/$FEATURE_NAME/domain/repositories"
mkdir -p "lib/features/$FEATURE_NAME/domain/usecases"
mkdir -p "lib/features/$FEATURE_NAME/presentation/bloc"
mkdir -p "lib/features/$FEATURE_NAME/presentation/pages"
mkdir -p "lib/features/$FEATURE_NAME/presentation/widgets"

echo -e "${GREEN}✓${NC} Directory structure created"

# Create template files
echo "Creating template files..."

# Entity template
cat > "lib/features/$FEATURE_NAME/domain/entities/${FEATURE_NAME}.dart" << 'ENTITY_EOF'
/// Domain entity for FEATURE_NAME
/// 
/// This is a plain Dart class with no dependencies on external packages.
/// It represents the business logic model.
class FeatureNameEntity {
  final String id;
  // Add your entity properties here
  
  FeatureNameEntity({
    required this.id,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureNameEntity && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
ENTITY_EOF

# Repository interface template
cat > "lib/features/$FEATURE_NAME/domain/repositories/${FEATURE_NAME}_repository.dart" << 'REPO_INTERFACE_EOF'
import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/FEATURE_NAME/domain/entities/FEATURE_NAME.dart';

/// Repository interface for FEATURE_NAME
/// 
/// Defines the contract that the data layer must implement.
/// Returns Either<Failure, Data> for error handling.
abstract class FeatureNameRepository {
  Future<Either<Failure, FeatureNameEntity>> getFeatureName(String id);
  Future<Either<Failure, List<FeatureNameEntity>>> getAll();
  Future<Either<Failure, void>> create(FeatureNameEntity entity);
  Future<Either<Failure, void>> update(FeatureNameEntity entity);
  Future<Either<Failure, void>> delete(String id);
}
REPO_INTERFACE_EOF

# Use case template
cat > "lib/features/$FEATURE_NAME/domain/usecases/get_${FEATURE_NAME}_usecase.dart" << 'USECASE_EOF'
import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/FEATURE_NAME/domain/entities/FEATURE_NAME.dart';
import 'package:balaji_points/features/FEATURE_NAME/domain/repositories/FEATURE_NAME_repository.dart';

/// Use case for getting FEATURE_NAME
/// 
/// Each use case handles a single business operation.
/// Contains the business logic for that specific operation.
class GetFeatureNameUseCase {
  final FeatureNameRepository repository;
  
  GetFeatureNameUseCase(this.repository);
  
  Future<Either<Failure, FeatureNameEntity>> call(String id) {
    return repository.getFeatureName(id);
  }
}
USECASE_EOF

# Model template
cat > "lib/features/$FEATURE_NAME/data/models/${FEATURE_NAME}_model.dart" << 'MODEL_EOF'
import 'package:balaji_points/features/FEATURE_NAME/domain/entities/FEATURE_NAME.dart';

/// Data model for FEATURE_NAME
/// 
/// Extends the domain entity and adds JSON serialization.
/// Handles conversion between JSON and domain entities.
class FeatureNameModel extends FeatureNameEntity {
  FeatureNameModel({
    required super.id,
  });
  
  /// Convert from JSON
  factory FeatureNameModel.fromJson(Map<String, dynamic> json) {
    return FeatureNameModel(
      id: json['id'] as String,
    );
  }
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
  
  /// Convert from domain entity
  factory FeatureNameModel.fromEntity(FeatureNameEntity entity) {
    return FeatureNameModel(
      id: entity.id,
    );
  }
  
  /// Convert to domain entity
  FeatureNameEntity toEntity() {
    return FeatureNameEntity(
      id: id,
    );
  }
}
MODEL_EOF

# Data source template
cat > "lib/features/$FEATURE_NAME/data/datasources/${FEATURE_NAME}_remote_datasource.dart" << 'DATASOURCE_EOF'
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balaji_points/features/FEATURE_NAME/data/models/FEATURE_NAME_model.dart';

/// Remote data source for FEATURE_NAME
/// 
/// Handles all network/database operations for this feature.
/// Throws exceptions on errors (handled by repository).
abstract class FeatureNameRemoteDataSource {
  Future<FeatureNameModel> getFeatureName(String id);
  Future<List<FeatureNameModel>> getAll();
  Future<void> create(FeatureNameModel model);
  Future<void> update(FeatureNameModel model);
  Future<void> delete(String id);
}

class FeatureNameRemoteDataSourceImpl implements FeatureNameRemoteDataSource {
  final FirebaseFirestore firestore;
  
  FeatureNameRemoteDataSourceImpl({required this.firestore});
  
  @override
  Future<FeatureNameModel> getFeatureName(String id) async {
    try {
      final doc = await firestore.collection('COLLECTION_NAME').doc(id).get();
      
      if (!doc.exists) {
        throw Exception('FEATURE_NAME not found');
      }
      
      return FeatureNameModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get FEATURE_NAME: $e');
    }
  }
  
  @override
  Future<List<FeatureNameModel>> getAll() async {
    try {
      final snapshot = await firestore.collection('COLLECTION_NAME').get();
      return snapshot.docs
          .map((doc) => FeatureNameModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get all FEATURE_NAME: $e');
    }
  }
  
  @override
  Future<void> create(FeatureNameModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .set(model.toJson());
    } catch (e) {
      throw Exception('Failed to create FEATURE_NAME: $e');
    }
  }
  
  @override
  Future<void> update(FeatureNameModel model) async {
    try {
      await firestore
          .collection('COLLECTION_NAME')
          .doc(model.id)
          .update(model.toJson());
    } catch (e) {
      throw Exception('Failed to update FEATURE_NAME: $e');
    }
  }
  
  @override
  Future<void> delete(String id) async {
    try {
      await firestore.collection('COLLECTION_NAME').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete FEATURE_NAME: $e');
    }
  }
}
DATASOURCE_EOF

# Repository implementation template
cat > "lib/features/$FEATURE_NAME/data/repositories/${FEATURE_NAME}_repository_impl.dart" << 'REPO_IMPL_EOF'
import 'package:dartz/dartz.dart';
import 'package:balaji_points/core/error/failures.dart';
import 'package:balaji_points/features/FEATURE_NAME/domain/entities/FEATURE_NAME.dart';
import 'package:balaji_points/features/FEATURE_NAME/domain/repositories/FEATURE_NAME_repository.dart';
import 'package:balaji_points/features/FEATURE_NAME/data/datasources/FEATURE_NAME_remote_datasource.dart';
import 'package:balaji_points/features/FEATURE_NAME/data/models/FEATURE_NAME_model.dart';

/// Repository implementation for FEATURE_NAME
/// 
/// Implements the repository interface from domain layer.
/// Handles data source calls and error conversion.
class FeatureNameRepositoryImpl implements FeatureNameRepository {
  final FeatureNameRemoteDataSource remoteDataSource;
  
  FeatureNameRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<Either<Failure, FeatureNameEntity>> getFeatureName(String id) async {
    try {
      final model = await remoteDataSource.getFeatureName(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<FeatureNameEntity>>> getAll() async {
    try {
      final models = await remoteDataSource.getAll();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> create(FeatureNameEntity entity) async {
    try {
      final model = FeatureNameModel.fromEntity(entity);
      await remoteDataSource.create(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> update(FeatureNameEntity entity) async {
    try {
      final model = FeatureNameModel.fromEntity(entity);
      await remoteDataSource.update(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await remoteDataSource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
REPO_IMPL_EOF

# BLoC event template
cat > "lib/features/$FEATURE_NAME/presentation/bloc/${FEATURE_NAME}_event.dart" << 'EVENT_EOF'
import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/FEATURE_NAME/domain/entities/FEATURE_NAME.dart';

/// Events for FEATURE_NAME BLoC
abstract class FeatureNameEvent extends Equatable {
  const FeatureNameEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadFeatureName extends FeatureNameEvent {
  final String id;
  
  const LoadFeatureName(this.id);
  
  @override
  List<Object?> get props => [id];
}

class LoadAllFeatureNames extends FeatureNameEvent {
  const LoadAllFeatureNames();
}

class CreateFeatureName extends FeatureNameEvent {
  final FeatureNameEntity entity;
  
  const CreateFeatureName(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class UpdateFeatureName extends FeatureNameEvent {
  final FeatureNameEntity entity;
  
  const UpdateFeatureName(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class DeleteFeatureName extends FeatureNameEvent {
  final String id;
  
  const DeleteFeatureName(this.id);
  
  @override
  List<Object?> get props => [id];
}
EVENT_EOF

# BLoC state template
cat > "lib/features/$FEATURE_NAME/presentation/bloc/${FEATURE_NAME}_state.dart" << 'STATE_EOF'
import 'package:equatable/equatable.dart';
import 'package:balaji_points/features/FEATURE_NAME/domain/entities/FEATURE_NAME.dart';

/// States for FEATURE_NAME BLoC
abstract class FeatureNameState extends Equatable {
  const FeatureNameState();
  
  @override
  List<Object?> get props => [];
}

class FeatureNameInitial extends FeatureNameState {
  const FeatureNameInitial();
}

class FeatureNameLoading extends FeatureNameState {
  const FeatureNameLoading();
}

class FeatureNameLoaded extends FeatureNameState {
  final FeatureNameEntity entity;
  
  const FeatureNameLoaded(this.entity);
  
  @override
  List<Object?> get props => [entity];
}

class FeatureNamesLoaded extends FeatureNameState {
  final List<FeatureNameEntity> entities;
  
  const FeatureNamesLoaded(this.entities);
  
  @override
  List<Object?> get props => [entities];
}

class FeatureNameError extends FeatureNameState {
  final String message;
  
  const FeatureNameError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class FeatureNameOperationSuccess extends FeatureNameState {
  final String message;
  
  const FeatureNameOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
STATE_EOF

# BLoC template
cat > "lib/features/$FEATURE_NAME/presentation/bloc/${FEATURE_NAME}_bloc.dart" << 'BLOC_EOF'
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balaji_points/features/FEATURE_NAME/domain/usecases/get_FEATURE_NAME_usecase.dart';
import 'package:balaji_points/features/FEATURE_NAME/presentation/bloc/FEATURE_NAME_event.dart';
import 'package:balaji_points/features/FEATURE_NAME/presentation/bloc/FEATURE_NAME_state.dart';

/// BLoC for FEATURE_NAME
/// 
/// Handles state management for FEATURE_NAME feature.
/// Uses use cases to execute business logic.
class FeatureNameBloc extends Bloc<FeatureNameEvent, FeatureNameState> {
  final GetFeatureNameUseCase getFeatureNameUseCase;
  // Add other use cases as needed
  
  FeatureNameBloc({
    required this.getFeatureNameUseCase,
  }) : super(const FeatureNameInitial()) {
    on<LoadFeatureName>(_onLoadFeatureName);
    on<LoadAllFeatureNames>(_onLoadAllFeatureNames);
    on<CreateFeatureName>(_onCreateFeatureName);
    on<UpdateFeatureName>(_onUpdateFeatureName);
    on<DeleteFeatureName>(_onDeleteFeatureName);
  }
  
  Future<void> _onLoadFeatureName(
    LoadFeatureName event,
    Emitter<FeatureNameState> emit,
  ) async {
    emit(const FeatureNameLoading());
    
    final result = await getFeatureNameUseCase(event.id);
    
    result.fold(
      (failure) => emit(FeatureNameError(failure.message)),
      (entity) => emit(FeatureNameLoaded(entity)),
    );
  }
  
  Future<void> _onLoadAllFeatureNames(
    LoadAllFeatureNames event,
    Emitter<FeatureNameState> emit,
  ) async {
    emit(const FeatureNameLoading());
    
    // Implement using GetAllFeatureNamesUseCase
    // final result = await getAllFeatureNamesUseCase();
    
    // result.fold(
    //   (failure) => emit(FeatureNameError(failure.message)),
    //   (entities) => emit(FeatureNamesLoaded(entities)),
    // );
  }
  
  Future<void> _onCreateFeatureName(
    CreateFeatureName event,
    Emitter<FeatureNameState> emit,
  ) async {
    emit(const FeatureNameLoading());
    
    // Implement using CreateFeatureNameUseCase
  }
  
  Future<void> _onUpdateFeatureName(
    UpdateFeatureName event,
    Emitter<FeatureNameState> emit,
  ) async {
    emit(const FeatureNameLoading());
    
    // Implement using UpdateFeatureNameUseCase
  }
  
  Future<void> _onDeleteFeatureName(
    DeleteFeatureName event,
    Emitter<FeatureNameState> emit,
  ) async {
    emit(const FeatureNameLoading());
    
    // Implement using DeleteFeatureNameUseCase
  }
}
BLOC_EOF

# Page template
cat > "lib/features/$FEATURE_NAME/presentation/pages/${FEATURE_NAME}_page.dart" << 'PAGE_EOF'
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balaji_points/l10n/app_localizations.dart';
import 'package:balaji_points/core/theme/design_token.dart';
import 'package:balaji_points/features/FEATURE_NAME/presentation/bloc/FEATURE_NAME_bloc.dart';
import 'package:balaji_points/features/FEATURE_NAME/presentation/bloc/FEATURE_NAME_event.dart';
import 'package:balaji_points/features/FEATURE_NAME/presentation/bloc/FEATURE_NAME_state.dart';

/// FEATURE_NAME Page
/// 
/// Main screen for FEATURE_NAME feature.
/// Uses BLoC for state management.
class FeatureNamePage extends StatelessWidget {
  const FeatureNamePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.featureNameTitle), // Add to localization
      ),
      body: BlocConsumer<FeatureNameBloc, FeatureNameState>(
        listener: (context, state) {
          if (state is FeatureNameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: DesignToken.error,
              ),
            );
          } else if (state is FeatureNameOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: DesignToken.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FeatureNameLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is FeatureNameLoaded) {
            return _buildContent(context, state.entity);
          }
          
          if (state is FeatureNamesLoaded) {
            return _buildList(context, state.entities);
          }
          
          return Center(
            child: Text(
              l10n.noDataAvailable, // Add to localization
              style: DesignToken.bodyLarge,
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, dynamic entity) {
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: DesignToken.paddingAllLG,
      child: Column(
        children: [
          // Build your UI here
          Text(
            'Feature Name Content',
            style: DesignToken.heading1,
          ),
        ],
      ),
    );
  }
  
  Widget _buildList(BuildContext context, List<dynamic> entities) {
    return ListView.builder(
      padding: DesignToken.paddingAllLG,
      itemCount: entities.length,
      itemBuilder: (context, index) {
        final entity = entities[index];
        return ListTile(
          title: Text(entity.id),
          // Add more details
        );
      },
    );
  }
}
PAGE_EOF

# Replace placeholders
find "lib/features/$FEATURE_NAME" -type f -exec sed -i '' "s/FEATURE_NAME/$FEATURE_NAME/g" {} \;
find "lib/features/$FEATURE_NAME" -type f -exec sed -i '' "s/FeatureName/$(echo $FEATURE_NAME | sed -r 's/(^|_)([a-z])/\U\2/g')/g" {} \;

echo -e "${GREEN}✓${NC} Template files created"

echo ""
echo -e "${GREEN}✓ Feature created successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Update the generated files with your specific logic"
echo "  2. Add the feature to dependency injection"
echo "  3. Add routes for the feature pages"
echo "  4. Write tests"
echo "  5. Run: ./scripts/validate_feature.sh $FEATURE_NAME"
echo ""
echo "Files created in: lib/features/$FEATURE_NAME/"

