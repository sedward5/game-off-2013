package;

import flash.display.Sprite;
import openfl.Assets;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.display.LoaderInfo;
import flash.display.Loader;
import flash.display.Bitmap;
import flash.net.URLRequest;
import flash.system.Security;
import flash.media.SoundTransform;

class Main extends Sprite {
	
	// Goal Location
	static var goal : flash.display.Shape;
	
	// Good Guy Stats
	static var a : flash.display.Shape;
	static var rectangleWidth = 40;
	static var rectangleHeight = 40;
	static var moveX : Float = 0; // the movement per frame of the rectangle on the horizontal axis
	static var moveY : Float = 0; // the movement per frame of the rectangle on the vertical axis
	
	//Bad guy stats
	static var b : flash.display.Shape;
	static var bWidth = 40;
	static var bHeight = 40;

	//Random terrain element
	static var t1 : flash.display.Shape;
	static var t2 : flash.display.Shape;
	static var t3 : flash.display.Shape;
	static var t4 : flash.display.Shape;
	static var t5 : flash.display.Shape;
	static var t1b : Bool = true;
	static var t2b : Bool = true;
	static var t3b : Bool = true;
	static var t4b : Bool = true;
	static var t5b : Bool = true;

	//Game state stuff
	static var win : Bool = false;
	static var loss: Bool = false;
	static var started: Bool = false;	
	static var restart_pressed: Bool = false;
	static var next_pressed: Bool = false;
	static var score: Int = 0;
	static var switchtimer: Int = 5;
	static var tick: Int = 0;
	
	//Text objects that update
	static var winlosstext;
	static var scoretext;
	static var switchtext;
	
	
	//Kongregate stuff
	static var onkon:Bool = true;
	static var kongregate;
	
	public function new () {
		super ();
		// Load the Kongregate API if onkon is true
		if(onkon) {kongregate = new CKongregate();}
		
		//Draw the background
		var field  = new flash.display.Shape();
		field.graphics.beginBitmapFill(Assets.getBitmapData("assets/3.png"));
		field.graphics.drawRect ( 0, 0, 700, 550);
		field.graphics.endFill ();
		flash.Lib.current.addChild(field);
		
		
		//Add the goal
		goal  = new flash.display.Shape();
		goal.graphics.beginBitmapFill(Assets.getBitmapData("assets/2.png"));
		goal.graphics.drawRect ( 0, 0, 75, 75);
		goal.graphics.endFill ();
		goal.x = 700-75-1;
		goal.y = 525-75-1;
		goal.filters = [ new  GlowFilter(0x5Dd9dF, 1.0, 5, 5, 5, 5, false, false) ];
		flash.Lib.current.addChild(goal);
		
		
		// Add 5 terrain elements that will be moved once they're all drawn
		t1 = new flash.display.Shape();
		t1.graphics.beginFill ( 0x000000 );
		t1.graphics.lineStyle ( 1, 0xffffff, 1, false, flash.display.LineScaleMode.NONE );
		t1.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
		t1.graphics.endFill ();
		flash.Lib.current.addChild(t1);
		
		t2 = new flash.display.Shape();
		t2.graphics.beginFill ( 0x000000 );
		t2.graphics.lineStyle ( 1, 0xffffff, 1, false, flash.display.LineScaleMode.NONE );
		t2.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
		t2.graphics.endFill ();
		flash.Lib.current.addChild(t2);
		
		t3 = new flash.display.Shape();
		t3.graphics.beginFill ( 0x000000 );
		t3.graphics.lineStyle ( 1, 0xffffff, 1, false, flash.display.LineScaleMode.NONE );
		t3.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
		t3.graphics.endFill ();
		flash.Lib.current.addChild(t3);
		
		t4 = new flash.display.Shape();
		t4.graphics.beginFill ( 0x000000 );
		t4.graphics.lineStyle ( 1, 0xffffff, 1, false, flash.display.LineScaleMode.NONE );
		t4.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
		t4.graphics.endFill ();
		flash.Lib.current.addChild(t4);
		
		t5 = new flash.display.Shape();
		t5.graphics.beginFill ( 0x000000 );
		t5.graphics.lineStyle ( 1, 0xffffff, 1, false, flash.display.LineScaleMode.NONE );
		t5.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
		t5.graphics.endFill ();
		flash.Lib.current.addChild(t5);
		
		//Add the good guy
		a  = new flash.display.Shape();
		a.graphics.beginBitmapFill(Assets.getBitmapData("assets/1.png"));
		a.graphics.drawRect ( 0, 0, rectangleWidth, rectangleHeight);
		a.graphics.endFill ();
		a.filters = [ new  GlowFilter(0x9b0000, 1.0, 5, 5, 5, 5, false, false) ];
		flash.Lib.current.addChild(a);

		//Add the bad guy
		b  = new flash.display.Shape();
		b.graphics.beginBitmapFill(Assets.getBitmapData("assets/1.png"));
		b.graphics.drawRect ( 0, 0, rectangleWidth, rectangleHeight);
		b.x = 700-bWidth-1;
		b.y = 525-bHeight-1;
		b.graphics.endFill ();
		b.filters = [ new  GlowFilter(0x009b00, 1.0, 5, 5, 5, 5, false, false) ];
		flash.Lib.current.addChild(b);
		
		// Display some text
		var titleText = new MyText(260, 50, 40, 0xffffff, 'Averter!', true);
		var instructionText = new MyText(170, 488, 14, 0xffffff, 'Avoid green, get to blue, use arrows, r to reset.', false);
		var instructionText2 = new MyText(135, 505, 14, 0xffffff, 'Red can pass through white, green can pass through black.', false);
		scoretext = new MyText(600, 5, 14, 0xffffff, 'Score: 0', false);
		winlosstext = new MyText(40, 350, 40, 0xffffff, '', true);
		switchtext = new MyText(5, 5, 14, 0xffffff, 'Next Switch: '+switchtimer, false);
		
		//Randomize the terrain
		redrawField();
		
		var sound = Assets.getSound("assets/bgm.wav");
		sound.play (0, 9999, new SoundTransform(.15));
		//Start event handlers
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME,function(_) Main.onEnterFrame());
		flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, key_down);
		flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, key_up);
	}
	
	static function key_down(event:flash.events.KeyboardEvent)
	{
		if (event.keyCode == 37) { // left arrow
			moveX = -5;
			started = true;
		}
		else if (event.keyCode == 39) { // right arrow
			moveX = 5;
			started = true;
		}
		else if (event.keyCode == 38) { // up arrow
			moveY = -5;
			started = true;
		}
		else if (event.keyCode == 40) { // down arrow
			moveY = 5;
			started = true;
		}
		else if (event.keyCode == 82) {
			restart_pressed = true;
		} 
		else if (event.keyCode == 78) {
			next_pressed = true;
		}
	}
   
	static function key_up(event:flash.events.KeyboardEvent)
	{
		if (event.keyCode == 37 && moveX == -5) // left arrow
		moveX = 0;
		else if (event.keyCode == 39 && moveX == 5) // right arrow
		moveX = 0;
		else if (event.keyCode == 38 && moveY == -5) // up arrow
		moveY = 0;
		else if (event.keyCode == 40 && moveY == 5) // down arrow
		moveY = 0;
		else if ((event.keyCode == 82 || event.keyCode == 78) && restart_pressed == true) {
			restart_pressed = false;
		}
		else if (event.keyCode == 78 && next_pressed == true) {
			next_pressed = false;
		}
	}
	static function onEnterFrame()
	{
		// Catch restart key
		if(restart_pressed) {
			score=0;
			scoretext.updateText("Score: "+score);
			win = false;
			loss = false;
			started = false;
			a.x = 0;
			a.y = 0;
			b.x = 700-bWidth-1;
			b.y = 525-bHeight-1;
			switchtimer=5;
			switchtext.updateText('Next Switch: '+switchtimer);
			redrawField();
				
				
				
			winlosstext.hideText();
			} else if(next_pressed && win) {
				win = false;
				loss = false;
				started = false;
				a.x = 0;
				a.y = 0;
				b.x = 700-bWidth-1;
				b.y = 525-bHeight-1;
				switchtimer=5;
				switchtext.updateText('Next Switch: '+switchtimer);
				redrawField();
				winlosstext.hideText();
		   	
			}
		   
			if(win || loss) {
				// Do nothing
			} 
			else {		
					
					
				// Terrain Collision detection
				if((isCollision(a.x+moveX, a.width, a.y, a.height, t1.x, t1.width, t1.y, t1.height) && t1b) ||
				(isCollision(a.x+moveX, a.width, a.y, a.height, t2.x, t2.width, t2.y, t2.height) && t2b) ||
				(isCollision(a.x+moveX, a.width, a.y, a.height, t3.x, t3.width, t3.y, t3.height) && t3b) ||
				(isCollision(a.x+moveX, a.width, a.y, a.height, t4.x, t4.width, t4.y, t4.height) && t4b) ||
				(isCollision(a.x+moveX, a.width, a.y, a.height, t5.x, t5.width, t5.y, t5.height) && t5b)) { 
					  
				}
				else {
					a.x += moveX;		
				}
				if((isCollision(a.x, a.width, a.y+moveY, a.height, t1.x, t1.width, t1.y, t1.height) && t1b) ||
				(isCollision(a.x, a.width, a.y+moveY, a.height, t2.x, t2.width, t2.y, t2.height) && t2b) ||
				(isCollision(a.x, a.width, a.y+moveY, a.height, t3.x, t3.width, t3.y, t3.height) && t3b) ||
				(isCollision(a.x, a.width, a.y+moveY, a.height, t4.x, t4.width, t4.y, t4.height) && t4b) ||
				(isCollision(a.x, a.width, a.y+moveY, a.height, t5.x, t5.width, t5.y, t5.height) && t5b)) { 
					
				}
				else {
					a.y += moveY;
				}
				  
				  
				          
				// here we prevent the rectangle to move out of the display area
				if( a.x > flash.Lib.current.stage.stageWidth - rectangleWidth -1)
				a.x = flash.Lib.current.stage.stageWidth - rectangleWidth -1;
				else if( a.x <    0 )
				a.x = 0;
				if( a.y > flash.Lib.current.stage.stageHeight - rectangleHeight -1)
				a.y = flash.Lib.current.stage.stageHeight - rectangleHeight -1;
				else if( a.y <    0 )
				a.y = 0;
				   
				if(started) {

					if(a.x < b.x) {
						if((isCollision(b.x-3, b.width, b.y, b.height, t1.x, t1.width, t1.y, t1.height) && !t1b) ||
						(isCollision(b.x-3, b.width, b.y, b.height, t2.x, t2.width, t2.y, t2.height) && !t2b) ||
						(isCollision(b.x-3, b.width, b.y, b.height, t3.x, t3.width, t3.y, t3.height) && !t3b) ||
						(isCollision(b.x-3, b.width, b.y, b.height, t4.x, t4.width, t4.y, t4.height) && !t4b) ||
						(isCollision(b.x-3, b.width, b.y, b.height, t5.x, t5.width, t5.y, t5.height) && !t5b)) { 
							// don't move x
						}
						else {
							b.x += -3;
						}
						   
					} 
					else if (a.x > b.x){
						if((isCollision(b.x+3, b.width, b.y, b.height, t1.x, t1.width, t1.y, t1.height) && !t1b) ||
						(isCollision(b.x+3, b.width, b.y, b.height, t2.x, t2.width, t2.y, t2.height) && !t2b) ||
						(isCollision(b.x+3, b.width, b.y, b.height, t3.x, t3.width, t3.y, t3.height) && !t3b) ||
						(isCollision(b.x+3, b.width, b.y, b.height, t4.x, t4.width, t4.y, t4.height) && !t4b) ||
						(isCollision(b.x+3, b.width, b.y, b.height, t5.x, t5.width, t5.y, t5.height) && !t5b)) { 
							// don't move x
						}
						else {
							b.x += 3;
						}
						   
					}
					if(a.y < b.y) {
						if((isCollision(b.x, b.width, b.y-3, b.height, t1.x, t1.width, t1.y, t1.height) && !t1b) ||
						(isCollision(b.x, b.width, b.y-3, b.height, t2.x, t2.width, t2.y, t2.height) && !t2b) ||
						(isCollision(b.x, b.width, b.y-3, b.height, t3.x, t3.width, t3.y, t3.height) && !t3b) ||
						(isCollision(b.x, b.width, b.y-3, b.height, t4.x, t4.width, t4.y, t4.height) && !t4b) ||
						(isCollision(b.x, b.width, b.y-3, b.height, t5.x, t5.width, t5.y, t5.height) && !t5b)) { 
							// don't move y
						}
						else  {
							b.y += -3;
						}
					} 
					else if (a.y > b.y){
						if((isCollision(b.x, b.width, b.y+3, b.height, t1.x, t1.width, t1.y, t1.height) && !t1b) ||
						(isCollision(b.x, b.width, b.y+3, b.height, t2.x, t2.width, t2.y, t2.height) && !t2b) ||
						(isCollision(b.x, b.width, b.y+3, b.height, t3.x, t3.width, t3.y, t3.height) && !t3b) ||
						(isCollision(b.x, b.width, b.y+3, b.height, t4.x, t4.width, t4.y, t4.height) && !t4b) ||
						(isCollision(b.x, b.width, b.y+3, b.height, t5.x, t5.width, t5.y, t5.height) && !t5b)) { 
							// don't move y
						}
						else {
							b.y += 3;
						}
						  
					}
					tick++;
					if(tick > 40) {
						tick = 0;
						switchtimer--;
						if(switchtimer == 0) {
							redrawField();
							switchtimer = 5;
							var sound = Assets.getSound("assets/Switch.wav");
							sound.play (new SoundTransform(.3));
						}
						switchtext.updateText('Next Switch: '+switchtimer);
					}
				}				   
				
				// here we prevent rectangle b from moving out of the display area
				if( b.x > flash.Lib.current.stage.stageWidth - bWidth -1)
				b.x = flash.Lib.current.stage.stageWidth - bWidth -1;
				else if( b.x <    0 )
				b.x = 0;
				if( b.y > flash.Lib.current.stage.stageHeight - bHeight -1)
				b.y = flash.Lib.current.stage.stageHeight - bHeight -1;
				else if( b.y <    0 )
				b.y = 0;
				
				//Collision check for 
				if(isCollision(a.x, rectangleWidth, a.y, rectangleHeight, b.x, bWidth, b.y, bHeight) && !loss) {
					loss=true;
					var sound = Assets.getSound("assets/Death.wav");
					sound.play (new SoundTransform(.3));
					if(onkon) {kongregate.SubmitScore(score, "Easy");}
					winlosstext.updateText("Loss! (Press r to restart)");
					winlosstext.showText();
				}
				   
				//Victory check
				if (a.x > 700-75-1 && a.y > 525-75-1 && !win) {
					win=true;
					score++;
					var sound = Assets.getSound("assets/Portal.wav");
					sound.play (new SoundTransform(.3));
					if(onkon) {kongregate.SubmitScore(score, "Easy");}
					scoretext.updateText("Score: "+score);
					winlosstext.updateText("Win! (Press n to continue)");
					winlosstext.showText();
				}
			}

		}
	
	static function redrawField() {
		flash.Lib.current.removeChild(t1);
		t1.graphics.clear();
		if(Std.random(2) == 1) {
			t1.graphics.beginFill ( 0xffffff );
			t1.graphics.lineStyle ( 1, 0x000000, 1, false, flash.display.LineScaleMode.NONE );
			t1.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
			t1.graphics.endFill ();
			t1b = false;
		} 
		else {
			t1.graphics.beginFill ( 0x000000 );
			t1.graphics.lineStyle ( 1, 0xffffff, 1, false, flash.display.LineScaleMode.NONE );
			t1.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
			t1.graphics.endFill ();
			t1b = true;
		}
		var fits:Bool = false;
		var proph:Int = 0;
		var propw:Int = 0;
		var propx:Int = 0;
		var propy:Int = 0;
		while(!fits) {
			proph = 50+Std.random(51);
			propw = 50+Std.random(51);
			propx = Std.random(flash.Lib.current.stage.stageWidth+1-propw);
			propy = Std.random(flash.Lib.current.stage.stageHeight+1-proph);
			if((isCollision(a.x-5, a.width+10, a.y-5, a.height+10, propx, propw, propy, proph) && t1b) ||
			(isCollision(b.x-3, b.width+6, b.y-3, b.height+6, propx, propw, propy, proph) && !t1b) ||
			isCollision(724, 75, 449, 75, propx, propw, propy, proph)) {
				//try again
			}
			else {
				fits = true;
			}
		}
		t1.height = proph;
		t1.width = propw;
		t1.x = propx;
		t1.y = propy;
		flash.Lib.current.addChild(t1);
		
		flash.Lib.current.removeChild(t2);
		t2.graphics.clear();
		if(Std.random(2) == 1) {
			t2.graphics.beginFill ( 0xffffff );
			t2.graphics.lineStyle ( 1, 0x000000, 1, false, flash.display.LineScaleMode.NONE );
			t2.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
			t2.graphics.endFill ();
			t2b = false;
		} 
		else {
			t2.graphics.beginFill ( 0x000000 );
			t2.graphics.lineStyle ( 1, 0xffffff, 1, false, flash.display.LineScaleMode.NONE );
			t2.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
			t2.graphics.endFill ();
			t2b = true;
		}
		var fits:Bool = false;
		var proph:Int = 0;
		var propw:Int = 0;
		var propx:Int = 0;
		var propy:Int = 0;
		while(!fits) {
			proph = 50+Std.random(51);
			propw = 50+Std.random(51);
			propx = Std.random(flash.Lib.current.stage.stageWidth+1-propw);
			propy = Std.random(flash.Lib.current.stage.stageHeight+1-proph);
			if((isCollision(a.x-5, a.width+10, a.y-5, a.height+10, propx, propw, propy, proph) && t2b) ||
			(isCollision(b.x-3, b.width+6, b.y-3, b.height+6, propx, propw, propy, proph) && !t2b) ||
			isCollision(724, 75, 449, 75, propx, propw, propy, proph)) {
				//try again
			}
			else {
				fits = true;
			}
		}
		t2.height = proph;
		t2.width = propw;
		t2.x = propx;
		t2.y = propy;
		flash.Lib.current.addChild(t2);
		
		flash.Lib.current.removeChild(t3);
		t3.graphics.clear();
		if(Std.random(2) == 1) {
			t3.graphics.beginFill ( 0xffffff );
			t3.graphics.lineStyle ( 1, 0x000000, 1, false, flash.display.LineScaleMode.NONE );
			t3.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
			t3.graphics.endFill ();
			t3b = false;
		} 
		else {
			t3.graphics.beginFill ( 0x000000 );
			t3.graphics.lineStyle ( 1, 0xffffff, 1, false, flash.display.LineScaleMode.NONE );
			t3.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
			t3.graphics.endFill ();
			t3b = true;
		}
		var fits:Bool = false;
		var proph:Int = 0;
		var propw:Int = 0;
		var propx:Int = 0;
		var propy:Int = 0;
		while(!fits) {
			proph = 50+Std.random(51);
			propw = 50+Std.random(51);
			propx = Std.random(flash.Lib.current.stage.stageWidth+1-propw);
			propy = Std.random(flash.Lib.current.stage.stageHeight+1-proph);
			if((isCollision(a.x-5, a.width+10, a.y-5, a.height+10, propx, propw, propy, proph) && t3b) ||
			(isCollision(b.x-3, b.width+6, b.y-3, b.height+6, propx, propw, propy, proph) && !t3b) ||
			isCollision(724, 75, 449, 75, propx, propw, propy, proph)) {
				//try again
			}
			else {
				fits = true;
			}
		}
		t3.height = proph;
		t3.width = propw;
		t3.x = propx;
		t3.y = propy;
		flash.Lib.current.addChild(t3);
		
		flash.Lib.current.removeChild(t4);
		t4.graphics.clear();
		if(Std.random(2) == 1) {
			t4.graphics.beginFill ( 0xffffff );
			t4.graphics.lineStyle ( 1, 0x000000, 1, false, flash.display.LineScaleMode.NONE );
			t4.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
			t4.graphics.endFill ();
			t4b = false;
		} 
		else {
			t4.graphics.beginFill ( 0x000000 );
			t4.graphics.lineStyle ( 1, 0xffffff, 1, false, flash.display.LineScaleMode.NONE );
			t4.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
			t4.graphics.endFill ();
			t4b = true;
		}
		var fits:Bool = false;
		var proph:Int = 0;
		var propw:Int = 0;
		var propx:Int = 0;
		var propy:Int = 0;
		while(!fits) {
			proph = 50+Std.random(51);
			propw = 50+Std.random(51);
			propx = Std.random(flash.Lib.current.stage.stageWidth+1-propw);
			propy = Std.random(flash.Lib.current.stage.stageHeight+1-proph);
			if((isCollision(a.x-5, a.width+10, a.y-5, a.height+10, propx, propw, propy, proph) && t4b) ||
			(isCollision(b.x-3, b.width+6, b.y-3, b.height+6, propx, propw, propy, proph) && !t4b) ||
			isCollision(724, 75, 449, 75, propx, propw, propy, proph)) {
				//try again
			}
			else {
				fits = true;
			}
		}
		t4.height = proph;
		t4.width = propw;
		t4.x = propx;
		t4.y = propy;
		flash.Lib.current.addChild(t4);
		
		flash.Lib.current.removeChild(t5);
		t5.graphics.clear();
		if(Std.random(2) == 1) {
			t5.graphics.beginFill ( 0xffffff );
			t5.graphics.lineStyle ( 1, 0x000000, 1, false, flash.display.LineScaleMode.NONE );
			t5.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
			t5.graphics.endFill ();
			t5b = false;
		} 
		else {
			t5.graphics.beginFill ( 0x000000 );
			t5.graphics.lineStyle ( 1, 0xffffff, 1, false, flash.display.LineScaleMode.NONE );
			t5.graphics.drawRect ( 0, 0, 25+Std.random(51), 25+Std.random(51));
			t5.graphics.endFill ();
			t5b = true;
		}
		var fits:Bool = false;
		var proph:Int = 0;
		var propw:Int = 0;
		var propx:Int = 0;
		var propy:Int = 0;
		while(!fits) {
			proph = 50+Std.random(51);
			propw = 50+Std.random(51);
			propx = Std.random(flash.Lib.current.stage.stageWidth+1-propw);
			propy = Std.random(flash.Lib.current.stage.stageHeight+1-proph);
			if((isCollision(a.x-5, a.width+10, a.y-5, a.height+10, propx, propw, propy, proph) && t5b) ||
			(isCollision(b.x-3, b.width+6, b.y-3, b.height+6, propx, propw, propy, proph) && !t5b) ||
			isCollision(724, 75, 449, 75, propx, propw, propy, proph)) {
				//try again
			}
			else {
				fits = true;
			}
		}
		t5.height = proph;
		t5.width = propw;
		t5.x = propx;
		t5.y = propy;
		flash.Lib.current.addChild(t5);
	}
	
	static function isCollision(ax:Float, aw, ay:Float, ah, bx:Float, bw, by:Float, bh) {
		if( ax + aw >= bx && ax < bx + bw && ay + ah >= by && ay < by + bh) {
			return true;
		}
		else {
			return false;
		}
	}
	
}


class MyText {
	public var textObj:TextField;

	public function new(x:Int, y:Int, size:Int, color:Int, text:String, glow:Bool) {
		this.textObj = new TextField();
		this.textObj.x = x;
		this.textObj.y = y;
		var font = Assets.getFont("assets/EHSMB.TTF");
		this.textObj.defaultTextFormat =  new TextFormat(font.fontName, size, color);
		this.textObj.embedFonts = true; 
		this.textObj.text = text;
		this.textObj.width = 640;
		if(glow) {
			this.textObj.filters = [ new  GlowFilter(0xaa0000, 1.0, 6, 6, 6, 6, false, false) ];
		}
		flash.Lib.current.addChild(this.textObj);
	}

	public function updateText(text:String) {
		this.textObj.text = text;
	}

	public function hideText() {
		flash.Lib.current.removeChild(this.textObj);
	}
	public function showText() {
		flash.Lib.current.addChild(this.textObj);
	}
}

class CKongregate 
{
	var kongregate: Dynamic;

	public function new()
	{
		kongregate = null;
		var parameters = flash.Lib.current.loaderInfo.parameters;
		var url: String;
		url = parameters.api_path;
		if(url == null)
		url = "http://www.kongregate.com/flash/API_AS3_Local.swf";
		var request = new flash.net.URLRequest(url);             
		var loader = new flash.display.Loader();
		loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, OnLoadComplete);
		loader.load(request);
		flash.Lib.current.addChild(loader);
	}

	function OnLoadComplete(e: flash.events.Event)
	{
		try
		{
			kongregate = e.target.content;
			kongregate.services.connect();
		}
		catch(msg: Dynamic)
		{
			kongregate = null;
		}
	}

	public function SubmitScore(score: Float, mode: String)
	{
		if(kongregate != null)
		{
			kongregate.scores.submit(score, mode);
		}
	}

	public function SubmitStat(name: String, stat: Float)
	{
		if(kongregate != null)
		{
			kongregate.stats.submit(name, stat);
		}
	}

}

