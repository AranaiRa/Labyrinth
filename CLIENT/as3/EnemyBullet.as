package as3 {
	
	import flash.display.MovieClip;
	
	
	public class EnemyBullet extends Enemy {
		
		var moveRight:Boolean = false;
		var moveLeft:Boolean = false;
						
		public function EnemyBullet(x:Number, y:Number, spX:Number, spY:Number, degrees:Number) {
			worldX = x;
			worldY = y;
			
			super(x, y, width, height, 100);
			
			super.speedX = 300 * spX;
			super.speedY = 300 * spY;
			super.invulnerable = true;
			super.hurtOnContact = true;
			rotation = degrees;
			if(speedX > 0) rotation = 0 - rotation;
			
			// TODO: culling based on camera?
		}
		
		public override function Update(dt:Number, cam:Camera, player:Player):void{
			
			worldX += speedX * dt;
			worldY += speedY * dt;
		
			super.Update(dt, cam, player);			
		}
	}
}
