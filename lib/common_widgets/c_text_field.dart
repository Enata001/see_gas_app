import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:see_gas_app/utils/dimensions.dart';

class CTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final TextInputType textInputType;
  final bool isPassword;
  final IconData? icon;
  final VoidCallback? action;
  final String? Function(String?)? validator;
  final String? initialValue;
  final bool? expands;
  final bool? filled;
  final bool? enabled;
  final Color? fillColor;
  final TextCapitalization? textCapitalization;
  final Function(String?)? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? inputAction;
  final double? tPadding;
  final double? basePadding;
  final TextStyle? labelStyle;

  final Function(String?)? onSubmitted;

  const CTextField({
    super.key,
    this.controller,
    required this.labelText,
    required this.textInputType,
    this.isPassword = false,
    this.icon,
    this.action,
    this.validator,
    this.initialValue,
    this.expands,
    this.filled,
    this.fillColor,
    this.onChanged,
    this.textCapitalization,
    this.focusNode,
    this.onSubmitted,
    this.inputAction,
    this.enabled,
    this.tPadding,
    this.basePadding,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(
        context,
        color: Theme.of(context).colorScheme.secondary,
      ),
      borderRadius: BorderRadius.circular(
        10,
      ),
    );
    return Container(
      margin: EdgeInsets.only(
        top: tPadding ?? Dimensions.contentPadding,
        bottom: basePadding ?? 0,

      ),
      // height: 50,
      // height: Dimensions.,
      child: TextFormField(
        initialValue: initialValue,
        style: GoogleFonts.lato(
          fontSize: 16,
          color: Theme.of(context).colorScheme.scrim,
        ),
        autovalidateMode: AutovalidateMode.onUnfocus,
        expands: expands ?? false,
        controller: controller,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        textInputAction: inputAction,
        onFieldSubmitted: onSubmitted,
        onChanged: onChanged,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        decoration: InputDecoration(
          fillColor: fillColor,
          filled: filled,
          suffixIcon: icon != null
              ? IconButton(
                  onPressed: action,
                  icon: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                )
              : null,
          hintText: labelText,
          labelStyle: labelStyle ?? GoogleFonts.lato(
            fontSize: 16,
            color: Theme.of(context).colorScheme.scrim,
          ),
          hintStyle: GoogleFonts.lato(
            fontSize: 16,
            color: Theme.of(context).colorScheme.scrim,
          ),
          alignLabelWithHint: true,
          border: inputBorder,
          focusedBorder: inputBorder,
          enabledBorder: inputBorder,
          enabled: enabled ?? true,
          contentPadding: const EdgeInsets.all(
            10,
          ),
        ),
        obscureText: isPassword,
        keyboardType: textInputType,
        validator: validator,
      ),
    );
  }
}
