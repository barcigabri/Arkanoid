import 'dart:ui';
import 'package:arkanoid/game_components/ball.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';

class Block extends PositionComponent with HasHitboxes, Collidable {
  final ArkanoidGame game;
  late Sprite bgSprite;
  //late Rect blockRect;
  late HitboxRectangle shape;
  Vector2 idPosizione;
  int lives;

  Block(this.game, Vector2 pos, this.idPosizione, this.lives) : super (
      position: pos,
      size: game.tileSize/*-Vector2.all(1)*/ // VALUTARE SE TENERE O MENO, PER ORA TENENDO TRAPASSO I BLOCCHI, MEGLIO DI NO
  ) {
    //bgSprite = Sprite(Flame.images.fromCache('immagine che non ho ancora'));
    collidableType = CollidableType.passive;
    // aggiungo le hitbox
    shape = HitboxRectangle();
    addHitbox(shape);

  }



  void render(Canvas canvas) {
    Paint boxPaint = Paint();
    boxPaint.color = Color(0xFFFF0000);
    //canvas.drawLine(Offset(0,0), Offset(game.screen.x,game.screen.y), boxPaint);

    super.render(canvas);
    renderHitboxes(canvas/*, paint:boxPaint*/);
    //canvas.drawRect(wallRect, boxPaint);

    //print(wallRect);
    //bgSprite.renderRect(c, bgRect); // stampa sfondo immagine

    //canvas.drawRect(Rect.fromLTWH(348.2, 0.0, game.screen.x/6, game.screen.y),boxPaint);
    //print(Rect.fromLTWH(348.2, 0.0, game.screen.x/6, game.screen.y));
    //print('348.2:${p.x} 0.0:${p.y} ${game.screen.x/6}:${s.x} ${game.screen.y}:${s.y}');
    //Rect.fromLTRB(p.x, p.y, game.size.x-s.x-p.x, game.size.y-s.y-p.y)
  }

  @override
  void update(double dt) {
    super.update(dt);
    switch(lives) {
      case 1:
        debugColor = Color(0xFFFF0000);
        break;
      case 2:
        debugColor = Color(0xFFC0C0C0);
        break;
      case 3:
        debugColor = Color(0xFFCD7F32);
        break;
      case 4:
        debugColor = Color(0xFFFFD700);
        break;
    }
  }

  void ballCollision(Ball ball, Set<Vector2> points) {
    ball.lock = false;
    if (!ball.megaBonus) { // se è attivo trapasso i blocchi
      if (!((ball.previousBlock.x == idPosizione.x + 1 && ball.previousBlock.y == idPosizione.y) ||
          (ball.previousBlock.x == idPosizione.x + -1 && ball.previousBlock.y == idPosizione.y) ||
          (ball.previousBlock.x == idPosizione.x && ball.previousBlock.y + 1 == idPosizione.y) ||
          (ball.previousBlock.x == idPosizione.x && ball.previousBlock.y - 1 == idPosizione.y) ||
          (ball.previousBlock.x == idPosizione.x && ball.previousBlock.y == idPosizione.y))) {
        ball.previousBlock = idPosizione;

        // controllo se il blocco fa parte di una parete e quindi va usato il rimbalzo laterale
        bool hasAdjacentVtop = false;
        bool hasAdjacentVbottom = false;


        game.blocks.forEach((block) {
          // print(num.parse((block.position.y + block.size.y).toStringAsFixed(2)));
          // print(num.parse(points.last.y.toStringAsFixed(2)));
          if (block != this) {
            if ((num.parse((block.position.y + game.tileSize.y).toStringAsFixed(2)) == num.parse(points.last.y.toStringAsFixed(2)) ||
                num.parse((block.position.y + game.tileSize.y).toStringAsFixed(2)) == num.parse(points.first.y.toStringAsFixed(2))) &&
                (block.position.x == position.x)) {
              //print('ok');
              hasAdjacentVtop = true;
            }
            if ((num.parse((block.position.y).toStringAsFixed(2)) == num.parse(points.last.y.toStringAsFixed(2)) ||
                num.parse((block.position.y).toStringAsFixed(2)) == num.parse(points.first.y.toStringAsFixed(2))) &&
                (block.position.x == position.x)) {
              //print('ok');
              hasAdjacentVbottom = true;
            }
          }
        });

        // in tutti gli if i controlli sono doppi così controllo tutti i punti di contatto,
        // sia del blocco che della pallina
        if (((num.parse((position.y + game.tileSize.y).toStringAsFixed(2)) == num.parse(points.last.y.toStringAsFixed(2)) ||
            num.parse((position.y + game.tileSize.y).toStringAsFixed(2)) == num.parse(points.first.y.toStringAsFixed(2))) &&
            (ball.velocity.y < 0) && !hasAdjacentVbottom) ||
            ((num.parse((position.y).toStringAsFixed(2)) == num.parse(points.last.y.toStringAsFixed(2)) ||
                num.parse((position.y).toStringAsFixed(2)) == num.parse(points.first.y.toStringAsFixed(2))) &&
                (ball.velocity.y > 0) &&
                !hasAdjacentVtop)) { // colpisco il blocco dall'alto o dal basso
          ball.velocity = Vector2(ball.velocity.x, - ball.velocity.y);
        }
        else if (num.parse((position.x).toStringAsFixed(2)) == num.parse(points.first.x.toStringAsFixed(2)) ||
            num.parse((position.x + size.x).toStringAsFixed(2)) == num.parse(points.first.x.toStringAsFixed(2)) ||
            num.parse((position.x).toStringAsFixed(2)) == num.parse(points.last.x.toStringAsFixed(2)) ||
            num.parse((position.x + size.x).toStringAsFixed(2)) == num.parse(points.last.x.toStringAsFixed(2))) { // colpisco il blocco dal lato destro o sinistro
          ball.velocity = Vector2(-ball.velocity.x, ball.velocity.y);
          //print(3);
        }
        else { //questo else non dovrebbe mai servire, era per il debug, valutare se toglierlo
          ball.velocity = Vector2(ball.velocity.x, -ball.velocity.y);
          //print(4);
          //print('prova');
        }
        collisionEndProcedure();

      }
    }
    else {
      collisionEndProcedure();
    }

  }

  void removeBlock() {
    game.blocks.remove(this);
    game.remove(this);
  }

  void addBonus() {
    game.addBonus(position + game.tileSize/2);
  }

  void collisionEndProcedure() {
   switch(lives) {
     case 1:
     case 3:
       removeBlock();
       // FlameAudio.audioCache.play('sfx/beeep.mp3', mode: PlayerMode.LOW_LATENCY);
       // game.blockSound.start();
       if (game.blocks.isEmpty) {
         game.levelCompleted();
       }
       else {
         addBonus();
       }
       break;
     case 2:
       lives++;
       // FlameAudio.audioCache.play('sfx/bing.mp3', mode: PlayerMode.LOW_LATENCY);
       // game.steelSound.start();
       break;
   }

  }

}