package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.text.FlxText;
import Globals.*;
class PlayState extends FlxState
{
	var _bar:FlxSprite;
	var _ball:FlxSprite;
	var _walls:FlxGroup;
	var _bricks:FlxTypedGroup<FlxSprite>;
	var gameOver:Bool=false;
	var win:Bool=false;
	var gameOverText:FlxText;
	override public function create():Void
	{
		 _bricks= new FlxTypedGroup<FlxSprite>();
		var file= "assets/data/level"+level;
		var content:String = "";
		if(sys.FileSystem.exists(file)){
			content = sys.io.File.getContent(file);
			
			createMap(content);

		}else{
			win=true;
			gameOver=true;
		}
		if(livesLeft<=0){
			gameOver=true;
		}
		_bar = new FlxSprite(SCREEN_WIDTH/2-BAR_WIDTH/2,SCREEN_HEIGHT-20);
		_bar.makeGraphic(BAR_WIDTH,BAR_HEIGHT,FlxColor.WHITE);
		_bar.immovable=true;

		_ball = new FlxSprite(_bar.x+BAR_WIDTH/2,_bar.y-BAR_HEIGHT);
		_ball.makeGraphic(BALL_WIDTH,BALL_HEIGHT,FlxColor.WHITE);

		_walls = new FlxGroup();
		var wallLeft:FlxSprite=new FlxSprite(0,0);
		wallLeft.makeGraphic(1,SCREEN_HEIGHT,FlxColor.GRAY);
		wallLeft.immovable=true;
		_walls.add(wallLeft);
	
		var wallRight:FlxSprite=new FlxSprite(SCREEN_WIDTH-1,0);
		wallRight.makeGraphic(1,SCREEN_HEIGHT,FlxColor.GRAY);
		wallRight.immovable=true;
		_walls.add(wallRight);

		var wallUp:FlxSprite=new FlxSprite(0,0);
		wallUp.makeGraphic(SCREEN_WIDTH,1,FlxColor.GRAY);
		wallUp.immovable=true;
		_walls.add(wallUp);
		
		add(_bar);
		add(_ball);
		add(_walls);
		add(_bricks);
		super.create();
	}
	var previousBallVeloX:Float= 0;
	var previousBallVeloY:Float= 0;
	var gameStarted=false;
	override public function update(elapsed:Float):Void
	{
		if(FlxG.keys.justPressed.R) {
			level=1;
			livesLeft=3;
			FlxG.resetGame();
		}
		if(gameOver){
			gameOverText = new FlxText(SCREEN_WIDTH/2-120,SCREEN_HEIGHT/2-60,"       Game over !", 20);
			var levelReached:FlxText;
			if(win){
				levelReached= new FlxText(SCREEN_WIDTH/2-120,SCREEN_HEIGHT/2-30,"You have finished the game ! \n Congratulations !!",12 ); 
			}else{
				levelReached= new FlxText(SCREEN_WIDTH/2-120,SCREEN_HEIGHT/2-30,"You reached level "+level+" !",12 );
			}
			var newGame = new FlxText(SCREEN_WIDTH/2-120,SCREEN_HEIGHT/2,"Press R to restart...",12 );
			add(gameOverText);
			add(levelReached);
			add(newGame);
		}
		else{
			if(_ball.velocity.y==0&&gameStarted){
				_ball.velocity.y=-10;
			}
			if(FlxG.keys.justPressed.SPACE&&!gameStarted) {
				_ball.velocity.y-=200;
				gameStarted=true;
			}
			if(!gameStarted){
				_ball.x=_bar.x+BAR_WIDTH/2-BALL_WIDTH/2;
			}
			previousBallVeloX=_ball.velocity.x;
			previousBallVeloY=_ball.velocity.y;
		
			if(FlxG.keys.anyPressed([LEFT,Q])&&_bar.x>0){
				_bar.x-=5;
			}else if(FlxG.keys.anyPressed([RIGHT,D])&&_bar.x+Globals.BAR_WIDTH<Globals.SCREEN_WIDTH) {
				_bar.x+=5;
			}
			



			FlxG.collide(_walls,_ball,bounce);
			FlxG.collide(_bar,_ball,ping);

			FlxG.collide(_bricks,_ball,breakBrick);
			var notOver:Bool=false;
			_bricks.forEachAlive(function (brick){
					if(brick.color!=FlxColor.GRAY){
						notOver=true;
						return;
					}

			});
			if(!notOver){
				level++;
				FlxG.resetState();
			}
			if(_bricks.getFirstAlive()==null){
				level++;
				FlxG.resetState();
			}

			if(_ball.y>=SCREEN_HEIGHT||_ball.x<0||_ball.x>SCREEN_WIDTH){
				livesLeft--;
				if(livesLeft==0){
					gameOver=true;
				}
				restart();
			}
		}
		super.update(elapsed);
	}
	function breakBrick(brick:FlxSprite,ball:FlxSprite){
		if(brick.color!=FlxColor.GRAY){

			brick.destroy();
		}	
		if(ball.isTouching(FlxObject.RIGHT)||ball.isTouching(FlxObject.LEFT)){
			ball.velocity.x=-1*previousBallVeloX;			
		}else if (ball.isTouching(FlxObject.UP)||ball.isTouching(FlxObject.DOWN)){
			ball.velocity.y=-1*previousBallVeloY;
		}	
		
	}
	function bounce(_w:FlxSprite,_b:FlxSprite){
		if(_ball.y!=1){
			_b.velocity.x=-1*previousBallVeloX;
		}
		if(_ball.y==1){
			_ball.velocity.y=-1*previousBallVeloY;
		}
	}
	function ping(bar:FlxSprite,ball:FlxSprite){
		var diff= bar.x+BAR_WIDTH/2-ball.x+BALL_WIDTH/2;
		ball.velocity.y=-200;
		if(diff>0){
			ball.velocity.x=10*(-1*diff);
		}else{
			ball.velocity.x=10*(-1*diff);
		}
	}
	function restart(){
		gameStarted=false;
		_bar.x=SCREEN_WIDTH/2-BAR_WIDTH/2;
		_ball.velocity.x=0;
		_ball.velocity.y=0;
		_ball.y=_bar.y-BAR_HEIGHT ;
		_ball.x=_bar.x+BAR_WIDTH/2;
	}
	function createMap(map:String){
		var posX=10;
		var posY=5;
		
		for(char in 0...map.length){
			switch(map.charAt(char)){
				case '1':
					var brick = new FlxSprite(posX,posY);
					brick.makeGraphic(BRICK_WIDTH,BRICK_HEIGHT,FlxColor.YELLOW);
					brick.immovable=true;
					_bricks.add(brick);
					posX+=BRICK_WIDTH+1;
				case '0':
					var brick = new FlxSprite(posX,posY);
					brick.makeGraphic(BRICK_WIDTH,BRICK_HEIGHT,FlxColor.RED);
					brick.immovable=true;
					_bricks.add(brick);
					posX+=BRICK_WIDTH+1;
				case 'X':
					var brick = new FlxSprite(posX,posY);
					brick.makeGraphic(BRICK_WIDTH,BRICK_HEIGHT,FlxColor.GRAY);
					brick.immovable=true;
					brick.color=FlxColor.GRAY;
					_bricks.add(brick);			
					posX+=BRICK_WIDTH+1;			
				case ' ':
					posX+=BRICK_WIDTH+1; 
				case '\n':
					posX=10;
					posY+=BRICK_HEIGHT+1;
			}
		}
		
	}
}
