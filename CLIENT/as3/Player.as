package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.Point;
	
	public class Player extends MovieClip {
		// true when jump_intro is playing; false to indicate that jump_up should play
		
		var index:int;
		//**************
		var worldX:Number, worldY:Number;
		var lastX:Number, lastY:Number;
		
		// stats
		var lives:int = 3;
		var health:int = 100;
		var maxHealth:int = 100;
		var energy:int = 100;
		var maxEnergy:int = 100;

		var hurtTimer:Number = 0;
		var hurtTimerMax:Number = 1.5;
		//****************
		
		// ui
		var healthMeter:HealthMeter = new HealthMeter();
		var energyMeter:EnergyMeter = new EnergyMeter();
		
		public function Player(index:int) {
			this.index = index;
			if(index == 1 && stage) Init();
			else if(index == 1) addEventListener(Event.ADDED_TO_STAGE, Init);
			this.x = x;
			this.y = y;
			
			worldX = x;
			worldY = y;
		}
		
		public function Init(e:Event = null):void{
			if(index == 1){
				removeEventListener(Event.ADDED_TO_STAGE, Init);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, KeyUp)
			
				if(index == 1){
					//parent.addChildAt(healthMeter, Layer.UI);
					//parent.addChildAt(energyMeter, Layer.UI);
					parent.addChild(healthMeter);
					parent.addChild(energyMeter);
				}
			}
		}
		
		public function KeyDown(e:KeyboardEvent):void{
			if(index == 1){
				Keys.KeyPressed(e, true);
			}
		}
		
		public function KeyUp(e:KeyboardEvent):void{
			if(index == 1){
				Keys.KeyPressed(e, false);
			}
		}

		public function UpdateStats(hp:uint, maxhp:uint, energy:uint, maxenergy:uint):void{
			this.health = hp;
			this.maxHealth = maxhp;
			this.energy = energy;
			this.maxEnergy = maxenergy;

			healthMeter.Update(health, maxHealth);
			energyMeter.Update(energy, maxenergy);	
		}
		
		public function Update(cam:Camera):void{
			if(index == 1) Update1();
			if(index == 2) Update2(cam);
		}
		
		public function Update1():void{			
			Keys.Update();
			if(Keys.Left) scaleX = 1;
			if(Keys.Right) scaleX = -1;
		}
		
		public function Update2(cam:Camera):void{	
			if(worldX > lastX) scaleX = -1;
			if(worldX < lastX) scaleX = 1;

			this.x = worldX + cam.x;
			this.y = worldY + cam.y;
			this.lastX = worldX;
		}
	}
}
