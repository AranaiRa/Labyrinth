package as3 {
	
	import flash.display.MovieClip;
	
	public class Pickup extends MovieClip {
		
		public static var HPUP:int = 1;
		public static var ATKUP:int = 2;
		public static var ENERGYATKUP:int = 3;
		public static var SPDUP:int = 4;
		public static var ENERGYUP:int = 5;
		
		var amount:int;
		var type:int;
		
		var aabb:AABB;
		var worldX:Number, worldY:Number;
		
		var a:Number = 1500;
		var speedX:Number = 0;
		var speedY:Number = 0;
		var moving:Boolean = true;
		
		var pickupDelay:Number = .3;
		var canPickup:Boolean = false;
		
		public function Pickup(x:Number, y:Number){
			type = Random.ChooseOne([Pickup.HPUP, Pickup.ATKUP, Pickup.ENERGYATKUP, Pickup.SPDUP, Pickup.ENERGYUP]);
			amount = Random.ChooseOne([1, 3, 5]); // possible values
			width *= (amount/2);
			height *= (amount/2);
			gotoAndStop(type);
			
			speedX = Random.Range(-20, 20);
			speedY = Random.Range(-30, 40);
			
			worldX = x;
			worldY = y;
			
			aabb = new AABB(worldX, worldY, width, height);
		}
		
		public function Update(dt:Number, cam:Camera):void{
			
			pickupDelay -= dt;
			if(pickupDelay <= 0) canPickup = true;
			
			if(moving){
				speedX *= .8;
				speedY *= .8;
				
				if(Math.abs(speedX) < .5 && Math.abs(speedY) < .5){
					speedX = 0;
					speedY = 0;
					moving = false;
				}
			}
			
			if(aabb.Bottom + speedY * dt > Config.StageHeight){
				worldY = Config.StageHeight - aabb.halfH;
				speedY = 0;
			}
			
			worldX += speedX;
			worldY += speedY;
			
			this.x = worldX + cam.x;
			this.y = worldY + cam.y;
			
			aabb.Update(worldX, worldY);
		}
	}
}
