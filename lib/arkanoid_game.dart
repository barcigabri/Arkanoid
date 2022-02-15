
import 'dart:math';
import 'package:arkanoid/bonus_type.dart';
import 'package:arkanoid/game_components/bonus.dart';
import 'package:arkanoid/game_components/bottom_hole.dart';
import 'package:arkanoid/game_components/frame.dart';
import 'package:arkanoid/game_components/laser.dart';
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
import 'package:arkanoid/level_components/level4.dart';
import 'package:arkanoid/level_components/level3.dart';
import 'package:arkanoid/level_components/level7.dart';
import 'package:arkanoid/level_components/level5.dart';
import 'package:arkanoid/level_components/level6.dart';
import 'package:arkanoid/game_components/background.dart';
import 'package:arkanoid/utilities_components/back_button.dart';
import 'package:arkanoid/utilities_components/endgame_button.dart';
import 'package:arkanoid/utilities_components/eye_button.dart';
import 'package:arkanoid/utilities_components/gesture_invisible_screen.dart';
import 'package:arkanoid/utilities_components/home_button.dart';
import 'package:arkanoid/utilities_components/next_level_button.dart';
import 'package:arkanoid/utilities_components/no_penalization_button.dart';
import 'package:arkanoid/utilities_components/pause_button.dart';
import 'package:arkanoid/utilities_components/pause_screen.dart';
import 'package:arkanoid/utilities_components/play_button.dart';
import 'package:arkanoid/utilities_components/resume_button.dart';
import 'package:arkanoid/utilities_components/selector_difficulty.dart';
import 'package:arkanoid/utilities_components/selector_eye.dart';
import 'package:arkanoid/utilities_components/slider.dart';
import 'package:arkanoid/utilities_components/start_button.dart';
import 'package:arkanoid/view.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ArkanoidGame extends FlameGame with HasCollidables, HasTappables, HasDraggables, KeyboardEvents {
  View activeView = View.home;
  late Vector2 screen;
  bool init = false;

  late SpriteComponent vrSprite;

  late List<Ball> balls;
  late Paddle paddle;
  late LateralPaddle lpl,lpr;
  late Wall wallLeft, wallRight;
  late Ceiling ceiling;
  late BottomHole bottomHole;
  late Vector2 tileSize;
  late List<Vector3> levelPosition;
  late Vector2 playScreenPosition;
  late Vector2 playScreenSize;
  late Set<b.Block> blocks;
  late Set<Bonus> bonusList;
  late Set<BonusType> bonusOnScreen;
  final double bonusPerc = 0.15;
  late List<Life> livesList;
  late GestureInvisibleScreen gesturesComponent;
  //late Logo logo;
  late StartButton startButton;
  late TextComponent logo;
  late TextComponent textBox1, textBox2;
  late List<TextComponent> difficulties;
  late List<TextComponent> eyeChoice;
  late NextLevelButton nextLevelButton;
  late Level currentLevel;
  late EyeButton eyeButtonLeft, eyeButtonRight;

  //late Sprite penalizationScreen;
  late bool penalizedEyeIsLeft;
  late bool penalizedEyeIsSet = false;

  late NoPenalizationButton noPenalizationButton;
  late HomeButton homeButton;

  double laserTimer = 0;
  late Laser laser1, laser2;

  late PauseScreen pauseScreen;

  // Animations
  final double animationSpeed = 0.15;
  late final SpriteAnimation disruption;
  late final SpriteAnimation mega;
  late final SpriteAnimation freeze;
  late final SpriteAnimation expansion;
  late final SpriteAnimation reduction;
  late final SpriteAnimation lasers;
  late final SpriteAnimation player;

  late final SpriteSheet paddleSheetCreate;
  late final SpriteSheet paddleSheetLaser;
  late final SpriteSheet paddleSheetDecompose;
  late final SpriteSheet paddleSheetDestruction;
  late final SpriteSheet spriteSheetBlocks;
  late final SpriteSheet spriteSheetBg;

  late final SpriteAnimation paddleNormalAnimation;
  late final SpriteAnimation paddleCreateNormalAnimation;
  late final SpriteAnimation paddleLaserAnimation;
  late final SpriteAnimation paddleCreateLaserAnimation;
  late final SpriteAnimation paddleExtendedAnimation;


  double penalPerc = 0.5;
  late Paint opacityPaint;

  late Offset position;
  int level = 0;

  Random rnd = Random();
  BonusType activeType = BonusType.normal;
  bool isActive = false;
  Paint a = Paint()..color = Color(0xFF00FF00);
  int lives = 2;

  late final List<Level> levels;
/*
  late OcarinaPlayer blockSound;
  late OcarinaPlayer steelSound;*/
  late AudioPool wallSound;
  late AudioPool lostLifeSound;
  late AudioPlayer gameOverBGM;

  bool activeSlider = false;


  bool lockOnTapUp = false;

  late Vector2 linePosition;
  late Vector2 lineSize;
  late Vector2 selectorPosition;
  late Vector2 selectorSize;


  late SliderSelection slider;
  late final SelectorDifficulty selectorDifficulty;
  late final SelectorEye selectorEye;
  late PlayButton playButton;

  late Set<LogicalKeyboardKey> keys = {};

  late Background bg;
  late Frame frame;

  late ResumeButton resumeButton;
  late PauseButton pauseButton;
  late EndgameButton endgameButton;
  late ReturnButton returnButton;


  late double pixel; //logical dimension of a pixel


  @override
  Future<void> onLoad() async {
    await super.onLoad();
    /*blockSound = OcarinaPlayer(
      asset: 'assets/audio/sfx/beeep.mp3'
    );
    await blockSound.load();
    steelSound = OcarinaPlayer(
        asset: 'assets/audio/sfx/bing.mp3'
    );*/
    /*await steelSound.load();*/

    // steelSound = await AudioPool.create('bing.mp3', maxPlayers: 4);
    wallSound = await AudioPool.create('plop.mp3');
    lostLifeSound = await AudioPool.create('vgdeathsound.mp3');
    gameOverBGM = await FlameAudio.audioCache.loop('bgm/KL Peach Game Over 2.mp3', volume: .25);
    gameOverBGM.pause();

    loadAnimations();

    screen=Vector2(size.x/2,size.y);
    tileSize = Vector2((screen.x*2/3)/13,(screen.x/3)/13);
    playScreenSize = Vector2(tileSize.x*13,tileSize.y*33);
    playScreenPosition = Vector2(screen.x/6,(screen.y-playScreenSize.y)/2);
    pixel = tileSize.y / 7;


    wallLeft = Wall(this,Vector2.all(0),Vector2(screen.x/6,screen.y));
    add(wallLeft);
    ceiling = Ceiling(this,Vector2.all(0),Vector2(screen.x,(screen.y-playScreenSize.y)/2));
    add(ceiling);
    wallRight = Wall(this,Vector2(screen.x-screen.x/6, 0),Vector2(screen.x/6,screen.y));
    add(wallRight);
    bottomHole = BottomHole(this);

    vrSprite = SpriteComponent.fromImage(
        Flame.images.fromCache('vr/cardboardview.png'),
        size: screen,
        priority: 100);
    add(vrSprite);

    frame = Frame(this);

    linePosition = Vector2(screen.x / 2 - playScreenSize.x * 3 / 8, screen.y / 2 + tileSize.y * 2);
    lineSize = Vector2(playScreenSize.x * 3 / 4, tileSize.y / 4);


    selectorPosition = linePosition + Vector2(0, lineSize.y / 2);
    selectorSize = Vector2.all(lineSize.y * 10);


    difficulties = [
      TextComponent(
          text: "EASY",
          position: Vector2(linePosition.x, linePosition.y + tileSize.y * 3),
          //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
          anchor: Anchor.center,
          textRenderer: getPainter(10)),
      TextComponent(
          text: "MEDIUM",
          position: Vector2(linePosition.x + lineSize.x / 2, linePosition.y + tileSize.y * 3),
          //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
          anchor: Anchor.center,
          textRenderer: getPainter(10)),
      TextComponent(
          text: "HARD",
          position: Vector2(linePosition.x + lineSize.x, linePosition.y + tileSize.y * 3),
          //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
          anchor: Anchor.center,
          textRenderer: getPainter(10))
    ];

    selectorDifficulty = SelectorDifficulty(this, selectorPosition, selectorSize, selectorPosition.x, selectorPosition.x + lineSize.x, 1);


    eyeChoice = [
      TextComponent(
          text: "LEFT",
          position: Vector2(linePosition.x, linePosition.y + tileSize.y * 3),
          //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
          anchor: Anchor.center,
          textRenderer: getPainter(10)),
      TextComponent(
          text: "NORMAL",
          position: Vector2(linePosition.x + lineSize.x / 2, linePosition.y + tileSize.y * 3),
          //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
          anchor: Anchor.center,
          textRenderer: getPainter(10)),
      TextComponent(
          text: "RIGHT",
          position: Vector2(linePosition.x + lineSize.x, linePosition.y + tileSize.y * 3),
          //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
          anchor: Anchor.center,
          textRenderer: getPainter(10))
    ];

    selectorEye = SelectorEye(this, selectorPosition + Vector2(lineSize.x / 2, 0), selectorSize, selectorPosition.x, selectorPosition.x + lineSize.x, 2);

    // DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
    // level = 3;
    // DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG

    levels = [
      Level1(this),
      Level2(this),
      Level3(this),
      Level4(this),
      Level5(this),
      Level6(this),
      Level7(this)
    ];

    opacityPaint = Paint()..color = Colors.white.withOpacity(penalPerc);

    pauseScreen = PauseScreen(this);

    pauseButton = PauseButton(this);

    resumeButton = ResumeButton(this);

    endgameButton = EndgameButton(this);

    returnButton = ReturnButton(this);


    startHome();

    //startGame();
  }



  void startHome() {
    activeView = View.home;
    keys = {};
    playHomeBGM();
    penalizedEyeIsSet = false;
    logo = TextComponent(
        text: "ARKANOID",
      position: Vector2(screen.x/2,screen.y/4),
      //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
      anchor: Anchor.center,
      textRenderer: getPainter(30));
    add(logo);
    textBox1 = TextComponent(
        text: "SELECT DIFFICULTY",
        position: Vector2(screen.x/2,screen.y/2 - tileSize.y * 2),
        //size: Vector2(game.playScreenSize.x*4/5,game.playScreenSize.x*4/5*45/8),
        anchor: Anchor.center,
        textRenderer: getPainter(10));
    add(textBox1);
    slider = SliderSelection(selectorDifficulty, linePosition, lineSize);
    add(slider);
    add(selectorDifficulty);
    addAll(difficulties);
    startButton = StartButton(this);
    add(startButton);
  }

  //
  // aggiungere power up (quelli attuali hanno dimensione totale 108x91, singola immagine 12x13)
  //

  void removeHome() {
    remove(logo);
    remove(textBox1);
    remove(slider);
    remove(selectorDifficulty);
    removeAll(difficulties);
    remove(startButton);
  }

  void selectEye() {
    activeView = View.selectEye;
    textBox1 = TextComponent(
      text: "SELECT THE",
      //text: "SCEGLI L'OCCHIO\n\nAMBLIOPICO",
      textRenderer: getPainter(15), position: Vector2(screen.x/2,screen.y/3),
      /*boxConfig: TextBoxConfig(
        maxWidth: playScreenSize.x*9/10,
      ),*/
      anchor: Anchor.center,
    );
    add(textBox1);
    textBox2 = TextComponent(
      text: "\n\n\nHEALTHY EYE",
      //text: "SCEGLI L'OCCHIO\n\nAMBLIOPICO",
      textRenderer: getPainter(15), position: Vector2(screen.x/2,screen.y/3),
      /*boxConfig: TextBoxConfig(
        maxWidth: playScreenSize.x*9/10,
      ),*/
      anchor: Anchor.center,
    );
    add(textBox2);
    slider = SliderSelection(selectorEye, linePosition, lineSize);
    add(slider);
    add(selectorEye);
    addAll(eyeChoice);
    playButton = PlayButton(this);
    add(playButton);
    add(returnButton);

    //eyeButtonLeft = EyeButton(this, true);
    //eyeButtonRight = EyeButton(this, false);
    //noPenalizationButton = NoPenalizationButton(this);
    //add(eyeButtonLeft);
    //add(eyeButtonRight);
    //add(noPenalizationButton);

  }

  void addPenalization(isLeft) {
    removeEyeSelection();
    // penalizationScreen = Sprite(Flame.images.fromCache('background/penalization.png'));
    penalizedEyeIsLeft = isLeft;
    penalizedEyeIsSet = true;
    startGame();
  }

  void removeEyeSelection() {
    remove(textBox1);
    remove(textBox2);
    remove(slider);
    remove(selectorEye);
    removeAll(eyeChoice);
    remove(playButton);
    remove(returnButton);

    // remove(eyeButtonLeft);
    // remove(eyeButtonRight);
    // remove(noPenalizationButton);
  }

  void startGame() {
    activeView = View.play;
    keys = {};
    lives = 2;
    bonusList = <Bonus>{};
    livesList = <Life>[];
    for(int i=0; i<lives; i++) {
      livesList.add(Life(this,i));
    }
    bonusOnScreen = <BonusType>{};
    nextLevel();
  }


  @override
  void update (double dt) {
    super.update(dt);

    waitLasers(dt);

  }


  @override
  void render(Canvas canvas) {
    if(penalizedEyeIsSet) {
      if (penalizedEyeIsLeft) {
        addPenal();
      }
    }
    super.render(canvas);
    if(penalizedEyeIsSet) {
      resetPenal();
    }
    /*if(penalizedEyeIsSet) {
      if (penalizedEyeIsLeft) {
        canvas.save();
        penalizationScreen.renderRect(canvas, Rect.fromLTWH(playScreenPosition.x,playScreenPosition.y,playScreenSize.x,playScreenSize.y), overridePaint: opacityPaint);
        canvas.restore();
      }
    }*/

    canvas.translate(screen.x,0); //render alla metà destra

    if(penalizedEyeIsSet) {
      if (!penalizedEyeIsLeft) {
        addPenal();
      }
    }
    super.render(canvas);
    if(penalizedEyeIsSet) {
      resetPenal();
    }
    /*if(penalizedEyeIsSet) {
      if (!penalizedEyeIsLeft) {
        canvas.save();
        penalizationScreen.renderRect(canvas, Rect.fromLTWH(playScreenPosition.x,playScreenPosition.y,playScreenSize.x,playScreenSize.y), overridePaint: opacityPaint);
        canvas.restore();
      }
    }*/
  }

  void addPenal() {
    paddle.setOpacity(penalPerc);
    blocks.forEach((element) {
      element.setOpacity(penalPerc);
    });
    bonusList.forEach((element) {
      element.setOpacity(penalPerc);
    });
    opacityPaint.color = opacityPaint.color.withOpacity(penalPerc/2);
  }

  void resetPenal() {
    paddle.setOpacity(1);
    blocks.forEach((element) {
      element.setOpacity(1);
    });
    bonusList.forEach((element) {
      element.setOpacity(1);
    });
    opacityPaint.color = opacityPaint.color.withOpacity(penalPerc);
  }

  void waitLasers(double dt) {
    if(activeType == BonusType.laser && activeView != View.pause) {
      laserTimer += dt;
      if(laserTimer >= 1) {
        laserTimer = 0;
        laser1 = Laser(this, true);
        laser2 = Laser(this, false);
        add(laser1);
        add(laser2);
      }
    }
  }

  void showLives() {
    addAll(livesList);
  }

  void multiplyBall() {
    resetBonus();

    // metto degli angoli fissi
    balls.add(Ball(this, false, angle: 40));
    add(balls.last);
    balls.add(Ball(this, false, angle: 140));
    add(balls.last);

  }

  void expandPaddle() {
    resetBonus();
    paddle.size.x += tileSize.x/2;
  }

  void reducePaddle() {
    resetBonus();
    paddle.size.x -= tileSize.x/2;
  }

  void freezeBall() {
    resetBonus();

    deleteLowerPositionBalls();
    balls.first.freezeBonus = true;

  }

  void megaBall() {
    resetBonus();
    for(int i=0; i<balls.length; i++) {
      balls.elementAt(i).megaBonus = true;
    }
  }

  void laser() {
    resetBonus();
    paddle.animation = paddleSheetLaser.createAnimation(row: 0, loop: false, stepTime: animationSpeed);
    paddle.animation?.onComplete = () {
      paddle.animation = paddleLaserAnimation;
    };
    paddle.animation?.reset();
    laserTimer = 0;
  }

  void extraLifePlayer() {
    livesList.add(Life(this,lives));
    add(livesList.last);
    lives++;
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

  void resetBonus() {
    paddle.size.x = tileSize.x*2; // disattivo expansion e reduction
    if (balls.isNotEmpty) {
      balls.first.freezeBonus = false; // disattivo il bonus nella pallina
      for(int i=0; i<balls.length; i++) {
        balls.elementAt(i).megaBonus = false;
      }
      if(balls.first.freeze) {
        balls.first.freeze = false; // disattivo il freeze
        balls.first.movementOnOff(true, false); // attivo il movimento
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

  void lostLifeAnimation() {
    /*
    paddle.xPaddle = screen.x/2; // Quando perde una vita rimetto il paddle al centro
    paddle.position.x = paddle.xPaddle;
    */
    lostLifeSound.start();
    removeComponentsNoPaddle();
    paddle.animation = paddleSheetDecompose.createAnimation(
        row: 0, loop: false, stepTime: animationSpeed);
    paddle.animation?.onComplete = () {
      paddle.transparent();
      paddle.position.y += paddle.size.y / 2;
      paddle.anchor = Anchor.center;
      paddle.size.x = paddle.size.x * 3 / 2;
      paddle.size.y = paddle.size.y * 3;

      paddle.animation = paddleSheetDestruction.createAnimation(
          row: 0, loop: false, stepTime: animationSpeed);
      paddle.animation?.onComplete = () {
        removePaddle();
        lostLife();
      };
    };
  }
  void lostLife() {
    removeBonuses();
    lives--;

    if (livesList.isEmpty) {
      lostGame();
    }
    else {
      if(activeView == View.pause) {
        resume();
      }
      createPaddle();
      gesturesComponent = GestureInvisibleScreen(this);
      add(gesturesComponent);
      remove(livesList.last);
      livesList.removeLast();
      resetBonus();
      balls.add(Ball(this, true));
      add(balls.first);
    }
  }

  void removeAllComponents() {
    removeBlocks();
    removeComponents();
    remove(gesturesComponent);
    remove(bottomHole);
    remove(bg);
    remove(frame);
    remove(pauseButton);
    remove(pauseScreen);
    remove(pauseButton);
    remove(resumeButton);
    remove(endgameButton);
    livesList.forEach((element) {
      remove(element);
    });
    level = 0;
  }

  void lostGame() {
    // Lo metto subito per il debug, ma ci sarà una schermata di game over
    removeAllComponents();
    lostScreen();
    //startHome();
  }

  void lostScreen() {
    activeView = View.lost;
    //FlameAudio.bgm.audioCache.play('bgm/KL Peach Game Over 2.mp3');
    playGameOverBGM();
    textBox1 = TextComponent(
      text: "GAME OVER",
      textRenderer: getPainter(30),
      position: Vector2(screen.x/2,screen.y/3),
      /*boxConfig: TextBoxConfig(
        maxWidth: playScreenSize.x*9/10,
        timePerChar: 0.2,
      ),*/
      anchor: Anchor.center,
    );
    add(textBox1);
    homeButton = HomeButton(this);
    add(homeButton);
  }

  void playHomeBGM() {
    gameOverBGM.pause();
    gameOverBGM.seek(Duration.zero);

  }

  void playGameOverBGM() {
    /*gameOverBGM.pause();
    gameOverBGM.seek(Duration.zero);*/
    gameOverBGM.resume();

  }

  void removeBlocks() {
    removeAll(blocks);
  }

  void removeComponents() {
    removePaddle();
    removeComponentsNoPaddle();
  }

  void removeComponentsNoPaddle() {
    removeBalls();
    removeBonuses();
    remove(gesturesComponent);
    children.removeWhere((element) => element is Laser); // elimino i laser se rimasti sullo schermo
  }

  void removePaddle() {
    remove(paddle);
    remove(lpl);
    remove(lpr);
  }
  void createPaddle() {
    paddle = Paddle(this);
    add(paddle);
    lpl = LateralPaddle(this, paddle, 0);
    add(lpl);
    lpr = LateralPaddle(this, paddle, 1);
    add(lpr);
  }

  void removeBalls() {
    removeAll(balls);
    balls.removeRange(0, balls.length);
  }

  void removeBonuses() {
    activeType = BonusType.normal;
    removeAll(bonusList);
    bonusList = <Bonus>{};
    bonusOnScreen = <BonusType>{};
  }

  void levelCompleted() {
    removeComponents();
    removeBlocks();
    removeAll(livesList);
    remove(bottomHole);
    remove(bg);
    remove(frame);
    remove(pauseButton);


    if(level < levels.length-1) {
      activeView = View.levelComplete;
      textBox1 = TextComponent(
        text: "LEVEL",
        textRenderer: getPainter(30),
        position: Vector2(screen.x / 2, screen.y / 3),
        /*boxConfig: TextBoxConfig(
        maxWidth: playScreenSize.x*9/10,
        timePerChar: 0.2,
      ),*/
        anchor: Anchor.center,
      );
      textBox2 = TextComponent(
        text: "\n\nCOMPLETED",
        textRenderer: getPainter(30),
        position: Vector2(screen.x / 2, screen.y / 3),
        /*boxConfig: TextBoxConfig(
        maxWidth: playScreenSize.x*9/10,
        timePerChar: 0.2,
      ),*/
        anchor: Anchor.center,
      );
      nextLevelButton = NextLevelButton(this);
      add(nextLevelButton);
    }
    else {
      removeLives();
      activeView = View.gameComplete;
      textBox1 = TextComponent(
        text: "GAME",
        textRenderer: getPainter(30),
        position: Vector2(screen.x / 2, screen.y / 3),
        /*boxConfig: TextBoxConfig(
        maxWidth: playScreenSize.x*9/10,
        timePerChar: 0.2,
      ),*/
        anchor: Anchor.center,
      );
      textBox2 = TextComponent(
        text: "\n\nCOMPLETED",
        textRenderer: getPainter(30),
        position: Vector2(screen.x / 2, screen.y / 3),
        /*boxConfig: TextBoxConfig(
        maxWidth: playScreenSize.x*9/10,
        timePerChar: 0.2,
      ),*/
        anchor: Anchor.center,
      );
      level = 0;
      homeButton = HomeButton(this);
      add(homeButton);
    }
    add(textBox1);
    add(textBox2);
  }

  void removeLives() {
    removeAll(livesList);
  }

  void removeLevel() {
    remove(textBox1);
    remove(textBox2);
    remove(nextLevelButton);
  }

  void nextLevel() {
    keys = {}; // Resetto la lista di keys attive
    activeView = View.play;
    gesturesComponent = GestureInvisibleScreen(this);
    add(gesturesComponent);
    currentLevel = levels.elementAt(level);
    currentLevel.create();
  }

  void removeLostScreen() {
    remove(textBox1);
    remove(textBox2);
    remove(homeButton);
    playHomeBGM();
  }

  void pause() {
    activeView = View.pause;
    remove(gesturesComponent);
    balls.forEach((element) {
      element.movementOnOff(false, false);
    });
    bonusList.forEach((element) {
      element.movementOnOff(false);
    });
    paddle.velocity = Vector2.zero();
    laser1.movementOnOff(false);
    laser2.movementOnOff(false);
    add(pauseScreen);
    remove(pauseButton);
    add(resumeButton);
    add(endgameButton);
  }


  void resume() {
    activeView = View.play;
    add(gesturesComponent);
    balls.forEach((element) {
      element.movementOnOff(true, false);
    });
    bonusList.forEach((element) {
      element.movementOnOff(true);
    });
    laser1.movementOnOff(true);
    laser2.movementOnOff(true);
    remove(pauseScreen);
    remove(resumeButton);
    remove(endgameButton);
    add(pauseButton);
  }

  void endgame() {
    activeView = View.home;
    removeAllComponents();
    startHome();
  }



  //
  //
  //
  //
  // CAPIRE SE POSSO FARE QUALCOSA PER IL LAG (Con usb lagga, tastiera bluetooth no)
  //
  //
  //
  //
  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event,
      Set<LogicalKeyboardKey> keysPressed,
      ) {

    if (event is RawKeyDownEvent && keys.contains(event.logicalKey)) return super.onKeyEvent(event, keysPressed);

    switch (activeView) {

      case View.levelComplete:
        nextLevelButton.keyboardAction(event);
        break;

      case View.lost:
        homeButton.keyboardAction(event);
        break;

      case View.play:
        paddle.keyboardAction(event);
        pauseButton.keyboardAction(event);
        break;

      case View.selectEye:
        selectorEye.keyboardAction(event);
        playButton.keyboardAction(event);
        returnButton.keyboardAction(event);
        break;

      case View.gameComplete:
        homeButton.keyboardAction(event);
        break;

      case View.home:
        selectorDifficulty.keyboardAction(event);
        startButton.keyboardAction(event);
        break;

      case View.pause:
        resumeButton.keyboardAction(event);
        endgameButton.keyboardAction(event);
        break;

    }

    return super.onKeyEvent(event, keysPressed);
  }


  void loadAnimations() {
    final SpriteSheet spriteSheet = SpriteSheet(
      image: Flame.images.fromCache('powerUp/powerups.png'),
      srcSize: Vector2(16.0, 8.0),
    );
    disruption = spriteSheet.createAnimation(row: 2, stepTime: animationSpeed);
    expansion = spriteSheet.createAnimation(row: 3, stepTime: animationSpeed);
    reduction = spriteSheet.createAnimation(row: 0, stepTime: animationSpeed);
    mega = spriteSheet.createAnimation(row: 5, stepTime: animationSpeed);
    lasers = spriteSheet.createAnimation(row: 4, stepTime: animationSpeed);
    freeze = spriteSheet.createAnimation(row: 1, stepTime: animationSpeed);
    player = spriteSheet.createAnimation(row: 6, stepTime: animationSpeed);

    paddleSheetCreate = SpriteSheet(
      image: Flame.images.fromCache('components/paddle_create.png'),
      srcSize: Vector2(32.0, 8.0),
    );
    paddleCreateNormalAnimation = paddleSheetCreate.createAnimation(row: 0, loop: false, stepTime: animationSpeed);
    paddleCreateNormalAnimation.onComplete = () {
      paddle.animation = paddleNormalAnimation;
    };

    SpriteSheet paddleSheet = SpriteSheet(
      image: Flame.images.fromCache('components/paddle_normal.png'),
      srcSize: Vector2(32.0, 8.0),
    );
    paddleNormalAnimation = paddleSheet.createAnimation(row: 0, stepTime: animationSpeed);

    paddleSheetLaser = SpriteSheet(
      image: Flame.images.fromCache('components/paddle_create_laser.png'),
      srcSize: Vector2(32.0, 8.0),
    );
    /*
    paddleCreateLaserAnimation = paddleSheet.createAnimation(row: 0, loop: false, stepTime: animationSpeed);
    paddleCreateLaserAnimation.onComplete = () {
      paddle.animation = paddleLaserAnimation;
    };
    */

    paddleSheet = SpriteSheet(
      image: Flame.images.fromCache('components/paddle_laser.png'),
      srcSize: Vector2(32.0, 8.0),
    );
    paddleLaserAnimation = paddleSheet.createAnimation(row: 0, stepTime: animationSpeed);

    paddleSheet = SpriteSheet(
      image: Flame.images.fromCache('components/paddle_extended.png'),
      srcSize: Vector2(32.0, 8.0),
    );
    paddleExtendedAnimation = paddleSheet.createAnimation(row: 0, stepTime: animationSpeed);

    paddleSheetDecompose = SpriteSheet(
      image: Flame.images.fromCache('components/paddle_decompose.png'),
      srcSize: Vector2(32.0, 8.0),
    );

    paddleSheetDestruction = SpriteSheet(
      image: Flame.images.fromCache('components/paddle_destruction.png'),
      srcSize: Vector2(48.0, 24.0),
    );

    spriteSheetBlocks = SpriteSheet(
      image: Flame.images.fromCache('components/blocks.png'),
      srcSize: Vector2(16.0, 8.0),
    );

    spriteSheetBg = SpriteSheet(
      image: Flame.images.fromCache('background/field.png'),
      srcSize: Vector2(208.0, 232.0),
    );
  }



  TextPaint getPainter(double fSize) {
    // mio: 417.8181818181818,392.72727272727275
    // avd: 383.45454545454544,392.72727272727275

    fSize = fSize * screen.x / 417.8181818181818;

    TextPaint painter;
    TextStyle textStyle;

    textStyle = TextStyle(
      fontFamily: 'arcade',
      fontSize: fSize,
      color: Color(0xffffffff),
      /*shadows: const <Shadow>[
        Shadow(
          blurRadius: 7,
          color: Color(0xffff0000),
          offset: Offset(2, 2),
        ),
      ],*/
    );

    painter = TextPaint(
      style: textStyle,
      textDirection: TextDirection.ltr,
    );
    return painter;
  }





}



