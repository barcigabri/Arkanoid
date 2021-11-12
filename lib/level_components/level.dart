import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/game_components/ball.dart';
import 'package:arkanoid/game_components/block.dart';
import 'package:arkanoid/game_components/lateral_paddle.dart';
import 'package:arkanoid/game_components/paddle.dart';
import 'package:flame/game.dart';

abstract class Level {
  final ArkanoidGame game;

  Level(this.game){

    //risolvere problemi inizializzazione paddle

  }

  /// Fills the levelPosition list with the top-left position of
  /// each block in the level
  void generateLevelPositions();

  /// Create the level automatically
  void create() {
    game.levelPosition = <Vector2>[];
    game.blocks = <Block>[];
    game.balls = <Ball>[];
    game.paddle = Paddle(game);
    game.add(game.paddle);
    game.lpl = LateralPaddle(game, game.paddle, 0);
    game.add(game.lpl);
    game.lpr = LateralPaddle(game, game.paddle, 1);
    game.add(game.lpr);
    game.deactivateBonus();
    game.paddle.restorePosition();
    game.balls.add(Ball(game, true));
    game.add(game.balls.first);
    generateLevelPositions();
    addBlocks();
  }

  /// internal function
  void addInPosition(double x, double y) {
    game.levelPosition.add(game.playScreenPosition + Vector2(game.tileSize.x * x, game.tileSize.y * y));
  }

  /// It must be called in generateLevelPositions() to work. Adds
  /// automatically the blocks to the components list and to the
  /// blocks list
  void addBlocks() {
    game.levelPosition.forEach((blockPosition) {
      Block single = Block(game, blockPosition, getLogicalPosition(blockPosition.x,blockPosition.y));
      game.blocks.add(single);
      game.add(single);
    });
  }

  Vector2 getLogicalPosition(double x, double y) {
    x = ((x - game.playScreenPosition.x) / game.tileSize.x).roundToDouble();
    y = ((y - game.playScreenPosition.y) / game.tileSize.y).roundToDouble();
    return Vector2(x,y);
  }

}