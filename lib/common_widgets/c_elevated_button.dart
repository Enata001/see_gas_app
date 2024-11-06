import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CElevatedButton extends StatelessWidget {
  const CElevatedButton({
    super.key,
    required this.action,
    required this.title,
    this.widget,
    this.change = false,
    this.color,
  });

  final VoidCallback? action;
  final String title;
  final Widget? widget;
  final bool change;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color??Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
            backgroundColor: change
                ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                : color??Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: change
              ? null
              : () {
                  action?.call();
                },
          child: change
              ? widget
              : Text(
                  title,
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
