package as3 {
	
	import flash.display.MovieClip;
	import flash.utils.*;
	
	public class PlayerAttack extends MovieClip {
		
		var aabb:AABB;
		var worldX:Number;
		var worldY:Number;
		var interval:uint;
						
		public function PlayerAttack(x:Number, y:Number, w:Number, h:Number) {
			worldX = x;
			worldY = y;
			aabb = new AABB(worldX, worldY, w, h);
			width = w;
			height = h;
			interval = setInterval(CleanUp, 200);
		}
		
		public function Update(cam:Camera):void{
			
			this.x = worldX + cam.x;
			this.y = worldY + cam.y;
			
			aabb.Update(worldX, worldY);
		}
		
		function CleanUp():void{
			clearInterval(interval);
			this.parent.removeChild(this);
		}
	}
}
