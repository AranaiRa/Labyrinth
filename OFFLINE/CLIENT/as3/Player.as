package as3 {
	
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
		var hasBuzzsaw:Boolean = false;
		var jumpsLeft:int = 2;
		
		// stats
		var lives:int = 3;
		var health:int = 100;
		var maxHealth:int = 100;
		var energy:int = 100;
		var maxEnergy:int = 100;
		var hurtTimer:Number = 0;
		var hurtTimerMax:Number = 1.5;
		var damageMultiplier:Number = 1;
		var energyMultiplier:Number = 1;
		var speedMultiplier:Number = 1;
		var regeneration:Number = 0;
		
		// ui
		var healthMeter:HealthMeter = new HealthMeter();
		var energyMeter:EnergyMeter = new EnergyMeter();
		
		// attack zones
		public var attacks = new Array();
		public var isAttacking:Boolean = false;
		
		// stats
		public var HP:int     = 0;
		public var ATK:int    = 0;
		public var ENATK:int  = 0;
		public var SPD:int    = 0;
		public var ENERGY:int = 0;
		
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
			
				if(index == 1) {
					parent.addChild(healthMeter);
					parent.addChild(energyMeter);
					energyMeter.y += 15;
				}
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
		
		public function Drain(amount:int):void{
			if(index == 1 && hurtTimer <= 0){
				hurtTimer = hurtTimerMax;
				energy -= amount;
				if(energy < 0) energy = 0;
				energyMeter.Update(energy, maxEnergy);
			}
		}
		
		public function Restore(amount:int):void{
			energy += amount;
			if(energy > maxEnergy) energy = maxEnergy;
			
			healthMeter.Update(energy, maxEnergy);
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
			if(index == 2) Update2(dt, cam);
			UpdateAnimations();
		}
		
		public function Update1(dt:Number, level:Level):void{
			if(hurtTimer >= 0) hurtTimer -= dt;
			regeneration += maxEnergy * 0.6 * dt;
			if(regeneration > 1){
				regeneration--;
				energy++;
				energyMeter.Update(energy, maxEnergy);
				if(energy > maxEnergy-1) energy = maxEnergy-1;
			}
			
			if(Keys.Left){
				scaleX = 1;
				speedX -= a * dt * speedMultiplier;
			}else if(Keys.Right){
				scaleX = -1;
				speedX += a * dt * speedMultiplier;
				
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
				if(hasBuzzsaw)
					GenerateLateralAttackField();
				else
					GenerateBasicAttackField();
			}
			else if(Keys.OnPress("Energy1")){
				GenerateFrontalAttackField();
			}
			else if(Keys.OnPress("Energy2")){
				GenerateRadialAttackField();
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
		
		// Loads the player's attacks array for a basic attack. Replaced by the buzzsaw.
		public function GenerateBasicAttackField():void{
			attacks = new Array();
			var px;
			var py;
			var pw;
			var ph;
			
			if(Keys.FacingLeft)
				px = -(Config.TileSize * 0.5);
			else
				px = (Config.TileSize * 0.5);
			py = 0;
			pw = Config.TileSize * 2;
			ph = Config.TileSize;
			
			attacks.push(new PlayerAttack(worldX + px, worldY + py, pw, ph, ATK));
			isAttacking = true;
		}
		
		// Loads the player's attacks array for a lateral attack. Costs 20 Energy.
		public function GenerateLateralAttackField():void{
			attacks = new Array();
			if(energy >= 20){
				energy -= 20;
				attacks = new Array();
				var px;
				var py;
				var pw;
				var ph;
				
				if(Keys.FacingLeft)
					px = -(Config.TileSize * 0.5);
				else
					px = (Config.TileSize * 0.5);
				py = 0;
				pw = Config.TileSize * 4;
				ph = Config.TileSize;
				
				attacks.push(new PlayerAttack(worldX + px, worldY + py, pw, ph, ATK));
				isAttacking = true;
			}
			energyMeter.Update(energy, maxEnergy);
		}
		
		// Loads the player's attacks array for a frontal attack. Costs 35 Energy.
		public function GenerateFrontalAttackField():void{
			attacks = new Array();
			if(energy >= 35){
				energy -= 35;
				attacks = new Array();
				var px;
				var py;
				var pw;
				var ph;
				
				if(Keys.FacingLeft)
					px = -(Config.TileSize * 0.5);
				else
					px = (Config.TileSize * 0.5);
				py = 0;
				pw = Config.TileSize * 2;
				ph = Config.TileSize * 3;
				
				attacks.push(new PlayerAttack(worldX + px, worldY + py, pw, ph, ATK));
				isAttacking = true;
			}
			energyMeter.Update(energy, maxEnergy);
		}
		
		// Loads the player's attacks array for a radial attack. Costs 50 Energy.
		public function GenerateRadialAttackField():void{
			attacks = new Array();
			if(energy >= 50){
				energy -= 50;
				var px;
				var py;
				var pw;
				var ph;
				
				px = 0;
				py = 0;
				pw = Config.TileSize * 3;
				ph = Config.TileSize * 3;
				
				attacks.push(new PlayerAttack(worldX + px, worldY + py, pw, ph, ATK));
				
				px = 0;
				py = (-Config.TileSize * 2);
				pw = Config.TileSize;
				ph = Config.TileSize;
				
				attacks.push(new PlayerAttack(worldX + px, worldY + py, pw, ph, ATK));
				
				px = 0;
				py = -py;
				
				attacks.push(new PlayerAttack(worldX + px, worldY + py, pw, ph, ATK));
				
				px = (-Config.TileSize * 2);
				py = 0;
				
				attacks.push(new PlayerAttack(worldX + px, worldY + py, pw, ph, ATK));
				
				px = -px;
				py = 0;
				
				attacks.push(new PlayerAttack(worldX + px, worldY + py, pw, ph, ATK));
				isAttacking = true;
			}
			energyMeter.Update(energy, maxEnergy);
		}
	}
}
