import 'dart:ui';
import 'package:arkanoid/game_components/ball.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/geometry.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';

class Block extends SpriteAnimationComponent with HasHitboxes, Collidable {
  final ArkanoidGame game;
  late Sprite bgSprite;

  //late Rect blockRect;
  late HitboxRectangle shape;
  Vector2 idPosizione;
  int lives;
  final Sprite shadow = Sprite(Flame.images.fromCache('shadows/block.png'));
  bool pause = false;

  Block(this.game, Vector2 pos, this.idPosizione, this.lives) : super (
      position: pos,
      size: game.tileSize, /*-Vector2.all(1)*/ // VALUTARE SE TENERE O MENO, PER ORA TENENDO TRAPASSO I BLOCCHI, MEGLIO DI NO
      priority: 1
  ) {
    //bgSprite = Sprite(Flame.images.fromCache('immagine che non ho ancora'));
    collidableType = CollidableType.passive;
    // aggiungo le hitbox
    shape = HitboxRectangle();
    addHitbox(shape);
    //size.sub(Vector2.all(1));

  }


  void render(Canvas canvas) {
    canvas.save();
    shadow.renderRect(canvas, size.toRect().translate(game.pixel * 4, game.pixel * 4), overridePaint: game.opacityPaint);
    canvas.restore();
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch (lives) {
      case 1:
        debugColor = Color(0xFFFF0000);
        int row, column;
        if(idPosizione.x < 4 || idPosizione.x > 7) {
          row = 0;
        }
        else {
          row = 1;
        }
        column = idPosizione.x.toInt() % 4;
        animation = game.spriteSheetBlocks.createAnimation(row: row, loop: false, stepTime: game.animationSpeed, from: column, to: column + 1);
        break;
      case 2:
        debugColor = Color(0xFFC0C0C0);
        animation = game.spriteSheetBlocks.createAnimation(row: 2, loop: false, stepTime: game.animationSpeed, to: 1);
        break;
      case 4:
        debugColor = Color(0xFFCD7F32);
        if(!pause) {
          animation = game.spriteSheetBlocks.createAnimation(row: 3, loop: false, stepTime: game.animationSpeed, to: 1);
        }
        break;
    }
  }

  //
  // DEVO ATTIVARE ANIMAZIONE FERRO
  //
  void ballCollision(Ball ball, Set<Vector2> points) {
    ball.lock = false;
    if (!ball.megaBonus || lives == 4) { // se è attivo trapasso i blocchi
      if (!((ball.previousBlock.x == idPosizione.x + 1 &&
          ball.previousBlock.y == idPosizione.y) ||
          (ball.previousBlock.x == idPosizione.x + -1 &&
              ball.previousBlock.y == idPosizione.y) ||
          (ball.previousBlock.x == idPosizione.x &&
              ball.previousBlock.y + 1 == idPosizione.y) ||
          (ball.previousBlock.x == idPosizione.x &&
              ball.previousBlock.y - 1 == idPosizione.y) ||
          (ball.previousBlock.x == idPosizione.x &&
              ball.previousBlock.y == idPosizione.y))) {


        // controllo se il blocco fa parte di una parete e quindi va usato il rimbalzo laterale
        bool hasAdjacentVtop = false;
        bool hasAdjacentVbottom = false;
        bool hasAdjacentVleft = false;
        bool hasAdjacentVright = false;


        game.blocks.forEach((block) {
          // print(num.parse((block.position.y + block.size.y).toStringAsFixed(2)));
          // print(num.parse(points.last.y.toStringAsFixed(2)));
          if (block != this) {
            if ((num.parse(
                (block.position.y + game.tileSize.y).toStringAsFixed(2)) ==
                num.parse(points.last.y.toStringAsFixed(2)) ||
                num.parse(
                    (block.position.y + game.tileSize.y).toStringAsFixed(2)) ==
                    num.parse(points.first.y.toStringAsFixed(2))) &&
                (block.position.x == position.x)) {
              //print('ok');
              hasAdjacentVtop = true;
            }
            if ((num.parse((block.position.y).toStringAsFixed(2)) ==
                num.parse(points.last.y.toStringAsFixed(2)) ||
                num.parse((block.position.y).toStringAsFixed(2)) ==
                    num.parse(points.first.y.toStringAsFixed(2))) &&
                (block.position.x == position.x)) {
              //print('ok');
              hasAdjacentVbottom = true;
            }
            if ((num.parse(
                (block.position.x + game.tileSize.x).toStringAsFixed(2)) ==
                num.parse(points.last.x.toStringAsFixed(2)) ||
                num.parse(
                    (block.position.x + game.tileSize.x).toStringAsFixed(2)) ==
                    num.parse(points.first.x.toStringAsFixed(2))) &&
                (block.position.y == position.y)) {
              //print('ok');
              hasAdjacentVleft = true;
            }
            if ((num.parse((block.position.x).toStringAsFixed(2)) ==
                num.parse(points.last.x.toStringAsFixed(2)) ||
                num.parse((block.position.x).toStringAsFixed(2)) ==
                    num.parse(points.first.x.toStringAsFixed(2))) &&
                (block.position.y == position.y)) {
              //print('ok');
              hasAdjacentVright = true;
            }
          }
        });

        // in tutti gli if i controlli sono doppi così controllo tutti i punti di contatto,
        // sia del blocco che della pallina
        if (((num.parse((position.y + game.tileSize.y).toStringAsFixed(2)) ==
            num.parse(points.last.y.toStringAsFixed(2)) ||
            num.parse((position.y + game.tileSize.y).toStringAsFixed(2)) ==
                num.parse(points.first.y.toStringAsFixed(2))) &&
            (ball.velocity.y < 0) && !hasAdjacentVbottom) ||
            ((num.parse((position.y).toStringAsFixed(2)) ==
                num.parse(points.last.y.toStringAsFixed(2)) ||
                num.parse((position.y).toStringAsFixed(2)) ==
                    num.parse(points.first.y.toStringAsFixed(2))) &&
                (ball.velocity.y > 0) &&
                !hasAdjacentVtop)) { // colpisco il blocco dall'alto o dal basso
          ball.velocity = Vector2(ball.velocity.x, -ball.velocity.y);
          ball.previousBlock = idPosizione;
        }
        else if (num.parse((position.x).toStringAsFixed(2)) ==
            num.parse(points.first.x.toStringAsFixed(2)) &&
                (!hasAdjacentVleft) ||
            num.parse((position.x + size.x).toStringAsFixed(2)) ==
                num.parse(points.first.x.toStringAsFixed(2)) &&
                (!hasAdjacentVright) ||
            num.parse((position.x).toStringAsFixed(2)) ==
                num.parse(points.last.x.toStringAsFixed(2)) &&
                (!hasAdjacentVleft) ||
            num.parse((position.x + size.x).toStringAsFixed(2)) ==
                num.parse(points.last.x.toStringAsFixed(2)) &&
                (!hasAdjacentVright)) { // colpisco il blocco dal lato destro o sinistro
          ball.velocity = Vector2(-ball.velocity.x, ball.velocity.y);
          ball.previousBlock = idPosizione;
          //print(3);
        }
        /*else { //questo else non dovrebbe mai servire, era per il debug, valutare se toglierlo
          ball.velocity = Vector2(ball.velocity.x, -ball.velocity.y);
          //print(4);
          //print('prova');
        }*/
        collisionEndProcedure();
      }
    }
    else {
      collisionEndProcedure();
    }
    game.wallLeft.isLast = false;
    game.wallRight.isLast = false;
    game.ceiling.isLast = false;
  }

  void removeBlock() {
    game.blocks.remove(this);
    game.remove(this);
  }

  void addBonus() {
    game.addBonus(position + game.tileSize / 2);
  }

  void collisionEndProcedure() {
    switch (lives) {
      case 1:
      case 3:
        removeBlock();
        // FlameAudio.audioCache.play('sfx/beeep.mp3', mode: PlayerMode.LOW_LATENCY);
        // game.blockSound.seek(Duration());
        // game.blockSound.play();
        Set remaining;
        remaining = game.blocks.toSet();
        remaining.removeWhere((element) => element is Block && element.lives == 4);
        if (remaining.isEmpty) {
          game.levelCompleted();
        }
        else {
          addBonus();
        }
        break;
      case 2:
        animation = game.spriteSheetBlocks.createAnimation(row: 2, loop: false, stepTime: game.animationSpeed / 1.5);
        animation?.onComplete = () {
          animation = game.spriteSheetBlocks.createAnimation(row: 2, loop: false, stepTime: game.animationSpeed, to: 1);
        };
        lives++;
        // FlameAudio.audioCache.play('sfx/bing.mp3', mode: PlayerMode.LOW_LATENCY);
        // game.steelSound.seek(Duration());
        // game.steelSound.play();
        break;
      case 4:
        animation = game.spriteSheetBlocks.createAnimation(row: 3, loop: false, stepTime: game.animationSpeed / 1.5);
        pause = true;
        animation?.onComplete = () {
          pause = false;
        };
        break;
    }
  }

}