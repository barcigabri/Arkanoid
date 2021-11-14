import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/level_components/level.dart';

class Level2 extends Level{

  Level2(ArkanoidGame game):super(game);

  @override
  void generateLevelPositions() {
    for (int y = 3; y < 18; y++) {
      switch(y) {
        case 3:
        case 17:
          for (double x = 5; x < 8; x++) {
            addInPosition(x, y.toDouble(),1);
          }
          break;
        case 4:
        case 16:
          for (double x = 4; x < 9; x++) {
            addInPosition(x, y.toDouble(),1);
          }
          break;
        case 5:
        case 15:
        case 6:
        case 14:
          for (double x = 3; x < 10; x++) {
            addInPosition(x, y.toDouble(),1);
          }
          break;
        case 7:
        case 13:
          for (double x = 2; x < 11; x++) {
            addInPosition(x, y.toDouble(),1);
          }
          break;
        case 8:
        case 12:
        case 9:
        case 11:
        case 10:
          for (double x = 1; x < 12; x++) {
            addInPosition(x, y.toDouble(),1);
          }
          break;
      }
    }
  }
}