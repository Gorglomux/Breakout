package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(Globals.SCREEN_WIDTH, Globals.SCREEN_HEIGHT, MenuState,1,60,60,true));
	}
}
