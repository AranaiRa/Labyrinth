package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class Enemy extends MovieClip {
		
		public static var TURRET:int = 1;
		public static var HOPPER:int = 2;
		public static var AERIAL:int = 3;
		public static var RANGER:int = 4;
		
		var health:int = 0;
		
		var aabb:AABB;
		
		var grounded:Boolean = false;
		
		var speedX:Number = 0;
		var speedY:Number = 0;
		var maxSpeedX:Number = 500;
		var maxSpeedY:Number = 650;
		var a:Number = 1500;
		var damage:int = 10; // overwrite later
		var invulnerable:Boolean = false;
		var hurtOnContact:Boolean = false;
		var bullet:EnemyBullet;
		
		var worldX:Number, worldY:Number;

		public function Enemy(x:Number, y:Number, w:Number, h:Number, hp:int) {
			aabb = new AABB(x, y, w, h);
			worldX = x;
			worldY = y;
			health = hp;
		}
		
		public function Update(dt:Number, cam:Camera, player:Player):void{
						
			this.x = worldX + cam.x;
			this.y = worldY + cam.y;
			
			aabb.Update(worldX, worldY);
		}		
		
		public function DropPickups():Array{
			var pickups:Array = new Array();
			var numToSpawn:int = Random.Range(1, 5);
			for(var i:int = 0; i < numToSpawn; i++){
				var rx:Number = Random.Range(aabb.Left, aabb.Right);
				var ry:Number = Random.Range(aabb.Top, aabb.Bottom);
				pickups.push(new Pickup(rx, ry));
			}
			return pickups;
		}
	}
}
