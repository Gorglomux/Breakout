package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.text.FlxText;
import Globals.*;
class MenuState extends FlxState
{

	var _title:FlxText;
	var _playGame:FlxText;
	override public function create():Void
	{
		_title= new FlxText(SCREEN_WIDTH/2-70, SCREEN_HEIGHT/6,"Breakout",25);
		_playGame= new FlxText(SCREEN_WIDTH/2-40, SCREEN_HEIGHT/2,"> Play <",16);
		
		add(_title);
		add(_playGame);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		if(FlxG.keys.anyPressed([SPACE,ENTER])){
			FlxG.switchState(new PlayState());
		}
		super.update(elapsed);
	}
}
