import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/game_components/ball.dart';
import 'package:arkanoid/game_components/block.dart';
import 'package:arkanoid/game_components/background.dart';
import 'package:flame/game.dart';

abstract class Level {
  final ArkanoidGame game;
  final int bgId;

  Level(this.game, this.bgId){

    //risolvere problemi inizializzazione paddle

  }

  /// Fills the levelPosition list with the top-left position of
  /// each block in the level
  void generateLevelPositions();

  /// Create the level automatically
  void create() {
    game.levelPosition = <Vector3>[];
    game.blocks = <Block>[];
    game.balls = <Ball>[];
    game.bg = Background(game, game.spriteSheetBg.getSpriteById(bgId));
    game.add(game.bg);
    game.showLives();
    game.paddleCreateNormalAnimation.reset();
    game.createPaddle();
    game.resetBonus();
    game.paddle.restorePosition();
    game.balls.add(Ball(game, true));
    game.add(game.balls.first);
    generateLevelPositions();
    addBlocks();
  }



  /// internal function
  void addInPosition(double x, double y, double type) {
    game.levelPosition.add(Vector3(game.playScreenPosition.x + game.tileSize.x * x, game.playScreenPosition.y + game.tileSize.y * y, type));
  }

  /// It must be called in generateLevelPositions() to work. Adds
  /// automatically the blocks to the components list and to the
  /// blocks list
  void addBlocks() {
    game.levelPosition.forEach((blockPosition) {
      Block single = Block(game, blockPosition.xy, getLogicalPosition(blockPosition.x,blockPosition.y), blockPosition.z.toInt());
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