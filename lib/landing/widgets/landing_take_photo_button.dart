import 'package:analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';

class LandingTakePhotoButton extends StatelessWidget {
  const LandingTakePhotoButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ElevatedButton(
      onPressed: () {
        trackEvent(
          category: 'button',
          action: 'click-start-photobooth',
          label: 'start-photobooth',
        );
        Navigator.of(context).push(PhotoboothPage.route());
      },
      child: Text(l10n.landingPageTakePhotoButtonText),
    // return Container(
    //   width: 60, // Set the desired width and height to create a circular button
    //   height: 60,
    //   decoration: BoxDecoration(
    //     shape: BoxShape.circle,
    //     border: Border.all(
    //       color: Colors.black, // Set the border color
    //       width: 2.0, // Set the border width
    //     ),
    //   ),
    //   child: ElevatedButton(
    //     onPressed: () {
    //       trackEvent(
    //         category: 'button',
    //         action: 'click-start-photobooth',
    //         label: 'start-photobooth',
    //       );
    //       Navigator.of(context).push(PhotoboothPage.route());
    //     },
    //     style: ElevatedButton.styleFrom(
    //       padding: EdgeInsets.zero, // Remove padding to make the content fill the circular container
    //       primary: Colors.white, // Set the button's background color
    //     ),
    //     child: Icon(
    //       Icons.camera, // Replace with your preferred icon or Text widget
    //       size: 30, // Set the icon size
    //       color: Colors.black, // Set the icon color
    //     ),
      // ),
    );
  }
}
