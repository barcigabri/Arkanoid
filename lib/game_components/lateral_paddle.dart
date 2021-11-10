import 'dart:ui';
import 'package:arkanoid/game_components/ball.dart';
import 'package:arkanoid/game_components/paddle.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/geometry.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';

class LateralPaddle extends PositionComponent with Hitbox, Collidable {
  final ArkanoidGame game;
  late Sprite bgSprite;
  late Rect wallRect;
  late HitboxRectangle shape;
  final Paddle paddle;
  final int LoR; //indica se è il confine di destra (1) o di sinistra (0)
  LateralPaddle(this.game, this.paddle, this.LoR) : super (
    position: Vector2(paddle.position.x/2-paddle.size.x/2+LoR*paddle.size.x-LoR*1,paddle.position.y+3),
    size: Vector2(1,game.tileSize.y*2/3),
  ) {
    //print(game.screen.x/2+LoR*paddle.size.x/2);
    collidableType = CollidableType.passive;
    //bgSprite = Sprite(Flame.images.fromCache('immagine che non ho ancora'));

    // aggiungo le hitbox
    shape = HitboxRectangle();
    addHitbox(shape);


  }

  void ballCollision(Ball ball, Set<Vector2> points) {
    if (!ball.lock && !ball.strongLock) {
      ball.lock = true;
      ball.strongLock = true;

      if(ball.velocity.x>0) {
        ball.position.x-=2;
      }
      else {
        ball.position.x+=2;
      }
      if (ball.velocity.y < 0) ball.velocity.y = -ball.velocity.y;
      ball.velocity = Vector2(-ball.velocity.x, ball.velocity.y);
    }
  }

  void render(Canvas canvas) {
    Paint boxPaint = Paint();
    boxPaint.color = Color(0xFFFF0000);
    /*canvas.drawLine(Offset(0,0), Offset(game.screen.x,game.screen.y), boxPaint);*/
    debugColor = Colors.white;
    super.render(canvas);
    renderHitboxes(canvas, paint:boxPaint);
    //canvas.drawRect(wallRect, boxPaint);

    //print(wallRect);
    //bgSprite.renderRect(c, bgRect); // stampa sfondo immagine

    //canvas.drawRect(Rect.fromLTWH(348.2, 0.0, game.screen.x/6, game.screen.y),boxPaint);
    //print(Rect.fromLTWH(348.2, 0.0, game.screen.x/6, game.screen.y));
    //print('348.2:${p.x} 0.0:${p.y} ${game.screen.x/6}:${s.x} ${game.screen.y}:${s.y}');
    //Rect.fromLTRB(p.x, p.y, game.size.x-s.x-p.x, game.size.y-s.y-p.y)
  }

  void update(double t) {
    super.update(t);
    if(paddle.xPaddle < paddle.position.x-paddle.size.x/2 && paddle.xPaddle > paddle.position.x+paddle.size.x/2) {
      position.x = paddle.xPaddle-paddle.size.x/2+LoR*paddle.size.x-LoR*1;
    }
    else {
      position.x = paddle.position.x-paddle.size.x/2+LoR*paddle.size.x-LoR*1;
    }
  }
}