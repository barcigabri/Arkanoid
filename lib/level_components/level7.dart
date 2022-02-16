import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/level_components/level.dart';

class Level7 extends Level{

  Level7(ArkanoidGame game):super(game, 6);

  @override
  void generateLevelPositions() {
    for (double y = 3; y < 18; y+=2) {
      /*for (double x = 0; x < y; x++){
        if(y == 13 && x != 12) {
          addInPosition(x, y, 2);
        }
        else {
          addInPosition(x, y, 1);
        }
      }
      */
      if(y != 5 && y != 13) {
        for (double x = 0; x < 13; x++){
          addInPosition(x, y, 1);
        }
      }
      if(y == 5) {
        for (double x = 0; x < 13; x++){
          if(x < 3) {
            addInPosition(x, y, 1);
          }
          else {
            addInPosition(x, y, 4);
          }
        }
      }
      if(y == 13) {
        for (double x = 0; x < 13; x++){
          if(x > 9) {
            addInPosition(x, y, 1);
          }
          else {
            addInPosition(x, y, 4);
          }
        }
      }

    }
  }
}