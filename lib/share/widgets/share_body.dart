import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';

import 'package:analytics/analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:io_photobooth/external_links/external_links.dart';
import 'package:io_photobooth/l10n/l10n.dart';
import 'package:io_photobooth/photobooth/photobooth.dart';
import 'package:io_photobooth/share/share.dart';
import 'package:photobooth_ui/photobooth_ui.dart';
import 'package:photos_repository/photos_repository.dart';

class ShareBody extends StatelessWidget {
  const ShareBody({super.key});

  @override
  Widget build(BuildContext context) {

    // final PhotosRepository photosRepository = PhotosRepository(
    //   firebaseStorage: FirebaseStorage.instance,
    //   // You can pass additional parameters as needed
    // );

    final textController = TextEditingController();
    final image = context.select((PhotoboothBloc bloc) => bloc.state.image);
    final file = context.select((ShareBloc bloc) => bloc.state.file);
    final compositeStatus = context.select(
      (ShareBloc bloc) => bloc.state.compositeStatus,
    );
    final compositedImage = context.select(
      (ShareBloc bloc) => bloc.state.bytes,
    );
    final isUploadSuccess = context.select(
      (ShareBloc bloc) => bloc.state.uploadStatus.isSuccess,
    );
    final shareUrl = context.select(
      (ShareBloc bloc) => bloc.state.explicitShareUrl,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // const AnimatedPhotoIndicator(),
          AnimatedPhotoboothPhoto(image: image),
          if (compositeStatus.isSuccess)
            AnimatedFadeIn(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  if (isUploadSuccess)
                    const ShareSuccessHeading()
                  else
                    const ShareHeading(),
                  const SizedBox(height: 20),
                  if (isUploadSuccess)
                    const ShareSuccessSubheading()
                  else
                    const ShareSubheading(),
                  const SizedBox(height: 30),
                  if (isUploadSuccess)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                        bottom: 30,
                      ),
                      child: ShareCopyableLink(link: shareUrl),
                    ),
                    // Add the TextField widget here
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 500,
                        right: 500,
                        bottom: 30,
                      ),
                      child: TextField(
                        controller: textController,
                        style: TextStyle(
                          color: Colors.white, // Set the text color to white
                        ),
                        decoration: InputDecoration(
                          labelText: 'Phone Number or Email',
                          labelStyle: TextStyle(color: Colors.white), // Set the label color to white
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // Set the border color to white
                          ),
                        ),
                        // You can add more properties and functionality to the TextField as needed.
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          String textFieldValue = textController.text;
                          print('Text from TextField: $textFieldValue');
                          final photosRepository = BlocProvider.of<ShareBloc>(context).photosRepository;

                          // final photosRepository = BlocProvider.of<PhotosRepository>(context);
                          // print(file!.path);
                          String filePath = file!.path;
                          String fileName = filePath.split('/').last + ".png";
                          // print('Filename: $fileName');

                          Uint8List dataBytes = await file.readAsBytes();
                          // Assuming `compositedImage` and `fileName` are available
                          final shareUrls = await photosRepository.sharePhoto(
                            fileName: fileName,
                            data: dataBytes,
                            shareText: 'Share it',
                          );

                          //Add information to database
                          final firestore = FirebaseFirestore.instance;
                          final CollectionReference photosCollection = firestore.collection('photos');
                          // Document data to be added
                          Map<String, dynamic> data = {
                            'church_city': 'shelbyville',
                            'church_name': 'st_joseph',
                            'contact': textFieldValue,
                            'file_name': fileName,
                          };

                          // Add document to the collection
                          await photosCollection.add(data);

                        } catch (error) {
                          // Handle any errors that occur during the upload process
                          print('Error uploading photo: $error');
                        }
                      },
                      child: Text('Submit'),
                    ),
                  // if (compositedImage != null && file != null)
                  //   ResponsiveLayoutBuilder(
                  //     small: (_, __) => MobileButtonsLayout(
                  //       image: compositedImage,
                  //       file: file,
                  //     ),
                  //     large: (_, __) => DesktopButtonsLayout(
                  //       image: compositedImage,
                  //       file: file,
                  //     ),
                  //   ),
                  const SizedBox(height: 28),
                  if (isUploadSuccess)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: const ShareSuccessCaption(),
                    ),
                ],
              ),
            ),
          if (compositeStatus.isFailure)
            const AnimatedFadeIn(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  ShareErrorHeading(),
                  SizedBox(height: 20),
                  ShareErrorSubheading(),
                  SizedBox(height: 30),
                ],
              ),
            )
        ],
      ),
    );
  }
}

@visibleForTesting
class DesktopButtonsLayout extends StatelessWidget {
  const DesktopButtonsLayout({
    required this.image,
    required this.file,
    super.key,
  });

  final Uint8List image;
  final XFile file;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: DownloadButton(file: file)),
        const SizedBox(width: 36),
        Flexible(child: ShareButton(image: image)),
        const SizedBox(width: 36),
        const GoToGoogleIOButton(),
      ],
    );
  }
}

@visibleForTesting
class MobileButtonsLayout extends StatelessWidget {
  const MobileButtonsLayout({
    required this.image,
    required this.file,
    super.key,
  });

  final Uint8List image;
  final XFile file;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DownloadButton(file: file),
        const SizedBox(height: 20),
        ShareButton(image: image),
        const SizedBox(height: 20),
        const GoToGoogleIOButton(),
      ],
    );
  }
}

@visibleForTesting
class GoToGoogleIOButton extends StatelessWidget {
  const GoToGoogleIOButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: PhotoboothColors.white,
      ),
      onPressed: launchGoogleIOLink,
      child: Text(
        l10n.goToGoogleIOButtonText,
        style: theme.textTheme.labelLarge?.copyWith(
          color: PhotoboothColors.black,
        ),
      ),
    );
  }
}

@visibleForTesting
class DownloadButton extends StatelessWidget {
  const DownloadButton({required this.file, super.key});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OutlinedButton(
      onPressed: () {
        trackEvent(
          category: 'button',
          action: 'click-download-photo',
          label: 'download-photo',
        );
        file.saveTo('');
      },
      child: Text(l10n.sharePageDownloadButtonText),
    );
  }
}
