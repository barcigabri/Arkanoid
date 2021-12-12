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
    'background/penalization.png',
    'background/field.png',
    'background/frame.png',
    'powerUp/d.png',
    'powerUp/e.png',
    'powerUp/f.png',
    'powerUp/r.png',
    'powerUp/m.png',
    'powerUp/l.png',
    'components/life.png',
    'components/paddle_normal.png',
    'components/paddle_create.png',
    'components/paddle_laser.png',
    'components/laser.png',
    'components/paddle_create_laser.png',
    'components/paddle_extended.png',
    'components/paddle_decompose.png',
    'components/paddle_destruction.png',
    'components/blocks.png',
    'components/ball.png',
    'components/megaball.png',
    'powerUp/powerups.png',
    'shadows/block.png',
    'shadows/paddle.png',
    'shadows/bonus.png',
    'shadows/blank.png',
    'shadows/ball.png'
  ]);

  /*await FlameAudio.audioCache.loadAll(<String>[
    *//*'sfx/beeep.mp3',
    'sfx/plop.mp3',
    'sfx/bing.mp3',
    'sfx/vgdeathsound.mp3',*//*
    'bgm/KL Peach Game Over 2.mp3'
  ]);*/



  ArkanoidGame game = ArkanoidGame();

  //sleep(Duration(seconds: 2));
  runApp(
      GameWidget(
        game: game,
      )
  );
}
