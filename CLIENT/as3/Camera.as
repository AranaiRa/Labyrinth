package as3 {
	
	public class Camera {

		var x:Number, y:Number;
		var halfW:int, halfH:int;

		public function Camera() {
			halfW = Config.StageWidth/2;
			halfH = Config.StageHeight/2;
		}
		
		public function Update(targetX:Number, targetY:Number){
			x = -targetX + halfW;
			y = -targetY + halfH;
		}
	}
}
