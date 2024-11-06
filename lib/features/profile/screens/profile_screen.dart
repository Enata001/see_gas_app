import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:see_gas_app/common_widgets/c_elevated_button.dart';
import 'package:see_gas_app/common_widgets/c_text_field.dart';
import 'package:see_gas_app/models/user_model.dart';
import 'package:see_gas_app/providers/auth_state_notifier.dart';
import 'package:see_gas_app/providers/user_notifier.dart';
import 'package:see_gas_app/services/firebase_firestore_methods.dart';
import 'package:see_gas_app/services/firebase_storage_methods.dart';
import 'package:see_gas_app/utils/constants.dart';
import '../../../common_widgets/c_appbar.dart';
import '../../../common_widgets/contact_widget.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/navigation.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool isEditing = false;
  Uint8List? _pickedImage;
  final _imagePicker = ImagePicker();
  late TextEditingController _usernameController;
  late TextEditingController _contactController;

  UserModel? get userModel => ref.watch(userProvider);

  @override
  void initState() {
    super.initState();

    _usernameController =
        TextEditingController(text: ref.read(userProvider)?.username);
    _contactController =
        TextEditingController(text: ref.read(userProvider)?.phoneContact);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _pickedImage = bytes;
      });
      await _uploadImageToFirebase();
    }
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () {
                Navigation.close();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigation.close();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  void _showFullImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            height: MediaQuery.sizeOf(context).height * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.devicePadding),
              image: DecorationImage(
                fit: BoxFit.contain,
                image: _pickedImage != null
                    ? MemoryImage(_pickedImage!)
                    : ref.read(userProvider)?.photoLink != null
                        ? NetworkImage(ref.read(userProvider)!.photoLink ??
                            Constants.profileLink)
                        : NetworkImage(Constants.profileLink),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailStyle = GoogleFonts.aBeeZee(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );
    final authProvider = ref.watch(authStateNotifierProvider.notifier);
    final userModel = ref.watch(userProvider);
    return Scaffold(
      appBar: CAppBar(
        title: 'Profile Page',
        trailing: isEditing
            ? null
            : IconButton.filledTonal(
                onPressed: _toggleEdit,
                icon: Icon(Icons.edit),
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.contentPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimensions.contentPadding),
            Align(
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: _showFullImage, // Show full image on tap
                    child: CircleAvatar(
                      radius: Dimensions.iconRadius * 0.7,
                      backgroundImage: _pickedImage != null
                          ? MemoryImage(
                              _pickedImage!) // Use Uint8List for display
                          : NetworkImage(
                              userModel?.photoLink ?? Constants.profileLink,
                            ) as ImageProvider,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: _showImageSourceSheet,
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        size: Dimensions.iconRadius * 0.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Text('E-mail', style: Theme.of(context).textTheme.labelLarge),
            CTextField(
              labelText: userModel!.email,
              textInputType: TextInputType.emailAddress,
              enabled: false,
              tPadding: 8,
              basePadding: 8,
            ),
            const Spacer(flex: 1),
            Text('Username', style: Theme.of(context).textTheme.labelLarge),
            CTextField(
              controller: _usernameController,
              enabled: isEditing,
              textInputType: TextInputType.text,
              tPadding: 8,
              basePadding: 8,
              labelText: userModel.username,
            ),
            const Spacer(flex: 1),
            Text('Contact', style: Theme.of(context).textTheme.labelLarge),
            ContactWidget(
              isEnabled: isEditing,
              phoneController: _contactController,
            ),
            const Spacer(flex: 15),
            if (isEditing)
              CElevatedButton(
                action: () async {
                  await _saveChanges();
                },
                title: 'Save Changes',
              ),
            const Spacer(flex: 1),
            CElevatedButton(
              action: () async {
                await authProvider.signOut();
              },
              title: 'Sign Out',
            ),
            const Spacer(flex: 1),
            CElevatedButton(
              action: () {
                // Navigate to password reset/change password
              },
              title: 'Change Password',
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  // In your _ProfileScreenState class

  Future<void> _saveChanges() async {
    try {
      final updatedUser = userModel?.copyWith(
        username: _usernameController.text,
        phoneContact: _contactController.text,
      );
      await FirestoreMethods().updateUserData(updatedUser!);
      await ref.read(userProvider.notifier).updateUserDetails(
            username: _usernameController.text,
            phoneContact: _contactController.text,
          );
      _toggleEdit(); // Exit edit mode
    } catch (e) {
      print('Failed to save changes: $e');
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_pickedImage == null) return;
    try {
      final profileImageUrl = await FirebaseStorageMethods()
          .uploadImageToFirebase(_pickedImage!, userModel!.userId.toString());
      final updatedUser = userModel?.copyWith(photoLink: profileImageUrl);
      await FirestoreMethods().updateUserData(updatedUser!);
      await ref
          .read(userProvider.notifier)
          .updateUserDetails(photoLink: profileImageUrl);
    } catch (e) {
      print('Failed to upload image: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _contactController.dispose();
    super.dispose();
  }
}
