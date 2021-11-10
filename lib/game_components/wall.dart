import 'dart:ui';
import 'package:arkanoid/game_components/ball.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/geometry.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';

class Wall extends PositionComponent with Hitbox, Collidable {
  final ArkanoidGame game;
  late Sprite bgSprite;
  late Rect wallRect;
  late HitboxRectangle shape;
  late Vector2 p, s;

  Wall(this.game, Vector2 pos, Vector2 siz) : super (
    position: pos,
    size: siz
  ) {
    collidableType = CollidableType.passive;
    //bgSprite = Sprite(Flame.images.fromCache('immagine che non ho ancora'));

    // aggiungo le hitbox
    shape = HitboxRectangle();
    addHitbox(shape);
    p=pos;
    s=siz;
    /*print(s.x);
    print(s.y);*/
    //non capisco bene perché non funziona, secondo me è sbagliata come è formulata la fromLTWH
    // wallRect = Rect.fromLTWH(p.x, p.y, s.x, s.y);
    // print(wallRect);
    wallRect=Rect.fromLTRB(p.x, p.y, game.size.x-s.x-p.x, game.size.y-s.y-p.y);
    // print(wallRect);
  }

  void ballCollision(Ball ball, Set<Vector2> points) {
    ball.lock = false;
    ball.previousBlock = Vector2.zero();
    if(!ball.freeze) {
      if (ball.velocity.x > 0) {
        ball.position.x -= 2;
      }
      else {
        ball.position.x += 2;
      }
      ball.velocity = Vector2(-ball.velocity.x, ball.velocity.y);
    }
    else {
      if(position.x < game.screen.x/2) { //controllo se la parete viene prima o dopo la metà per capire se è la sx o la dx
        ball.position.x += 1;
      }
      else {
        ball.position.x -= 1;
      }
    }
  }

  void render(Canvas canvas) {
    Paint boxPaint = Paint();
    boxPaint.color = Color(0xFFFF9800);
    /*canvas.drawLine(Offset(0,0), Offset(game.screen.x,game.screen.y), boxPaint);*/
    debugColor = Colors.orange;
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
  }
}