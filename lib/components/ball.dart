import 'dart:math';
import 'dart:ui';
import 'package:arkanoid/arkanoid_game.dart';
import 'package:arkanoid/bonus_type.dart';
import 'package:arkanoid/components/block.dart' as b;
import 'package:arkanoid/components/bonus.dart';
import 'package:arkanoid/components/bottom_hole.dart';
import 'package:arkanoid/components/ceiling.dart';
import 'package:arkanoid/components/lateral_paddle.dart';
import 'package:arkanoid/components/paddle.dart';
import 'package:arkanoid/components/wall.dart';
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
  double speed = 150;
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
    shape = HitboxCircle();
    shape.position = game.screen/2;
    addHitbox(shape);
    //print('ball: ${shape.position}');

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
    bool lostLife = false;
    //print(velocity);
    //print(points);
    if (other is Wall) {
      lock = false;
      previousBlock = Vector2.zero();
      if(velocity.x>0) {
        position.x-=2;
      }
      else {
        position.x+=2;
      }
      velocity = Vector2(-velocity.x, velocity.y);

    }
    else if (other is LateralPaddle) {

      if (!lock && !strongLock) {
        lock = true;
        strongLock = true;

        if(velocity.x>0) {
          position.x-=2;
        }
        else {
          position.x+=2;
        }
        if (velocity.y < 0) velocity.y = -velocity.y;
        velocity = Vector2(-velocity.x, velocity.y);
      }
    }
    else if (other is Paddle) {  //rimbalza strano quando il paddle è tutto a sinistra o tutto a destra
      if (!lock && !strongLock && !freeze) {
        lock = true;
        previousBlock = Vector2.zero();

        ballRotation(points.first.x);

      }
      if(freezeBonus) {
        freeze = true;
        movementOnOff(false);
        difference = game.paddle.xPaddle-position.x;
      }
    }
    else if (other is Ceiling) {
      lock = false;
      velocity = Vector2(velocity.x, -velocity.y);
      position.y+=2;
      previousBlock = Vector2.zero();
    }
    else if (other is BottomHole) {
      lock = false;
      strongLock = false;
      previousBlock = Vector2.zero();
      print('Ball fell down');
      game.balls.remove(this);
      game.remove(this);
      if (game.balls.isEmpty) {
        game.lostLife();
      }
    }
    else if (other is b.Block) {
      lock = false;
      print (other.invalida);
      if(!other.invalida) {
        if (!megaBonus) { // se è attivo trapasso i blocchi
          if (!((previousBlock.x == other.idPosizione.x + 1 &&
              previousBlock.y == other.idPosizione.y)
              || (previousBlock.x == other.idPosizione.x + -1 &&
                  previousBlock.y == other.idPosizione.y)
              || (previousBlock.x == other.idPosizione.x &&
                  previousBlock.y + 1 == other.idPosizione.y)
              || (previousBlock.x == other.idPosizione.x &&
                  previousBlock.y - 1 == other.idPosizione.y))) {
            previousBlock = other.idPosizione;

            // controllo se il blocco fa parte di una parete e quindi va usato il rimbalzo laterale
            bool hasAdjacentVtop = false;
            bool hasAdjacentVbottom = false;


            game.blocks.forEach((block) {
              // print(num.parse((block.position.y + block.size.y).toStringAsFixed(2)));
              // print(num.parse(points.last.y.toStringAsFixed(2)));
              if (block != other) {
                if ((num.parse(
                    (block.position.y + game.tileSize.y).toStringAsFixed(2)) ==
                    num.parse(points.last.y.toStringAsFixed(2)) ||
                    num.parse(
                        (block.position.y + game.tileSize.y).toStringAsFixed(
                            2)) ==
                        num.parse(points.first.y.toStringAsFixed(2))) &&
                    (block.position.x == other.position.x)) {
                  //print('ok');
                  hasAdjacentVtop = true;
                }
                if ((num.parse((block.position.y).toStringAsFixed(2)) ==
                    num.parse(points.last.y.toStringAsFixed(2)) ||
                    num.parse((block.position.y).toStringAsFixed(2)) ==
                        num.parse(points.first.y.toStringAsFixed(2))) &&
                    (block.position.x == other.position.x)) {
                  //print('ok');
                  hasAdjacentVbottom = true;
                }
              }
            });

            // in tutti gli if i controlli sono doppi così controllo tutti i punti di contatto,
            // sia del blocco che della pallina
            if (((num.parse(
                (other.position.y + game.tileSize.y).toStringAsFixed(2)) ==
                num.parse(points.last.y.toStringAsFixed(2)) ||
                num.parse(
                    (other.position.y + game.tileSize.y).toStringAsFixed(2)) ==
                    num.parse(points.first.y.toStringAsFixed(2))) &&
                (velocity.y < 0) && !hasAdjacentVbottom) ||
                ((num.parse((other.position.y).toStringAsFixed(2)) ==
                    num.parse(points.last.y.toStringAsFixed(2)) ||
                    num.parse((other.position.y).toStringAsFixed(2)) ==
                        num.parse(points.first.y.toStringAsFixed(2))) &&
                    (velocity.y > 0) &&
                    !hasAdjacentVtop)) { // colpisco il blocco dall'alto o dal basso
              velocity = Vector2(velocity.x, -velocity.y);
            }
            else if (num.parse((other.position.x).toStringAsFixed(2)) ==
                num.parse(points.first.x.toStringAsFixed(2)) ||
                num.parse(
                    (other.position.x + other.size.x).toStringAsFixed(2)) ==
                    num.parse(points.first.x.toStringAsFixed(2)) ||
                num.parse((other.position.x).toStringAsFixed(2)) ==
                    num.parse(points.last.x.toStringAsFixed(2)) ||
                num.parse(
                    (other.position.x + other.size.x).toStringAsFixed(2)) ==
                    num.parse(points.last.x.toStringAsFixed(
                        2))) { // colpisco il blocco dal lato destro o sinistro
              velocity = Vector2(-velocity.x, velocity.y);
              //print(3);
            }
            else { //questo else non dovrebbe mai servire, era per il debug, valutare se toglierlo
              velocity = Vector2(velocity.x, -velocity.y);
              //print(4);
              //print('prova');
            }
            print('block ID: ${other.idPosizione}');
            other.invalida = true;
            game.blocks.remove(other);
            game.remove(other);
            addBonus();
          }
        }
        else {
          game.blocks.remove(other);
          game.remove(other);
          addBonus();
        }
      }
      else {
        print('Ritento la rimozione!');
        game.blocks.remove(other);
        game.remove(other);
      }

    }

    /*@override
    void onCollisionEnd(Collidable other) {
      if(other is Block) {

      }
    }*/



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

  }

  @override
  void update(double dt) {
    /*if(dt > max) {
      max = dt;
      print(max);
    }*/

    if(freeze) {
      position.x = game.paddle.xPaddle - difference;
      position.y = game.paddle.position.y-size.x/2;
    }
    //Prova per non far scomparire la pallina
    if(dt > 0.07) {
      dt = 0;
    }
    super.update(dt);
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
