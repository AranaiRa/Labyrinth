package as3 {
	
	import flash.display.MovieClip;
	
	
	public class EnemyRanger extends Enemy {
		
		var targetX:Number;
		var safeDistance:Number = 230;
		
		var bulletTimer:Number = .5;
		var bulletTimerMax:Number = .5;
		
		public function EnemyRanger(x:Number, y:Number) {
			worldX = x;
			targetX = x;
			worldY = y;
			
			super(x, y, width, height, 100);
			
			super.maxSpeedY = 450;
			
			// rapid update to put it on the ground?
		}
		
		private function Jump(){
			grounded = false;
			speedY = -maxSpeedY;
		}
		
		public override function Update(dt:Number, cam:Camera, player:Player):void{
			// face player
			var playerToTheRight:Boolean = player.worldX > this.worldX;
			if(playerToTheRight) scaleX = -1;
			else scaleX = 1;
				
			// shoot
			bulletTimer -= dt;
			if(bulletTimer <= 0){				
				var disX:Number = (player.worldX - this.worldX);
				var disY:Number = (player.worldY - this.worldY);
	
				// check to move away from or towards player
				var disX2:Number = (disX * disX);
				var disY2:Number = (disY * disY);
				var hypot:Number = Math.sqrt(disX2 + disY2);
				if(hypot < safeDistance){ // move away from player
					if(playerToTheRight){
						targetX = worldX - safeDistance * (3/5);
					}else{
						targetX = worldX + safeDistance * (3/5);
					}
				}else if(hypot > safeDistance * 1.5){ // move toward player
					if(playerToTheRight){
						targetX = worldX + safeDistance * (3/5);
					}else{
						targetX = worldX - safeDistance * (3/5);
					}
				}
				//
				
				var radians:Number = Math.atan(disY/disX);
				var degrees:Number = (radians/3.14159) * 180;
				if(playerToTheRight) degrees = 0 - degrees;
				arm.rotation = degrees;
				
				var spX:Number = Math.cos(radians);
				var spY:Number = Math.sin(radians);
			
				if(!playerToTheRight){
					spY = Math.sin(radians + 3.14159);
					spX *= -1;
				}
				bullet = new EnemyBullet(worldX, worldY, spX, spY, degrees);
				bulletTimer = bulletTimerMax;
			}
			//
			
			// x movement
				speedX = (targetX - worldX)/2;
				speedX *= 5;
			//
			
			// y movement
			if(!grounded) speedY += a * dt;
			if(worldY + speedY * dt > Config.Ground){
				worldY = Config.Ground;
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
