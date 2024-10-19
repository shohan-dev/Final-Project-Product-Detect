import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TAnimationLoaderWidget extends StatelessWidget {
  const TAnimationLoaderWidget({
    super.key,
    required this.text,
    required this.animation,
    this.showAction = false,
    this.actionText,
    this.onActionPressed,
  });

  final String text;
  final String animation;
  final bool showAction;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            animation,
            width: MediaQuery.of(context).size.width * 0.8,
          ),
          const SizedBox(height: 16.0), // Use a constant value or define TSizes.defaultSpace
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0), // Use a constant value or define TSizes.defaultSpace
          if (showAction) 
            SizedBox(
              width: 250,
              child: OutlinedButton(
                onPressed: onActionPressed,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black, // Use TColors.dark if defined
                ),
                child: Text(
                  actionText ?? '', // Handle null actionText
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: Colors.white, // Use TColors if defined
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
