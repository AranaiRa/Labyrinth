﻿package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;
	
	public class Player extends MovieClip {
		// true when jump_intro is playing; false to indicate that jump_up should play
		var jumpIntroPlaying:Boolean = true;
		
		var JUMP_INTRO:int = 1;
		var JUMP_UP:int = 7;
		var JUMP_SWITCH:int = 8;
		var JUMP_FALL:int = 9;
		var IDLE:int = 10;
		
		public var index:int;
		var aabb:AABB;
		var worldX:Number, worldY:Number;
		var speedX:Number = 0;
		var speedY:Number = 0;
		var maxSpeedX:Number = 500;
		var maxSpeedY:Number = 650;
		var a:Number = 1500;
		
		var grounded:Boolean = false;
		
		var jumpJuice:Number;
		var jumpJuiceMax:Number = 1.8;
		
		var hasJetpack:Boolean = false;
		var hasDoubleJump:Boolean = true;
		var jumpsLeft:int = 2;
		
		// stats
		var health:int = 100;
		var maxHealth:int = 100;
		var hurtTimer:Number = 0;
		var hurtTimerMax:Number = 1.5;
		var damageMultiplier:Number = 1;
		var energyMultiplier:Number = 1;
		var speedMultiplier:Number = 1;
		
		// ui
		var healthMeter:HealthMeter = new HealthMeter();
		
		// attack zones
		public var attacks = new Array();
		public var isAttacking:Boolean = false;
		
		public function Player(x:int, y:int, index:int) {
			jumpJuice = 0;
			gotoAndPlay(2);
			this.index = index;
			if(index == 1 && stage) Init();
			else if(index == 1) addEventListener(Event.ADDED_TO_STAGE, Init);
			this.x = x;
			this.y = y;
			
			worldX = x;
			worldY = y;
			aabb = new AABB(x - width/2, y - height, width, height);
		}
		
		public function Init(e:Event = null):void{
			if(index == 1){
				removeEventListener(Event.ADDED_TO_STAGE, Init);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
				stage.addEventListener(KeyboardEvent.KEY_UP, KeyUp)
			
				if(index == 1) parent.addChild(healthMeter);
			}
		}
		
		public function KeyDown(e:KeyboardEvent):void{
			if(index == 1) Keys.KeyPressed(e, true);
		}
		
		public function KeyUp(e:KeyboardEvent):void{
			if(index == 1) Keys.KeyPressed(e, false);
		}
		
		public function AddHealth(amount:int):void{
			// add health proportionally
			var percentage:Number = health/maxHealth;
			maxHealth += amount;
			health = Math.ceil(maxHealth * percentage);
			healthMeter.Update(health, maxHealth);
			// TODO: Add text to health bar?
		}
		
		public function Hurt(amount:int):void{
			if(index == 1 && hurtTimer <= 0){
				hurtTimer = hurtTimerMax;
				health -= amount;
				if(health < 0) health = 0;
				healthMeter.Update(health, maxHealth);
				
				if(health <= 0){
					// death! woo!
				}
			}
		}
		
		public function Heal(amount:int):void{
			health += amount;
			if(health > maxHealth) health = maxHealth;
			
			healthMeter.Update(health, maxHealth);
		}
		
		private function Jump(){
			jumpJuice = jumpJuiceMax;
			speedY = -maxSpeedY;
			gotoAndPlay(JUMP_INTRO);
			jumpIntroPlaying = true;
			grounded = false;
			jumpsLeft--;
		}
		
		public function Land(){
				grounded = true;
				speedY = 0;
				jumpsLeft = 2;
		}
		
		public function Update(dt:Number, cam:Camera, level:Level):void{
			if(index == 1) Update1(dt, level);
			if(index == 2) Update2(dt, cam, level);
			UpdateAnimations();
		}
		
		public function Update1(dt:Number, level:Level):void{
			if(hurtTimer >= 0) hurtTimer -= dt;
			
			if(Keys.Left){
				scaleX = 1;
				speedX -= a * dt;
			}else if(Keys.Right){
				scaleX = -1;
				speedX += a * dt;
				
			}else{
				speedX *= .8;
			}
			
			if(speedX > maxSpeedX) speedX = maxSpeedX;
			if(speedX < -maxSpeedX) speedX = -maxSpeedX;
			
			worldX += speedX * dt;
			// End Horizontal Movement
			
			// Vertical Movement			
			if(hasJetpack && Keys.Jump){
				speedY -= a * dt * (Config.Gravity + 1);
				grounded = false;
			}else if(Keys.Jump && !Keys.JumpPrev && grounded){
				Jump();
			}else if(hasDoubleJump && Keys.Jump && !Keys.JumpPrev && jumpsLeft > 0){
				Jump();
			}
			if(!grounded){
				speedY += a * dt * Config.Gravity;
				speedY -= jumpJuice * 40;
				jumpJuice -= dt;
				if(jumpJuice < 0) jumpJuice = 0;
				
				if(!Keys.Jump) jumpJuice = 0;
				
				if(speedY > maxSpeedY*2) speedY = maxSpeedY*2; // falling
				if(speedY < -maxSpeedY) speedY = -maxSpeedY; // rising
				
			}
			
			if(worldY + speedY * dt > Config.StageHeight){
				worldY = Config.StageHeight;
				speedY = 0;
				grounded = true;
			}
			worldY += speedY * dt;
			// End Vertical Movement
			
			// Attack logic
			isAttacking = false;
			if(Keys.OnPress("Attack1")){
				GenerateBasicAttackField();
				isAttacking = true;
				//trace("DEBUG: Attack1 pushed");
			}
			else if(Keys.OnPress("Energy1")){
				GenerateFrontalAttackField();
				isAttacking = true;
				trace("DEBUG: Energy1 pushed");
			}
			else if(Keys.OnPress("Energy2")){
				GenerateRadialAttackField();
				isAttacking = true;
				trace("DEBUG: Energy2 pushed");
			}
			// End attack logic
			
			aabb.Update(worldX, worldY);
			level.FixCollisions(this);
			
			Keys.Update();
		}
		
		public function Update2(dt:Number, cam:Camera):void{
			
			
			if(aabb.Bottom >= Config.Ground){
				worldY = Config.Ground;
				grounded = true;
				speedY = 0;
			}
			
			if(!grounded){
				speedY += a * dt;
			}
			worldY += speedY * dt;
			
			this.x = worldX + cam.x;
			this.y = worldY + cam.y;
			
			
			
			aabb.Update(worldX, worldY);
			
			
			
		}
		
		public function UpdateAnimations():void{
			if(jumpIntroPlaying && currentFrame == JUMP_UP){ // intro is done playing
				jumpIntroPlaying = false;
			}
			else if(speedY < -70 && !jumpIntroPlaying){ // rising
				gotoAndStop(JUMP_UP);
			}
			else if(speedY > -70 && speedY < 70){ // switch frame
				gotoAndStop(JUMP_SWITCH);
			}
			else if(speedY > 70){ // falling
				gotoAndStop(JUMP_FALL);
			}
		}
		
		// collision response to level
		public function FixCollisionWithStaticAABB
		(other:AABB, omitTop:Boolean, omitRight:Boolean, omitBottom:Boolean, omitLeft:Boolean):void{
			
			if(this.aabb.Right < other.Left) return;
			if(this.aabb.Left > other.Right) return;
			if(this.aabb.Bottom < other.Top) return;
			if(this.aabb.Top > other.Bottom) return;
			
			var overlapB1:Number = other.Bottom - aabb.Top; // distance to move down; OVERLAP B
			var overlapT1:Number = other.Top - aabb.Bottom; // distance to move up; OVERLAP T
			var overlapR1:Number = other.Right - aabb.Left; // distance to move right; OVERLAP R
			var overlapL1:Number = other.Left - aabb.Right; // distance to move left; OVERLAP L

			var overlapB:Number = Math.abs(overlapB1);
			var overlapT:Number = Math.abs(overlapT1);
			var overlapR:Number = Math.abs(overlapR1);
			var overlapL:Number = Math.abs(overlapL1);

			var solutionX:Number = 0;
			var solutionY:Number = 0;

			// find solution
			if (!omitTop && overlapT <= overlapB && overlapT <= overlapR && overlapT <= overlapL) {
				// your bottom side collided
				solutionY = overlapT1;
				Land();
				
			}
			if (!omitRight && overlapR <= overlapT && overlapR <= overlapB && overlapR <= overlapL) {
				// your left side collided
				solutionX = overlapR1;
				speedX = 0;
				
			}
			if (!omitBottom && overlapB <= overlapT && overlapB <= overlapR && overlapB <= overlapL) {
				// your top side collided
				solutionY = overlapB1;
				speedY = 0;
				
			}
			if (!omitLeft && overlapL <= overlapT && overlapL <= overlapR && overlapL <= overlapB) {
				// your right side collided
				solutionX = overlapL1;
				speedX = 0;

			}
			
			worldX += solutionX;
			worldY += solutionY;
			
			aabb.Update(worldX, worldY);
		}
		
		public function GenerateBasicAttackField():void{
			attacks = new Array();
			var px;
			var py;
			var pw;
			var ph;
			
			px = -(Config.TileSize * 0.5);
			py = 0;
			pw = Config.TileSize * 2;
			ph = Config.TileSize;
			
			attacks.push(new PlayerAttack(worldX + px, worldY + py, pw, ph));
		}
		
		public function GenerateForwardAttackField():void{
			var pb1:PixelBasic = new PixelBasic();
			pb1.width = Config.TileSize * 4;
			pb1.height = Config.TileSize;
			pb1.x -= Config.TileSize * 2.5;
			pb1.y -= Config.TileSize / 2;
			
			this.addChild(pb1);
		}
		
		public function GenerateFrontalAttackField():void{
			var pb1:PixelBasic = new PixelBasic();
			pb1.width = Config.TileSize * 2;
			pb1.height = Config.TileSize * 3;
			pb1.x -= Config.TileSize * 1.5;
			pb1.y -= Config.TileSize * 1.5;
			
			this.addChild(pb1);
		}
		
		public function GenerateRadialAttackField():void{
			var pb1:PixelBasic = new PixelBasic();
			pb1.width = Config.TileSize * 3;
			pb1.height = Config.TileSize * 3;
			pb1.x -= Config.TileSize * 1.5;
			pb1.y -= Config.TileSize * 1.5;
			
			var pb2:PixelBasic = new PixelBasic();
			pb2.width = Config.TileSize;
			pb2.height = Config.TileSize;
			pb2.x -= Config.TileSize / 2;
			pb2.y -= Config.TileSize * 2.5;
		
			var pb3:PixelBasic = new PixelBasic();
			pb3.width = Config.TileSize;
			pb3.height = Config.TileSize;
			pb3.x -= Config.TileSize / 2;
			pb3.y += Config.TileSize * 1.5;
		
			var pb4:PixelBasic = new PixelBasic();
			pb4.width = Config.TileSize;
			pb4.height = Config.TileSize;
			pb4.x -= Config.TileSize * 2.5;
			pb4.y -= Config.TileSize / 2;
		
			var pb5:PixelBasic = new PixelBasic();
			pb5.width = Config.TileSize;
			pb5.height = Config.TileSize;
			pb5.x += Config.TileSize * 1.5;
			pb5.y -= Config.TileSize / 2;
		
			this.addChild(pb1);
			this.addChild(pb2);
			this.addChild(pb3);
			this.addChild(pb4);
			this.addChild(pb5);
		}
	}
}