package as3 {
	
	import flash.display.MovieClip;
	
	public class Pickup extends MovieClip {
		
		public static var HPUP:int = 1;
		public static var ATKUP:int = 2;
		//public static var ENERGYATKUP:int = 3;
		public static var SPDUP:int = 4;
		public static var ENERGYUP:int = 5;
		
		var amount:int;
		var type:int;
		
		var worldX:Number, worldY:Number;
		
		public function Pickup(pType:int, amount:int){
			this.type = pType;
			this.amount = amount;
			width *= (amount/2);
			height *= (amount/2);
			gotoAndStop(type);
		}
		
		public function Update(cam:Camera):void{
			this.x = worldX + cam.x;
			this.y = worldY + cam.y;
		}
	}
}
