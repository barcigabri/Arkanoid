
import 'dart:math';
import 'dart:ui';
import 'package:arkanoid/bonus_type.dart';
import 'package:arkanoid/game_components/bonus.dart';
import 'package:arkanoid/game_components/bottom_hole.dart';
import 'package:arkanoid/game_components/lateral_paddle.dart';
import 'package:arkanoid/game_components/life.dart';
import 'package:arkanoid/game_components/paddle.dart';
import 'package:arkanoid/game_components/wall.dart';
import 'package:arkanoid/game_components/ball.dart';
import 'package:arkanoid/game_components/ceiling.dart';
import 'package:arkanoid/game_components/block.dart' as b;
import 'package:arkanoid/level_components/level.dart';
import 'package:arkanoid/level_components/level1.dart';
import 'package:arkanoid/level_components/level2.dart';
import 'package:arkanoid/level_components/level3.dart';
import 'package:arkanoid/utilities_components/gesture_invisible_screen.dart';
import 'package:arkanoid/utilities_components/logo.dart';
import 'package:arkanoid/utilities_components/next_level_button.dart';
import 'package:arkanoid/utilities_components/start_button.dart';
import 'package:arkanoid/utilities_components/vr.dart';
import 'package:arkanoid/view.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';


class ArkanoidGame extends FlameGame with HasCollidables, HasTappableComponents, HasDraggableComponents {
  View activeView = View.home;
  late Vector2 screen;
  bool init = false;
  late Vr vrLeft, vrRight;
  late List<Ball> balls;
  late Paddle paddle;
  late LateralPaddle lpl,lpr;
  late Vector2 tileSize;
  late List<Vector3> levelPosition;
  late Vector2 playScreenPosition;
  late Vector2 playScreenSize;
  late List<b.Block> blocks;
  late List<Bonus> bonusList;
  late List<BonusType> bonusOnScreen;
  final double bonusPerc = 0.15;
  late List<Life> livesList;
  late GestureInvisibleScreen gesturesComponent;
  //late Logo logo;
  late StartButton startButton;
  late TextComponent logo;
  late TextBoxComponent levelComplete;
  late NextLevelButton nextLevelButton;
  late Level currentLevel;

  late Offset position;
  int level = 0;

  Random rnd = Random();
  BonusType activeType = BonusType.normal;
  bool isActive = false;
  Paint a = Paint()..color = Color(0xFF00FF00);
  int lives = 2;

  late final List<Level> levels;

  bool lockOnTapUp =false;


  @override
  Future<void> onLoad() async {
    super.onLoad();
    screen=Vector2(size.x/2,size.y);
    tileSize = Vector2((screen.x*2/3)/13,(screen.x/3)/13);
    playScreenSize = Vector2(tileSize.x*13,tileSize.y*33);
    playScreenPosition = Vector2(screen.x/6,(screen.y-playScreenSize.y)/2);

    add(Wall(this,Vector2.all(0),Vector2(screen.x/6,screen.y)));
    add(Ceiling(this,Vector2.all(0),Vector2(screen.x,(screen.y-playScreenSize.y)/2)));
    add(Wall(this,Vector2(screen.x-screen.x/6, 0),Vector2(screen.x/6,screen.y)));
    add(BottomHole(this));
    vrLeft = Vr(this,1);
    vrRight = Vr(this,2);

    // DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
    // DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
    // DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
    // DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
    // level = 2;
    // DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
    // DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
    // DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
    // DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG

    levels = [
      Level1(this),
      Level2(this),
      Level3(this)
    ];

    startHome();

    //startGame();
  }

  TextPaint getPainter(double fSize) {
    TextPaint painter;
    TextStyle textStyle;

    textStyle = TextStyle(
      fontFamily: 'iomanoid',
      fontSize: fSize,
      color: Color(0xff0000ff),
      shadows: const <Shadow>[
        Shadow(
          blurRadius: 7,
          color: Color(0xffff0000),
          offset: Offset(2, 2),
        ),
      ],
    );

    painter = TextPaint(
        style: textStyle,
        textDirection: TextDirection.ltr,

    );

    return painter;
  }

  void startHome() {
    logo = TextComponent("arkanoid",
      position: Vector2(screen.x/2,screen.y/3),
      //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
      anchor: Anchor.center,
      textRenderer: getPainter(70));
    add(logo);
    startButton = StartButton(this);
    add(startButton);
  }

  void removeHome() {
    remove(logo);
    remove(startButton);

  }

  void startGame() {
    gesturesComponent = GestureInvisibleScreen(this);
    add(gesturesComponent);
    bonusList = <Bonus>[];
    livesList = <Life>[];
    for(int i=0; i<lives; i++) {
      livesList.add(Life(this,i));
      add(livesList.elementAt(i));
    }
    bonusOnScreen = <BonusType>[];
    nextLevel();
  }




  @override
  void render(Canvas canvas) {
    super.render(canvas);
    renderBothScreens(canvas, 1);
    canvas.translate(screen.x,0); //render alla metà destra
    super.render(canvas);
    renderBothScreens(canvas, 2);
    canvas.drawLine(Offset(0,0), Offset(0,screen.y), a);

  }

  // Il canvas è adattato su metà schermo, il side è per sapere su quale lato sto operando (utile anche per la penalizzazione)
  void renderBothScreens(Canvas canvas, int side) { //renderizza considerando metà schermo

    // painter.paint(canvas, position);

    //canvas.drawLine(Offset(0,0), Offset(417.8181818181818,392.72727272727275), a);

    //Per ultimo così è sopra a tutto il resto
    if(side == 1) { // L'if è necessario altrimenti la maschera vr non sarebbe simmetrica
      vrLeft.render(canvas); // render VR mask
    }
    else {
      vrRight.render(canvas); // render VR mask
    }

  }



  @override
  void onHorizontalDragUpdate(DragUpdateInfo info) {
    paddle.xPaddle = info.eventPosition.game.x;

  }



  void multiplyBall() {
    deactivateBonus();
    double angle = balls.first.angle; // meglio mettere degli angoli fissi

    balls.add(Ball(this, false, angle: 40));
    add(balls.last);
    balls.add(Ball(this, false, angle: 140));
    add(balls.last);

  }

  void expandPaddle() {
    deactivateBonus();
    paddle.size.x += tileSize.x/2;
  }

  void reducePaddle() {
    deactivateBonus();
    paddle.size.x -= tileSize.x/2;
  }

  void freezeBall() {
    deactivateBonus();

    deleteLowerPositionBalls();
    balls.first.freezeBonus = true;

  }

  void megaBall() {
    deactivateBonus();
    for(int i=0; i<balls.length; i++) {
      balls.elementAt(i).megaBonus = true;
    }
  }

  void deleteLowerPositionBalls() {
    double min = screen.y;
    int index=0;
    for(int i=0; i<balls.length; i++) {
      if(balls.elementAt(i).position.y < min) {
        min = balls.elementAt(i).position.y;
        index = i;
      }
    }
    for(int i=balls.length-1; i>=0; i--) {
      if(i != index) {
        remove(balls.elementAt(i));
        balls.removeAt(i);
      }
    }
  }

  void deactivateBonus() {
    paddle.size.x = tileSize.x*2; // disattivo expansion e reduction
    if (balls.isNotEmpty) {
      balls.first.freezeBonus = false; // disattivo il bonus nella pallina
      for(int i=0; i<balls.length; i++) {
        balls.elementAt(i).megaBonus = false;
      }
      if(balls.first.freeze) {
        balls.first.freeze = false; // disattivo il freeze
        balls.first.movementOnOff(true); // attivo il movimento
      }
    }
  }

  void addBonus(Vector2 pos) {
    // Calcolo per il rilascio dei bonus (15%)
    double release;
    release = rnd.nextDouble();
    if (release <= bonusPerc) {
      // Controllo tutta la casistica per valutare se creare un bonus
      if (!((activeType == BonusType.normal && bonusOnScreen.length == BonusType.values.length - 1) || // bonus attivo normale e sullo schermo c'è un bonus per ogni componente (tutti tranne normale)
          (activeType != BonusType.normal && bonusOnScreen.length == BonusType.values.length - 2) || // bonus attivo != normale e sullo schermo c'è un bonus per ogni componente non attivo (tutti tranne normale e quello attivo)
          bonusOnScreen.length > 1)) { // Non permetto più di due bonus sullo schermo
        bonusList.add(Bonus(this, pos));
        add(bonusList.last);
      }
    }
  }

  void lostLife() {
    paddle.xPaddle = screen.x/2; // Quando perde una vita rimetto il paddle al centro
    paddle.position.x = paddle.xPaddle;
    removeBonuses();
    if(livesList.isEmpty) {
      lostGame();
    }
    else {
      remove(livesList.last);
      livesList.removeLast();
      deactivateBonus();
      balls.add(Ball(this,true));
      add(balls.first);
    }
  }

  void lostGame() {
    // Lo metto subito per il debug, ma ci sarà una schermata di game over
    removeBlocks();
    removeComponents();
    remove(gesturesComponent);
    startHome();
  }

  void removeBlocks() {
    removeAll(blocks);
  }

  void removeComponents() {
    removePaddle();
    removeBalls();
    removeBonuses();
  }

  void removePaddle() {
    remove(paddle);
    remove(lpl);
    remove(lpr);
  }

  void removeBalls() {
    removeAll(balls);
    balls.removeRange(0, balls.length);
  }

  void removeBonuses() {
    removeAll(bonusList);
    bonusList = <Bonus>[];
    bonusOnScreen = <BonusType>[];
  }

  void levelCompleted() {
    removeComponents();

    levelComplete = TextBoxComponent(
      "level completed",
      textRenderer: getPainter(60), position: Vector2(screen.x/2,screen.y/3),
      boxConfig: TextBoxConfig(
        maxWidth: playScreenSize.x*9/10,
        timePerChar: 0.2,
      ),
      anchor: Anchor.center,
    );
    add(levelComplete);
    nextLevelButton = NextLevelButton(this);
    add(nextLevelButton);
  }

  void removeLevel() {

    remove(levelComplete);
    remove(nextLevelButton);
  }

  void nextLevel() {
    currentLevel = levels.elementAt(level);
    currentLevel.create();
  }
}



