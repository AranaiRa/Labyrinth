package as3 {

	import flash.geom.Point;
	import flash.events.*;	
	
	public class GSPlay extends GameState {

		var playerID:uint;
		
		var level:Level = new Level();
		
		var cam:Camera;
		var player:Player;
		var player2:Player;
		
		var players:Array = new Array();
		var attacks:Array = new Array();
		var spawners:Array = new Array();
		var enemies:Array = new Array();
		var pickups:Array = new Array();
		
		var roundTimer:Number = 30;
		

		public function GSPlay(gsm:GameStateManager, players:Array, roomID:uint, playerID:uint) {
			super(gsm);

			this.playerID = playerID;
			
			cam = new Camera();
			this.players = players;
			player = this.players[playerID];

			if(stage) Init();
			else addEventListener(Event.ADDED_TO_STAGE, Init);

			//addChildAt(level, Layer.LEVELBG);
			addChild(level);
			
			for(var i:int = players.length-1; i >= 0; i--){
				//addChildAt(players[i], Layer.PLAYER);
				if(players[i] == null) continue;
				addChild(players[i]);
			}
			
			for(var i:int = spawners.length-1; i >= 0; i--){
				//addChildAt(spawners[i], Layer.SPAWNER);
				addChild(spawners[i]);
			}
			
			for(var i:int = enemies.length-1; i >= 0; i--){
				//addChildAt(enemies[i], Layer.ENEMY);
				addChild(enemies[i]);
			}
			
			Config.timer.start();
		}
		
		public function Init(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
			
			stage.stageFocusRect = false;
			stage.focus = this;
		}
		
		public function ReceiveWorldstatePlayer(pID:uint, px:Number, py:Number):void{
			if(players.length > 0 && players[pID] != null){
				players[pID].worldX = px;
				players[pID].worldY = py;
			}
		}

		public function KillPlayer(playerToKill:uint, winner:uint):void{
			if(winner > 0){
				Main.gsm.SwitchToEnd(winner, playerID);
			}

			if(playerToKill == playerID){
				// you died
				// stop listening to input so you don't wiggle around while you're dead
				// switch camera to a different player??
			}
			players[playerToKill].gotoAndStop(Player.DEADFRAME);
		}

		public function UpdateStats(hp:uint, maxhp:uint, energy:uint, maxenergy:uint):void{
			player.UpdateStats(hp, maxhp, energy, maxenergy);		
		}

		public function AddEnemy(eType:uint):void{ // tell it what index to be at??
			var e:Enemy;
			switch(eType){
				case Enemy.TURRET:
					//e = new EnemyTurret();
				break;
				case Enemy.HOPPER:
					e = new EnemyHopper();
				break;
				case Enemy.AERIAL:
					//e = new EnemyAerial();
				break;
				case Enemy.RANGER:
					//e = new EnemyRanger();
				break;
				case Enemy.BULLET:
					//e = new EnemyBullet();
				break;
			}
			
			if(e == null){
				return;
			}
			//addChildAt(e, Layer.ENEMY);
			addChild(e);
			enemies.push(e);
		}

		public function RemoveEnemy(eID:uint):void{
			var e:Enemy = enemies[eID];
			if(e == null){
				trace("Attempted to remove an enemy that doesn't exist...");
				return;
			}
			removeChild(e);
			enemies.splice(eID, 1);
		}

		public function ReceiveWorldstateEnemy(pID:uint, playerID:uint, px:Number, py:Number):void{
			if(enemies[pID] == null){
				trace("Attempted to update a null enemy");
				return;
			}
			enemies[pID].targetPlayer = players[playerID];
			enemies[pID].worldX = px;
			enemies[pID].worldY = py;
		}

		public function ReceiveWorldstateSpawner(pID:uint, px:Number, py:Number):void{
			if(spawners[pID] == null){
				spawners.push(new EnemySpawner(px, py));
				//addChildAt(spawners[pID], Layer.ENEMY);
				addChild(spawners[pID]);
			}else{
				spawners[pID].worldX = px;
				spawners[pID].worldY = py;
			}
		}

		public function AddPickup(pType:uint, pAmount:uint):void{
			var p:Pickup = new Pickup(pType, pAmount);
			//addChildAt(p, Layer.PICKUP);
			addChild(p);
			pickups.push(p);
		}

		public function RemovePickup(pID:uint):void{
			var p:Pickup = pickups[pID];
			if(p == null){
				trace("Attempted to remove a pickup that doesn't exist...");
				return;
			}
			removeChild(p);
			pickups.splice(pID, 1);
		}

		public function ReceiveWorldstatePickups(pID:uint, px:Number, py:Number):void{
			if(pickups[pID] == null){
				trace("Attempted to update a null pickup");
				return;
			}
			pickups[pID].worldX = px;
			pickups[pID].worldY = py;
		}
		
		public override function Update():void{

			// update your player and camera
			player.Update(cam);
			cam.Update(player.worldX, player.worldY);

			// update level
			level.Update(cam);

			// update other players
			for(var i:int = 0; i < players.length; i++){
				if(players[i] == null) continue;
				if(players[i].index != 1) players[i].Update(cam);
			}
						
			// update enemies
			for(var i:int = enemies.length-1; i >=0; i--){
				var e:Enemy = enemies[i];
				e.Update(cam, player);
			}
			
			// update spawners
			for(var i:int = spawners.length-1; i >=0; i--){
				var spawn:EnemySpawner = spawners[i];
				spawn.Update(cam);
			}
			
			// update pickups
			for(var i:int = pickups.length-1; i >=0; i--){
				var pickup:Pickup = pickups[i];
				pickup.Update(cam);
			}
		}
	}
}
