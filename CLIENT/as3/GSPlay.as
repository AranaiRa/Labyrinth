package as3 {
	import flashx.textLayout.formats.Float;
	
	public class GSPlay extends GameState {
		
		var level:Level = new Level();
		
		var cam:Camera;
		var player:Player;
		var player2:Player;
		
		var players:Array = new Array();
		var attacks:Array = new Array();
		var spawns:Array = new Array();
		var enemies:Array = new Array();
		var pickups:Array = new Array();
		
		var roundTimer:Number = 30;
		var wait:Number = 1; // how long to wait before beginning updates, to fix dt
		

		public function GSPlay(gsm:GameStateManager) {
			super(gsm);
			
			cam = new Camera();
			player = new Player(Config.StageWidth/2, Config.StageHeight/2, 1);
			player2 = new Player(Config.StageWidth/2, Config.StageHeight, 2);
			players.push(player);
			players.push(player2);
			
			spawns.push(new EnemySpawner(30, 450));
			//enemies.push(new EnemyHopper(Config.StageWidth/3, Config.StageHeight/2));
			//enemies.push(new EnemyTurret(Config.StageWidth/3, Config.StageHeight/2));
			enemies.push(new EnemyRanger(Config.StageWidth/3, Config.StageHeight/2));
			
			addChild(level);
			
			for(var i:int = players.length-1; i >= 0; i--){
				addChild(players[i]);
			}
			
			for(var i:int = spawns.length-1; i >= 0; i--){
				addChild(spawns[i]);
			}
			
			for(var i:int = enemies.length-1; i >= 0; i--){
				addChild(enemies[i]);
			}
			
			Config.timer.start();
			level.GetValidSpawnLocation();
		}
		
		public override function Update():void{
			var dt:Number = .05;
			if(wait < 0){
				for(var i:int = 0; i < players.length; i++){
					players[i].Update(dt, cam, level);
					if(players[i].index == 1) cam.Update(player.worldX, player.worldY);
				}
				level.Update(cam);
				
				// put in players loop
				attacks = new Array();
				if(player.isAttacking){
					for(var i:int = 0; i < player.attacks.length; i++){
						trace("Attack added to array");
						attacks.push(player.attacks[i]);
						addChild(player.attacks[i]);
					}
				}
				
				// update enemies
				for(var i:int = enemies.length-1; i >=0; i--){
					var e:Enemy = enemies[i];
					e.Update(dt, cam, player);					
					
					// check for bullets
					if(e.bullet != null){
						enemies.push(e.bullet);
						addChild(e.bullet);
						e.bullet = null;
					}
					
					// put in players loop
					if(e.aabb.IsCollidingWith(player.aabb) && e.hurtOnContact){
						player.Hurt(e.damage);
						if(e is EnemyBullet){
							KillEnemy(i);
							continue;
						}
					}
				
					//check player attack fields
					// put in players loop
					//for(var i:int = 0; i < players.length; i++){
						for(var af:int = 0; af < attacks.length; af++){
							attacks[af].Update(cam);
							
							if(e.aabb.IsCollidingWith(attacks[af].aabb)){
								trace("  }- Have some pain! :D");
								
								if(!(e is EnemyBullet)){
									KillEnemy(i);
									continue;
								}
							}
							else{
								//trace("  }- Missed. :c");
							}
						}
					//}
				}
				
				// put in players loop
				for(var i:int = spawns.length-1; i >=0; i--){
					var spawn:EnemySpawner = spawns[i];
					spawn.Update(cam);
					if(spawn.aabb.IsCollidingWith(player.aabb)){
						ActivateSpawner(i);
					}
				}
				
				// put in players loop
				for(var i:int = pickups.length-1; i >=0; i--){
					var pickup:Pickup = pickups[i];
					pickup.Update(dt, cam);
					if(pickup.canPickup && pickup.aabb.IsCollidingWith(player.aabb)){
						GetPickup(i);
					}
				}
			}else{
				wait -= dt;
			}
		}
		
		public function KillEnemy(index:int):void{
			var enemy:Enemy = enemies.splice(index, 1)[0];
			if(!(enemy is EnemyBullet)){ // bullets don't drop pickups
				var newPickups:Array = enemy.DropPickups();
				for(var i:int = 0; i < newPickups.length; i++){
					pickups.push(newPickups[i]);
					addChild(newPickups[i]);
				}
			}
			
			removeChild(enemy);
		}
		
		public function GetPickup(index:int):void{
			var pickup:Pickup = pickups.splice(index, 1)[0];
				
			switch(pickup.type){
				case Pickup.HPUP:
					player.AddHealth(pickup.amount);
				break;				
				case Pickup.ATKUP:
					player.AddHealth(pickup.amount);
				break;
				case Pickup.ENERGYATKUP:
					player.AddHealth(pickup.amount);
				break;
				case Pickup.SPDUP:
					player.AddHealth(pickup.amount);
				break;
				case Pickup.ENERGYUP:
					player.AddHealth(pickup.amount);
				break;
			}
			
			removeChild(pickup);
		}
		
		public function ActivateSpawner(index:int):void{
			var spawn:EnemySpawner = spawns.splice(index, 1)[0];
			
			var newEnemies:Array = spawn.SpawnEnemies();
			for(var i:int = 0; i < newEnemies.length; i++){
				enemies.push(newEnemies[i]);
				addChild(newEnemies[i]);
			}
			removeChild(spawn);
		}
	}
}
