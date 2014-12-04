package as3 {
	
	import flash.display.MovieClip;
	
	
	public class EnemyAerial extends Enemy {
		
		var moveRight = false;
		var moveUp = false;
		var vec:Number = 0.075;
				
		public function EnemyAerial(x:Number, y:Number) {
			worldX = x;
			worldY = y;
			
			var r:int = Random.ChooseOne([1, 2]);
			var u:int = Random.ChooseOne([1, 2]);
			if(r == 1) moveRight = true;
			if(u == 1) moveUp = true;
			
			super(x, y, width, height, 100);
			
			super.maxSpeedX = 350;
			super.maxSpeedY = 450;
			super.hurtOnContact = true;
		}
		
		public override function Update(dt:Number, cam:Camera, player:Player):void{
			if(moveRight) worldX += this.a * dt * vec;
			else          worldX -= this.a * dt * vec;
			if(moveUp) worldY -= this.a * dt * vec;
			else       worldY += this.a * dt * vec;
		
			super.Update(dt, cam, player);			
		}
	}	
}
