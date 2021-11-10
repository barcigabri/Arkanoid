
import 'dart:math';
import 'dart:ui';
import 'package:arkanoid/bonus_type.dart';
import 'package:arkanoid/components/bonus.dart';
import 'package:arkanoid/components/bottom_hole.dart';
import 'package:arkanoid/components/lateral_paddle.dart';
import 'package:arkanoid/components/life.dart';
import 'package:arkanoid/components/paddle.dart';
import 'package:arkanoid/components/wall.dart';
import 'package:arkanoid/components/vr.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:arkanoid/components/play_screen.dart';
import 'package:arkanoid/components/ball.dart';
import 'package:arkanoid/components/ceiling.dart';
import 'package:arkanoid/components/block.dart' as b;

class ArkanoidGame extends FlameGame with HasCollidables, TapDetector, HorizontalDragDetector {
  late FixedResolutionViewport view1;
  late Vector2 screen;
  bool init = false;
  late Vr vrLeft, vrRight;
  late List<Ball> balls;
  late Paddle paddle;
  late Vector2 tileSize;
  late List<Vector2> levelPosition;
  late Vector2 playScreenPosition;
  late Vector2 playScreenSize;
  late List<b.Block> blocks;
  late List<BonusType> bonusOnScreen;
  late List<Life> livesList;
  Random rnd = Random();
  BonusType activeType = BonusType.normal;
  bool isActive = false;
  Paint a = Paint()..color = Color(0xFF00FF00);
  int lives = 2;


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
    paddle = Paddle(this);
    add(paddle);
    add(LateralPaddle(this, paddle, 0));
    add(LateralPaddle(this, paddle, 1));

    startGame();
  }

  void startGame() {
    livesList = <Life>[];
    for(int i=0; i<lives; i++) {
      livesList.add(Life(this,i));
      add(livesList.elementAt(i));
    }
    bonusOnScreen = <BonusType>[];
    startLevel();
  }

  void startLevel() {
    levelPosition = <Vector2>[];
    blocks = <b.Block>[];

    generateLevels();
    balls = <Ball>[];
    deactivateBonus();
    paddle.restorePosition();
    balls.add(Ball(this, true));
    add(balls.first);
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

    //wall.render(canvas); // render Background
    //playScreen.render(canvas); // render play Screen
    //ball.render(canvas);
    //bottom.render(canvas);

    //canvas.drawLine(Offset(0,0), Offset(417.8181818181818,392.72727272727275), a);
    //Per ultimo così è sopra a tutto il resto
    if(side == 1) { // L'if è necessario altrimenti la maschera vr non sarebbe simmetrica
      vrLeft.render(canvas); // render VR mask
    }
    else {
      vrRight.render(canvas); // render VR mask
    }
/*

    TextPainter painter;
    TextStyle textStyle;
    painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textStyle = TextStyle(
      color: Color(0xffffffff),
      fontSize: 75,
      shadows: <Shadow>[
        Shadow(
          blurRadius: 7,
          color: Color(0xff4ccd00),
          offset: Offset(3, 3),
        ),
      ],
    );

    painter.text = TextSpan(
      text: balls.first.speed.toString(),
      style: textStyle,
    );
    painter.layout();
    painter.paint(canvas,Offset(screen.x/2,screen.y/2));
*/

  }

  @override
  void onTapDown(TapDownInfo info) {
    balls.first.onTapDown(info);
  }


  @override
  void onHorizontalDragUpdate(DragUpdateInfo info) {
    paddle.xPaddle = info.eventPosition.game.x;

  }

  void generateLevels() {
    double x;
    double y;
    levelPosition = <Vector2>[];
    blocks = <b.Block>[];
    Vector2 position;
    //levelPosition.add(playScreenPosition + Vector2(tileSize.y * 0, tileSize.y * 3));
    for(y = 3; y < 10; y++) {
      for (x = 1; x < 12; x++) {
        if(x == 6) x++;
        levelPosition.add(
            playScreenPosition + Vector2(tileSize.x * x, tileSize.y * y));
        position = playScreenPosition + Vector2(tileSize.x * x, tileSize.y * y);
        b.Block single = b.Block(this, position, Vector2(x+1,y-2));
        blocks.add(single);
        add(single);
        }
      }
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

  void removeBlocks() {
    blocks.forEach((element) {
      remove(element);
    });

  }

  void lostLife() {

    if(livesList.isEmpty) {
      lostGame();
    }
    else {
      remove(livesList.last);
      livesList.removeLast();
      deactivateBonus();
      balls.add(Ball(this,true));
      add(balls.first);
      paddle.xPaddle = screen.x/2; // Quando perde una vita rimetto il paddle al centro
    }
  }

  void lostGame() {
    // Lo metto subito per il debug, ma ci sarà una schermata di game over
    startGame();
  }

}


/*

  @override
  void onGameResize(Vector2 gameSize) {
    screenSize = gameSize;
    print(screenSize.x);

    // controllo se è la prima volta che eseguo onGameResize
    if(!init) {
      init = true;
      initialize();
    }
  }

  // Non posso inserire ridimensionamento nel costruttore perché non ho ancora
  // le dimensioni dello schermo, quindi uso una funzione dopo aver acquisito
  // i dati sulle dimensioni dello schermo
  void initialize() {
    view1 = FixedResolutionViewport(Vector2(screenSize.x/2,screenSize.y));
    camera.viewport = view1;
    screen=camera.viewport.effectiveSize;
    wall = Wall(this);
    vrLeft = Vr(this,1);
    vrRight = Vr(this,2);
    playScreen = PlayScreen(this);
    ball = Ball(this);
    bottom = BottomHole(this);

    //print(cam1.canvasSize);
  }

  @override
  void render(Canvas canvas) {

    Paint a = Paint();
    a.color = Color(0xFF00FF00);



    renderBothScreens(canvas, 1);
    canvas.translate(screen.x,0); //render alla metà destra
    renderBothScreens(canvas, 2);
    canvas.drawLine(Offset(0,0), Offset(0,screenSize.y), a);

    // Scalando il canvas e usandolo doppio può essere un modo intelligente per dover fare un solo render,
    // lo schermo intero è metà schermo, faccio un translate del canvas (shift a destra) e ripeto le
    // stesse identiche operazione senza la necessità di translare tutte le coordinate.
    // Se tengo questo modo devo fare un solo vr.render e devo modificare la classe perché è sufficiente
    // farlo una volta sola

  }

  // Il canvas è adattato su metà schermo, il side è per sapere su quale lato sto operando (utile anche per la penalizzazione)
  void renderBothScreens(Canvas canvas, int side) { //renderizza considerando metà schermo

    wall.render(canvas); // render Background
    playScreen.render(canvas); // render play Screen
    ball.render(canvas);
    bottom.render(canvas);



    //Per ultimo così è sopra a tutto il resto
    if(side == 1) { // L'if è necessario altrimenti la maschera vr non sarebbe simmetrica
      vrLeft.render(canvas); // render VR mask
    }
    else {
      vrRight.render(canvas); // render VR mask
    }

  }

  @override
  void update(double timeDelta) {
  }
*/


