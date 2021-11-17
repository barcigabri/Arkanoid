import 'dart:ui';
import 'package:arkanoid/bonus_type.dart';
import 'package:arkanoid/game_components/bottom_hole.dart';
import 'package:arkanoid/game_components/paddle.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/geometry.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';

class Bonus extends SpriteComponent with HasHitboxes, Collidable {
  final ArkanoidGame game;
  late Sprite bgSprite;
  double speed = 60;
  //late Rect blockRect;
  late HitboxRectangle shape;
  late Vector2 velocity;
  late BonusType type;


  Bonus(this.game, Vector2 pos) : super (
      position: Vector2(pos.x + game.tileSize.x/5,pos.y),
      size: game.tileSize*3/5,
      anchor:Anchor.center,
  ) {
    double moltiplicatore = speed / 353.53846153846155;
    speed = game.playScreenSize.y * moltiplicatore;

    // aggiungo le hitbox
    shape = HitboxRectangle();
    addHitbox(shape);
    debugColor = Color(0xFFFFFF00);
    velocity = Vector2(0,1)..scaleTo(speed);

    //print(game.bonusOnScreen);


    do { // scelgo il tipo di bonus
      type = BonusType.values.elementAt(game.rnd.nextInt(BonusType.values.length - 1));
    } while (game.bonusOnScreen.contains(type) || type == game.activeType);
    game.bonusOnScreen.add(type);
    assignSprite();
  }

  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    //capire perchè non aggiunge più
    if (other is Paddle) {
      game.bonusOnScreen.remove(type);
      game.remove(this);
      game.activeType = type;
      switch(type) {
        case BonusType.disruption:
          game.multiplyBall();
          break;
        case BonusType.expansion:
          game.expandPaddle();
          break;
        case BonusType.freezing:
          game.freezeBall();
          break;
        case BonusType.reduction:
          game.reducePaddle();
          break;
        case BonusType.mega:
          game.megaBall();
          break;
        case BonusType.laser:
          game.laser();
          break;
      }

    }
    else if(other is BottomHole)
    {
      game.bonusOnScreen.remove(type);
      game.remove(this);
    }
  }

  void render(Canvas canvas) {
    Paint boxPaint = Paint();
    boxPaint.color = Color(0xFFFFFF00);

    super.render(canvas);
    renderHitboxes(canvas);
    //canvas.drawRect(wallRect, boxPaint);
    //bgSprite.renderRect(c, bgRect); // stampa sfondo immagine
  }

  void update (double dt){
    super.update(dt);
    position.add(velocity * dt);
  }

  void assignSprite() {
    String letter='';
    switch(type) {
      case BonusType.disruption:
        letter ='d';
        break;
      case BonusType.expansion:
        letter ='e';
        break;
      case BonusType.freezing:
        letter ='f';
        break;
      case BonusType.reduction:
        letter ='r';
        break;
      case BonusType.mega:
        letter ='m';
        break;
      case BonusType.laser:
        letter ='l';
        break;
    }
    sprite = Sprite(Flame.images.fromCache("powerUp/$letter.png"));
    //print("powerUp/$letter.png");

  }


}