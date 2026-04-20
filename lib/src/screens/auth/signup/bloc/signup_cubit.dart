import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";

class SignupState extends Equatable {
  final String? gender;
  final String? choosenDivision;
  final String? choosenDistrict;
  final String? choosenThana;

  const SignupState({
    this.gender,
    this.choosenDivision,
    this.choosenDistrict,
    this.choosenThana,
  });

  SignupState copyWith({
    String? gender,
    String? choosenDivision,
    String? choosenDistrict,
    String? choosenThana,
  }) {
    return SignupState(
      gender: gender ?? this.gender,
      choosenDivision: choosenDivision ?? this.choosenDivision,
      choosenDistrict: choosenDistrict ?? this.choosenDistrict,
      choosenThana: choosenThana ?? this.choosenThana,
    );
  }

  @override
  List<Object?> get props => [gender, choosenDivision, choosenDistrict, choosenThana];
}

class SignupCubit extends Cubit<SignupState> {
  SignupCubit() : super(const SignupState());

  void updateGender(String? gender) {
    emit(state.copyWith(gender: gender));
  }

  void updateDivision(String? division) {
    emit(state.copyWith(choosenDivision: division));
  }

  void updateDistrict(String? district) {
    emit(state.copyWith(choosenDistrict: district));
  }

  void updateThana(String? thana) {
    emit(state.copyWith(choosenThana: thana));
  }
}
