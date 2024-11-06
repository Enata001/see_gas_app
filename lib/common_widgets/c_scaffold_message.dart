import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:see_gas_app/providers/theme_provider.dart';
import 'package:see_gas_app/utils/themes.dart';

import '../utils/dimensions.dart';
import '../utils/navigation.dart';

class CScaffoldMessage extends StatelessWidget {
  final String title;
  final String message;
  final Function callback;

  const CScaffoldMessage(
      {super.key,
        required this.title,
        required this.message,
        required this.callback,});

  @override
  Widget build(BuildContext context) {
    return Consumer(

      builder: (context, ref, child) {
        final theme = ref.watch(themeProvider);
        final darkTheme = theme.theme == AppTheme.darkTheme;
        return Container(
          margin: const EdgeInsets.all(Dimensions.contentPadding),
          padding: const EdgeInsets.all(Dimensions.contentPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 17),
              ),
              const SizedBox(
                height: Dimensions.contentPadding,
              ),
              Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 15),
              ),
              const SizedBox(
                height: Dimensions.contentPadding,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: Navigation.close,
                    child: Text(
                      'No',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 15, color: !darkTheme ? Colors.grey : null),
                    ),
                  ),
                  const SizedBox(
                    height: Dimensions.contentPadding / 2,
                  ),
                  TextButton(
                    onPressed: () => callback(),
                    child: Text(
                      'Yes',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 17, color: !darkTheme ? Colors.red : null),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}
