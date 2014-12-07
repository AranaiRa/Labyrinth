package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class Enemy extends MovieClip {
		
		public static var TURRET:int = 1;
		public static var HOPPER:int = 2;
		public static var AERIAL:int = 3;
		public static var RANGER:int = 4;
		public static var BULLET:int = 5;

		var targetPlayer:Player;
		
		var worldX:Number, worldY:Number;

		public function Enemy() {
			x = -100;
			y = -100;
			worldX = -100;
			worldY = -100;
		}
		
		public function Update(cam:Camera, player:Player):void{
			this.x = worldX + cam.x;
			this.y = worldY + cam.y;
		}
	}
}
