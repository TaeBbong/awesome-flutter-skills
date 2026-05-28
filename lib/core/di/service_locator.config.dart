// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:awesome_flutter_skills/features/infinite_scroll/view_model/profile_list_view_model.dart'
    as _i361;
import 'package:awesome_flutter_skills/shared/data/profile_repository.dart'
    as _i645;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i645.ProfileRepository>(() => _i645.ProfileRepository());
    gh.factory<_i361.ProfileListViewModel>(
      () => _i361.ProfileListViewModel(gh<_i645.ProfileRepository>()),
    );
    return this;
  }
}
