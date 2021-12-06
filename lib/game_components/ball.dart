import 'dart:math';
import 'dart:ui';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/game_components/block.dart' as b;
import 'package:arkanoid/game_components/bottom_hole.dart';
import 'package:arkanoid/game_components/ceiling.dart';
import 'package:arkanoid/game_components/lateral_paddle.dart';
import 'package:arkanoid/game_components/paddle.dart';
import 'package:arkanoid/game_components/wall.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class Ball extends PositionComponent with HasHitboxes, Collidable {
  final ArkanoidGame game;
  late HitboxCircle shape;
  late Vector2 velocity;
  late double speed;
  bool lock = false;
  bool strongLock = false;
  Vector2 previousBlock  = Vector2.zero();
  bool freeze; // blocco sul paddle
  bool freezeBonus = false; // se attivo freeze al contatto con il paddle
  bool megaBonus = false; // se la pallina attraversa i blocchi
  late double difference;
  double angle;
  late Collidable lastCollision;




  double max = 0;

  /// game è per avere un riferimento alla partita in corso,
  /// freeze indica se la pallina parte da ferma (false) o in movimento (true),
  /// angle indica l'angolo nel caso in cui la pallina parte in movimento
  Ball(this.game, this.freeze, {this.angle = 45}) : super(
    //position: game.screen/2,
    //position: Vector2(game.screen.x/2, game.playScreenPosition.y+game.tileSize.y * 8 + 7),
    position: Vector2(game.paddle.position.x,game.paddle.position.y-game.tileSize.x/6),
    size: Vector2.all(game.tileSize.x/3),
    anchor: Anchor.center,
  ) {

    speed = 150 + game.selectorDifficulty.difficulty * 50;
    print(speed);

    double moltiplicatore = speed / 353.53846153846155;
    speed = game.playScreenSize.y * moltiplicatore;
    addHitbox(HitboxCircle());
    //print('ball: ${shape.position}');
    //debugMode=true; //modalità debug

    // Ogni volta che viene effettuato un freeze è necessario aggiornare difference per sapere di quanto spostare la pallina
    difference = game.paddle.xPaddle-position.x;
    velocity = Vector2.zero();
    if(!freeze) { // se la pallina è creata con freeze = false sono palline create dal bonus disruption
      if(angle % 180 == 0) {
        angle += 45;
      }
      velocity = angleToDirection(angle);
      position = game.balls.first.position;
    }

  }


  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    // Bisogna usare tutta una serie di if in modo che other sia di una classe ben definita
    lastCollision = other;
    if (other is Wall) {
      other.ballCollision(this, points);
    }
    else if (other is LateralPaddle) {
      other.ballCollision(this, points);
    }
    else if (other is Paddle) {
      other.ballCollision(this, points);
    }
    else if (other is Ceiling) {
      other.ballCollision(this, points);
    }
    else if (other is BottomHole) {
      other.ballCollision(this, points);
    }
    else if (other is b.Block) {
      other.ballCollision(this, points);
    }
  }






  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Paint a = Paint();
    a.color = Color(0xFF00FF00);
    renderHitboxes(canvas,paint: a);
    //canvas.drawCircle(position.toOffset(), size.x/2, a);

  }

  @override
  void update(double dt) {
    super.update(dt);
    if(freeze) {
      position.x = game.paddle.xPaddle - difference;
      position.y = game.paddle.position.y-size.x/2;
    }

    //Prova per non far scomparire la pallina
    if(dt > 0.07) {
      dt = 0;
    }
    double scaleMultiplier = 1;

    if (velocity.x.abs() * dt > game.tileSize.x / 3 - 1) scaleMultiplier = (game.tileSize.x / 3 - 1) / (velocity.x.abs() * dt);
    if (velocity.y.abs() * dt > game.tileSize.x / 3 - 1) scaleMultiplier = (game.tileSize.x / 3 - 1) / (velocity.y.abs() * dt);
    position.add((velocity * dt).scaled(scaleMultiplier));

    if(position.x < game.playScreenPosition.x) {
      position.x = game.playScreenPosition.x + size.x / 2;
      velocity.x = -velocity.x;
    }
    if(position.x > game.playScreenPosition.x + game.playScreenSize.x) {
      position.x = game.playScreenPosition.x + game.playScreenSize.x - size.x / 2;
      velocity.x = -velocity.x;
    }
    if(position.y < game.playScreenPosition.y) {
      position.y = game.playScreenPosition.y + size.y / 2;
      velocity.y = velocity.y.abs();
    }
  }

  void ballRotation(double xPoint){ // angle in degrees
    double angle;
    if (xPoint - game.paddle.xPaddle >= -game.paddle.size.x / 6 &&
        xPoint - game.paddle.xPaddle <= game.paddle.size.x / 6) {
      angle = 70;
      // print(1);
    }
    else if (xPoint - game.paddle.xPaddle >= -game.paddle.size.x * 2 / 6 &&
        xPoint - game.paddle.xPaddle < -game.paddle.size.x * 1 / 6 ||
        xPoint - game.paddle.xPaddle > game.paddle.size.x * 1 / 6 &&
            xPoint - game.paddle.xPaddle <= game.paddle.size.x * 2 / 6) {
      angle = 50;
      // print(2);
    }
    else {
      angle = 30;
      // print(3);
    }

    //print(game.paddle.xPaddle);
    //print(xPoint);
    if (game.paddle.xPaddle <= xPoint) {
      velocity = angleToDirection(angle);
    }
    else {
      velocity = angleToDirection(angle);
      velocity.x = - velocity.x;

    }
  }

  Vector2 angleToDirection(double ang){
    double x; // angle in game logic
    double y;
    x = cos(ang*pi/180);
    y = sin(ang*pi/180);

    // per ora non gestisco gli angoli
/*
    if(angle<0) {
      angle += 360;
    }
    angle = ang % 360;*/

    return Vector2(x, -y)..scaleTo(speed);
  }

  void movementOnOff(bool movement) {
    if(movement) {
      ballRotation(game.paddle.xPaddle - difference);
    }
    else {
      velocity = Vector2.zero();
    }
  }

  void onTapUp(TapUpInfo info) {
    if(game.lockOnTapUp){ // controllo per non fare doppio onTapUp simultaneo, lo avvio in EyeButton e nextLevelButton
      game.lockOnTapUp = false;
    }
    else {
      if (!freeze) game.paddle.xPaddle = info.eventPosition.game.x;
      if (freeze) { // Se la pallina è sul paddle la lancio e inizio il gioco
        freeze = false;
        movementOnOff(true);
      }
    }
  }
}
