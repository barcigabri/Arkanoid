import 'dart:ui';
import 'package:arkanoid/game_components/block.dart' as b;
import 'package:arkanoid/game_components/ceiling.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';

class Laser extends SpriteComponent with HasHitboxes, Collidable {
  final ArkanoidGame game;
  late Sprite bgSprite;
  double speed = 375;
  //late Rect blockRect;
  late HitboxRectangle shape;
  late Vector2 velocity;
  bool isLeft;


  Laser(this.game,this.isLeft) : super (
    position: game.paddle.position,
    size: Vector2(game.tileSize.y*4/15,game.tileSize.y*4/5),
    anchor: Anchor.center,
    sprite: Sprite(Flame.images.fromCache('components/laser.png'))
  ) {
    double moltiplicatore = speed / 353.53846153846155;
    speed = game.playScreenSize.y * moltiplicatore;

    if(isLeft) {
      position.x -= game.paddle.size.x / 2;
    }
    else {
      position.x += game.paddle.size.x / 2;
      scale.x = -1;
    }

    // aggiungo le hitbox
    shape = HitboxRectangle();
    addHitbox(shape);
    position.add(Vector2.all(game.tileSize.y*4/45));
    size.add(Vector2.all(game.tileSize.y*2/15));
    debugColor = Color(0xFFFFFF00);
    velocity = Vector2(0,-1)..scaleTo(speed);

  }

  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    //capire perchè non aggiunge più
    if (other is b.Block) {
      other.collisionEndProcedure();
      game.remove(this);
    }
    else if(other is Ceiling)
    {
      game.remove(this);
    }
  }

  void render(Canvas canvas) {
    Paint boxPaint = Paint();
    boxPaint.color = Color(0xFFFFFF00);

    super.render(canvas);
    //renderHitboxes(canvas);
    //canvas.drawRect(wallRect, boxPaint);
    //bgSprite.renderRect(c, bgRect); // stampa sfondo immagine
  }

  void update (double dt){
    super.update(dt);
    position.add(velocity * dt);
  }



}