import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/level_components/level.dart';

class Level3 extends Level {

  Level3(ArkanoidGame game) :super(game, 2);

  @override
  void generateLevelPositions() {
    for (double y = 5; y < 19; y++) {
      if (y % 2 == 1) {
        for (double x = 0; x < 13; x++) {
          addInPosition(x, y, 1);
        }
      }
      if (y % 4 == 2) {
        addInPosition(0, y, 4);
        addInPosition(12, y, 4);
      }
    }
  }
}
