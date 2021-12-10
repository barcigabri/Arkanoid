import 'dart:ui';
import 'package:arkanoid/game_components/ball.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/geometry.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Paddle extends SpriteAnimationComponent with HasHitboxes, Collidable {
  final ArkanoidGame game;
  late Sprite bgSprite;
  late Rect wallRect;
  late HitboxRectangle shape;
  late double xPaddle;
  Vector2 velocity = Vector2.zero();
  double speed = 200;
  final Sprite shadow = Sprite(Flame.images.fromCache('shadows/paddle.png'));
  late Paint opacity;

  Paddle(this.game) : super (
      position: Vector2(game.screen.x/2,(game.screen.y-game.playScreenSize.y)/2+game.playScreenSize.y-game.tileSize.y*2),
      size: Vector2(game.tileSize.x*2,1),
      anchor: Anchor.topCenter,
      animation: game.paddleSheetCreate.createAnimation(row: 0, loop: false, stepTime: game.animationSpeed),
      priority: 1
  ) {
    collidableType = CollidableType.passive;
    //bgSprite = Sprite(Flame.images.fromCache('immagine che non ho ancora'));

    // aggiungo le hitbox
    shape = HitboxRectangle();
    addHitbox(shape);
    size.y = size.x / 4; // sistemare dimensioni!! ( UPDATE: Credo di aver fatto)

    animation?.onComplete = () {
      animation = game.paddleNormalAnimation;
    };
    double moltiplicatore = speed / 353.53846153846155;
    speed = game.playScreenSize.y * moltiplicatore;

    xPaddle = game.screen.x/2;
    opacity = game.opacityPaint;
  }

  void ballCollision(Ball ball, Set<Vector2> points) {
    if (!ball.lock && !ball.strongLock && !ball.freeze) {
      ball.lock = true;
      ball.previousBlock = Vector2.zero();
      ball.ballRotation(points.first.x);

    }
    if(ball.freezeBonus) {
      ball.freeze = true;
      ball.movementOnOff(false);
      ball.difference = xPaddle-ball.position.x;
    }
    game.wallLeft.isLast = false;
    game.wallRight.isLast = false;
    game.ceiling.isLast = false;
  }

  void restorePosition() {
    position = Vector2(game.screen.x/2,(game.screen.y-game.playScreenSize.y)/2+game.playScreenSize.y-game.tileSize.y*2);
  }

  void transparent() {
    opacity = Paint()..color = Colors.white.withOpacity(0);
  }

  void render(Canvas canvas) {
    canvas.save();
    shadow.renderRect(canvas, size.toRect().translate(game.pixel * 4, game.pixel * 4), overridePaint: opacity);
    canvas.restore();
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if(xPaddle <= game.screen.x-game.screen.x/6-size.x/2 && xPaddle >= game.screen.x/6+size.x/2) {
      xPaddle += (velocity.x * dt);
      if(xPaddle > game.screen.x-game.screen.x/6-size.x/2) {
        position.x = game.screen.x-game.screen.x/6-size.x/2;
        xPaddle = position.x;
      }
      if(xPaddle < game.screen.x/6+size.x/2) {
        position.x = game.screen.x/6+size.x/2;
        xPaddle = position.x;
      }
      position.x = xPaddle;
    }
    else if(xPaddle > game.screen.x-game.screen.x/6-size.x/2) {
      position.x = game.screen.x-game.screen.x/6-size.x/2;
      xPaddle = position.x;
    }
    else {
      position.x = game.screen.x/6+size.x/2;
      xPaddle = position.x;
    }
  }

  void keyboardAction(RawKeyEvent event) {
      if (event is RawKeyDownEvent && !game.keys.contains(event.logicalKey)) {
        game.keys.add(event.logicalKey);
        if(event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          velocity = Vector2(-1,0)..scaleTo(speed);
        }
        if(event.logicalKey == LogicalKeyboardKey.arrowRight) {
          velocity = Vector2(1,0)..scaleTo(speed);
        }
      }
      if (event is RawKeyUpEvent) {
        game.keys.remove(event.logicalKey);
        if(event.logicalKey == LogicalKeyboardKey.gameButtonA) {
          game.balls.first.freeze = false;
          game.balls.first.movementOnOff(true);
        }
        if(event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          velocity = Vector2.zero();
        }
        if(event.logicalKey == LogicalKeyboardKey.arrowRight) {
          velocity = Vector2.zero();
        }
      }

  }
}