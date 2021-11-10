import 'dart:math';
import 'dart:ui';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/bonus_type.dart';
import 'package:arkanoid/game_components/block.dart' as b;
import 'package:arkanoid/game_components/bonus.dart';
import 'package:arkanoid/game_components/bottom_hole.dart';
import 'package:arkanoid/game_components/ceiling.dart';
import 'package:arkanoid/game_components/lateral_paddle.dart';
import 'package:arkanoid/game_components/paddle.dart';
import 'package:arkanoid/game_components/wall.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class Ball extends PositionComponent with Hitbox, Collidable {
  final ArkanoidGame game;
  late HitboxCircle shape;
  late Vector2 velocity;
  double speed = 200;
  bool lock = false;
  bool strongLock = false;
  Vector2 previousBlock  = Vector2.zero();
  bool freeze; // blocco sul paddle
  bool freezeBonus = false; // se attivo freeze al contatto con il paddle
  bool megaBonus = false; // se la pallina attraversa i blocchi
  late double difference;
  double angle;


  final double bonusPerc = 0.15;

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
    //velocity = Vector2(0, game.size.y)..scaleTo(speed);

  }


  @override
  void onCollision(Set<Vector2> points, Collidable other) {
    // Bisogna usare tutta una serie di if in modo che other sia di una classe ben definita
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

  void addBonus() {
    // Calcolo per il rilascio dei bonus (15%)
    double release;
    release = game.rnd.nextDouble();
    if (release <= bonusPerc) {
      // Controllo tutta la casistica per valutare se creare un bonus
      if (!((game.activeType == BonusType.normal && game.bonusOnScreen.length == BonusType.values.length - 1) || // bonus attivo normale e sullo schermo c'è un bonus per ogni componente (tutti tranne normale)
          (game.activeType != BonusType.normal && game.bonusOnScreen.length == BonusType.values.length - 2))) { // bonus attivo != normale e sullo schermo c'è un bonus per ogni componente non attivo (tutti tranne normale e quello attivo)
        game.add(Bonus(game, position));
      }
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
    position.add(velocity * dt);
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
      angle = 45;
      // print(2);
    }
    else {
      angle = 20;
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
      //speed = 150;
      ballRotation(game.paddle.xPaddle - difference);
    }
    else {
      velocity = Vector2.zero();
      //speed = 0;
    }
  }

  void onTapDown(TapDownInfo info) {
    if(!freeze) game.paddle.xPaddle = info.eventPosition.game.x;
    if(freeze) { // Se la pallina è sul paddle la lancio e inizio il gioco
      freeze = false;
      movementOnOff(true);
    }
  }
}
