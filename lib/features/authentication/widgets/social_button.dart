import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/dimensions.dart';

class SocialButton extends StatelessWidget {
  final String title;
  final String asset;
  final VoidCallback action;

  const SocialButton({
    required this.title,
    required this.asset,
    required this.action,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: Dimensions.contentPadding),
      height: 50,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(Dimensions.buttonRadius)),
      child: MaterialButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.buttonRadius),
        ),
        onPressed: action,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 30.0,
              width: 30.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(asset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              width: Dimensions.contentPadding,
            ),
            Text(
              title,
              style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
