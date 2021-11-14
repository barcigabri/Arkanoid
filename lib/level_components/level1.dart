import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/level_components/level.dart';

class Level1 extends Level{

  Level1(ArkanoidGame game):super(game);

  @override
  void generateLevelPositions() {
    for (double y = 3; y < 11; y++) {
      for (double x = 1; x < 12; x++) {
        if (x == 6) x++;
        addInPosition(x, y, 1);
      }
    }
  }
}