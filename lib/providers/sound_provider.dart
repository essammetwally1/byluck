import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSound(String path) async {
    await _player.play(AssetSource('sounds/$path.mp3'));
    notifyListeners();
  }

  Future<void> stopSound() async {
    await _player.stop();
    notifyListeners();
  }
}
