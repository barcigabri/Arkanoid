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

class Bonus extends SpriteAnimationComponent with HasHitboxes, Collidable {
  final ArkanoidGame game;
  late Sprite bgSprite;
  double speed = 60;
  //late Rect blockRect;
  late HitboxRectangle shape;
  late Vector2 velocity;
  late BonusType type;
  final Sprite shadow = Sprite(Flame.images.fromCache('shadows/bonus.png'));
  late Vector2 pausedVelocity = Vector2.zero();


  Bonus(this.game, Vector2 pos) : super (
      position: Vector2(pos.x + game.tileSize.x/5,pos.y),
      size: game.tileSize*4/5,
      anchor:Anchor.center,
      priority: 2,
      paint: Paint()..color = Colors.white
  ) {
    double moltiplicatore = speed / 353.53846153846155;
    speed = game.playScreenSize.y * moltiplicatore;

    // aggiungo le hitbox
    shape = HitboxRectangle();
    addHitbox(shape);
    debugColor = Color(0xFFFFFF00);
    velocity = Vector2(0,1)..scaleTo(speed);

    /*
    Set<BonusType> available = BonusType.values.toSet();
    available.removeAll(game.bonusOnScreen);
    available.remove(BonusType.normal);
    do { // scelgo il tipo di bonus
    type = BonusType.values.elementAt(game.rnd.nextInt(available.length));
    } while (type == BonusType.player && game.rnd.nextDouble() > 0.6); // Ho solo il 60% di possibilità di guadagnare una vita quando esce il bonus corrispondente
    */
    do { // scelgo il tipo di bonus
      type = BonusType.values.elementAt(game.rnd.nextInt(BonusType.values.length - 1));
    } while (game.bonusOnScreen.contains(type) || type == game.activeType || (type == BonusType.player && game.rnd.nextDouble() > 0.6)); // Ho solo il 60% di possibilità di guadagnare una vita quando esce il bonus corrispondente

    game.bonusOnScreen.add(type);
    assignSprite();
  }

  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    // Capire perchè non aggiunge più
    if (other is Paddle) {
      game.bonusOnScreen.remove(type);
      game.remove(this);
      if(type != BonusType.player) {
        if(game.activeType == BonusType.laser) {
          game.paddle.animation = game.paddleSheetLaser.createAnimation(row: 0, loop: false, stepTime: game.animationSpeed).reversed();
          game.paddle.animation?.onComplete = () {
            game.paddle.animation = game.paddleNormalAnimation;
          };
        }
        game.activeType = type;
      }
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
        case BonusType.player:
          game.extraLifePlayer();
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
    canvas.save();
    shadow.renderRect(canvas, size.toRect().translate(game.pixel * 4, game.pixel * 4), overridePaint: game.opacityPaint);
    canvas.restore();
    super.render(canvas);
    //renderHitboxes(canvas);
    //canvas.drawRect(wallRect, boxPaint);
    //bgSprite.renderRect(c, bgRect); // stampa sfondo immagine
  }

  void update (double dt){
    super.update(dt);
    position.add(velocity * dt);
  }

  void movementOnOff(bool movement) {
    if(movement) {
      velocity = pausedVelocity;
    }
    else {
      pausedVelocity = velocity;
      velocity = Vector2.zero();
    }
  }

  void assignSprite() {
    String letter='';
    switch(type) {
      case BonusType.disruption:
        letter ='d';
        animation = game.disruption;
        break;
      case BonusType.expansion:
        letter ='e';
        animation = game.expansion;
        break;
      case BonusType.freezing:
        letter ='f';
        animation = game.freeze;
        break;
      case BonusType.reduction:
        letter ='r';
        animation = game.reduction;
        break;
      case BonusType.mega:
        letter ='m';
        animation = game.mega;
        break;
      case BonusType.laser:
        letter ='l';
        animation = game.lasers;
        break;
      case BonusType.player:
        animation = game.player;
        break;
    }
    //sprite = Sprite(Flame.images.fromCache("powerUp/$letter.png"));
    //print("powerUp/$letter.png");

  }


}