import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class SharedTextManager extends ChangeNotifier {
  final List<String> _sharedText = [];

  void _addNewSharedText(String text) {
    _sharedText.add(text);

    notifyListeners();
  }

  List<String> get sharedText => _sharedText;

  void checkForNewMessages() {
    if (kIsWeb) return;
    ReceiveSharingIntent.instance.getMediaStream().listen(
      (value) {
        log("Get Media Stream is triggered with $value value");
        for (SharedMediaFile media in value) {
          _addNewSharedText(media.path);
        }
      },
    );

    ReceiveSharingIntent.instance.getInitialMedia().then(
      (value) {
        log("Get Initial Media is triggered with $value value");
        for (SharedMediaFile media in value) {
          _addNewSharedText(media.path);
        }
      },
    );
  }

  void removeFromSharedText(String text) {
    _sharedText.remove(text);

    notifyListeners();
  }
}
