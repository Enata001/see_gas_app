import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/models/user_model.dart';
import 'package:see_gas_app/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserNotifier extends StateNotifier<UserModel?> {
  final SharedPreferences pref;

  UserNotifier(super.userModel, this.pref);

  Future<void> loadUserFromCache() async {
    final user = pref.getUser();
    if (user != null) {
      Future.delayed(Duration.zero,(){
      state = user;

      });
    }
  }

  void updateUser(UserModel newUser) async {
    await cacheUser(newUser);
    state = newUser;
  }

  Future<void> cacheUser(UserModel user) async {
    await pref.saveUser(user);
    state = user;
  }

  Future<void> clearUser() async {
    await pref.clearUser();
    state = null;
  }

  Future<void> updateUserDetails({
    String? username,
    String? email,
    String? phoneContact,
    String? photoLink,
  }) async{
    state = state?.copyWith(
      username: username,
      email: email,
      phoneContact: phoneContact,
      photoLink: photoLink,
    );
   await cacheUser(state!);
  }
}

extension UserModelCopyWith on UserModel {
  UserModel copyWith({
    String? username,
    String? email,
    String? phoneContact,
    String? photoLink,
  }) {
    return UserModel(
      username: username ?? this.username,
      email: email ?? this.email,
      phoneContact: phoneContact ?? this.phoneContact,
      userId: userId,
      photoLink: photoLink ?? this.photoLink,
      devices: devices,
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  throw UnimplementedError();
});
