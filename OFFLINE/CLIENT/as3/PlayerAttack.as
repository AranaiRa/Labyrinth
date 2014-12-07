package as3 {
	
	import flash.display.MovieClip;
	import flash.utils.*;
	
	public class PlayerAttack extends MovieClip {
		
		var aabb:AABB;
		var worldX:Number;
		var worldY:Number;
		// tracks the amount of time before cleanup
		var interval:uint;
		// attack power attached to the attack
		var power:int;
						
		public function PlayerAttack(x:Number, y:Number, w:Number, h:Number, pow:int) {
			worldX = x;
			worldY = y;
			aabb = new AABB(worldX, worldY, w, h);
			width = w;
			height = h;
			power = pow;
			// sets how long the object exists
			interval = setInterval(CleanUp, 200);
		}
		
		public function Update(cam:Camera):void{
			
			this.x = worldX + cam.x;
			this.y = worldY + cam.y;
			
			aabb.Update(worldX, worldY);
		}
		
		// deletes the object and removes the interval
		function CleanUp():void{
			clearInterval(interval);
			this.parent.removeChild(this);
		}
	}
}
