import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/geometry.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';

class Block extends PositionComponent with Hitbox, Collidable {
  final ArkanoidGame game;
  late Sprite bgSprite;
  //late Rect blockRect;
  late HitboxRectangle shape;
  late Vector2 p, s;
  Vector2 idPosizione;
  bool invalida = false;

  Block(this.game, Vector2 pos, this.idPosizione) : super (
      position: pos,
      size: game.tileSize
  ) {
    //bgSprite = Sprite(Flame.images.fromCache('immagine che non ho ancora'));
    collidableType = CollidableType.passive;
    // aggiungo le hitbox
    shape = HitboxRectangle();
    addHitbox(shape);
    p=pos;
    debugColor = Color(0xFFFF0000);
    //print('elemento creato in posizione $p');
    /*print(s.x);
    print(s.y);*/
    //non capisco bene perché non funziona, secondo me è sbagliata come è formulata la fromLTWH
    // wallRect = Rect.fromLTWH(p.x, p.y, s.x, s.y);
    // print(wallRect);
    //blockRect=Rect.fromLTRB(p.x, p.y, game.size.x-s.x-p.x, game.size.y-s.y-p.y);
    // print(wallRect);

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


}