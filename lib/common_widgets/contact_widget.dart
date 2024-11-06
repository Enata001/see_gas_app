import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class ContactWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final FocusNode? node;
  final bool? isEnabled;
  final String? Function(String?)? validator;
  final Function(String?)? onInputChange;

  const ContactWidget(
      {super.key,
      required this.phoneController,
      this.node,
      this.validator,
      this.onInputChange,
      this.isEnabled});

  @override
  Widget build(BuildContext context) {
    PhoneNumber number = PhoneNumber(isoCode: 'GH', dialCode: '+233');
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(
        context,
        color: Theme.of(context).colorScheme.secondary,
      ),
      borderRadius: BorderRadius.circular(
        10,
      ),
    );
    return InternationalPhoneNumberInput(
      onInputChanged: (PhoneNumber contact) {
        onInputChange?.call(contact.phoneNumber);
      },
      isEnabled: isEnabled ?? true,
      validator: validator,
      selectorConfig: const SelectorConfig(
        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
        trailingSpace: false,
      ),
      selectorTextStyle: GoogleFonts.lato(
        fontSize: 16,
        color: Theme.of(context).colorScheme.scrim,
      ),
      ignoreBlank: false,
      focusNode: node,
      inputDecoration: InputDecoration(
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: inputBorder,
          hintText: "Phone Number",
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.scrim)),
      autoValidateMode: AutovalidateMode.onUserInteraction,
      textFieldController: phoneController,
      formatInput: true,
      initialValue: number,
      textStyle: GoogleFonts.lato(
        fontSize: 16,
        color: Theme.of(context).colorScheme.scrim,
      ),
      keyboardType:
          const TextInputType.numberWithOptions(signed: true, decimal: true),
      inputBorder: inputBorder,
      onFieldSubmitted: (value) {},
    );
  }
}
