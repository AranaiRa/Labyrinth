package as3 {
	
	import flash.display.MovieClip;
	
	
	public class EnemyTurret extends Enemy {
		
		var moveRight:Boolean = false;
		var moveLeft:Boolean = false;
		
		var bulletTimer:Number = 2;
		var bulletTimerMax:Number = 2;
						
		public function EnemyTurret(x:Number, y:Number) {
			worldX = x;
			worldY = y;
			
			super(x, y, width, height, 100);
			
			super.maxSpeedX = 350;
			super.maxSpeedY = 450;
		}
		
		public override function Update(dt:Number, cam:Camera, player:Player):void{
			// shoot
			bulletTimer -= dt;
			if(bulletTimer <= 0){
				var playerToTheRight:Boolean = player.worldX > this.worldX;
				var degrees = 180;
				if (playerToTheRight) degrees = 0;
				var spX:Number = -1;
				if(playerToTheRight) spX = 1;
				bullet = new EnemyBullet(worldX, worldY, spX, 0, degrees);
				bulletTimer = bulletTimerMax;
			}
			//
			
			// y movement
			if(!grounded) speedY += a * dt;
			if(worldY + speedY * dt > Config.StageHeight - aabb.halfH*2){
				worldY = Config.StageHeight - aabb.halfH*2;
				speedY = 0;
				grounded = true;
			}
			//
			
			worldX += speedX * dt;
			worldY += speedY * dt;
		
			super.Update(dt, cam, player);			
		}
	}	
}
