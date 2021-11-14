import 'package:arkanoid/arkanoid_game.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized(); //controllo che sia inizializzato altrimenti ci sono errori con il fullscreen
  if (!kIsWeb) {
    Flame.device.setLandscape(); // Imposto l'orientamento in orizzontale
    await Flame.device.fullScreen(); // Imposto la schermata fullscreen
  }

  await Flame.images.loadAll(<String>[
    'vr/cardboardview.png',
    'background/spike.png',
    'powerUp/d.png',
    'powerUp/e.png',
    'powerUp/f.png',
    'powerUp/r.png',
    'powerUp/m.png',
    'components/life.png'
  ]);



  ArkanoidGame game = ArkanoidGame();

  //sleep(Duration(seconds: 2));
  runApp(
    GameWidget(
      game: game,
    ),
  );
}
