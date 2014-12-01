package as3 {
	
	import flash.display.MovieClip;
	
	
	public class EnemyAerial extends Enemy {
		
		var moveRight = false;
		var moveLeft = false;
				
		public function EnemyAerial(x:Number, y:Number) {
			worldX = x;
			worldY = y;
			
			super(x, y, width, height, 100);
			
			super.maxSpeedX = 350;
			super.maxSpeedY = 450;
			super.hurtOnContact = true;
		}
		
		private function Jump(){
			grounded = false;
			speedY = -maxSpeedY;
		}
		
		public override function Update(dt:Number, cam:Camera, player:Player):void{
			if(!grounded){
				speedY += a * dt;
				
				if(moveRight){
					speedX += this.a * dt;
				}
				else if(moveLeft){
					speedX -= this.a * dt;
				}else{
					speedX *= .85;
				}
				
				if(player.worldX > this.worldX) moveLeft = false;
				if(player.worldX < this.worldX) moveRight = false;
				
				if(speedX > maxSpeedX) speedX = maxSpeedX;
				if(speedX < -maxSpeedX) speedX = -maxSpeedX;
			}else{
				if(player.worldX > this.worldX){
					moveRight = true;
					moveLeft = false;
				}
				if(player.worldX < this.worldX){
					moveRight = false;
					moveLeft = true;
				}
			}
			
			if(worldY + speedY * dt > Config.StageHeight - aabb.halfH*2){
				
			}
			
			worldX += speedX * dt;
			worldY += speedY * dt;
		
			super.Update(dt, cam, player);			
		}
	}	
}
