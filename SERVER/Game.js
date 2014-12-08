
var PlayerList = require("./PlayerList.js").PlayerList;
var Level = require("./Level.js").Level;
var EnemyHopper = require("./EnemyHopper.js");
var EnemySpawner = require("./EnemySpawner.js");
var PickupType = require("./PickupType.js").PickupType;

exports.Game = function(gameID){

	var me = this;
	this.id = gameID;
	this.players = [null, null, null, null, null, null, null, null];
	this.attacks = [];
	this.spawners = [];
	this.enemies = [];
	this.pickups = [];
	this.started = false;
	this.systime = Date.now(); // system time
	this.time = 0; // game time
	this.level = new Level();
	this.fullSeats = 0;

	this.AddPlayer = function(player, index){
		if(me.players[index] != null){
			console.log("!!! Attempted to overwrite an existing player. what happened");
		}else{
			me.players[index] = player;
			me.fullSeats++;
		}
	};

	this.RemovePlayer = function(player){
		for(var i = 0; i < me.players.length; i++){
			if(me.players[i].MatchesAddr(player.rinfo)){
				me.players[i] = null;
				me.fullSeats--;
				return;
			}
		}
		
		console.log("!!! No player with that IP exists in this game");
	};

	this.DisconnectPlayer = function(playerID){
		if(me.players[playerID] != null){
			global.Labyrinth.players.Remove(me.players[playerID]);
			me.players.splice(playerID, 1);
			// TODO: broadcast disconnect to all other players
			console.log("disconnect player (timeout)")
		}else{
			console.log("!!! Failed to disconnect player: player doesn't exist");
		}
	};

	// gets deltatime and sets gametime
	this.GetDeltaTime = function(){
		var t = Date.now();
		var dt = t - me.time;
		me.time += dt;
		return dt/1000;
	};

	this.SetUp = function(){
		// set initial system time and reset delta time
		me.systime = Date.now();
		me.GetDeltaTime();

		// set up players
		for(var i = 0; i < me.players.length; i++){
			// spawning info, etc;
			if(me.players[i] != null){
				var spawnPos = me.level.GetRandomSpawnLocation();
				me.players[i].SetUp(spawnPos.x, spawnPos.y);
			}
		}

		// set up spawns
		for(var i = 0; i < global.Config.numSpawners; i++){
			me.spawners.push(new EnemySpawner(me.level.GetRandomSpawnLocation()));
			me.spawners[i].Update();
		}

		global.Labyrinth.socket.SendWorldstateSpawners(me);

		me.GameLoop();
	};
	
	this.GameLoop = function(){ // in this function, use `me` instead of `this`
		var dt = me.GetDeltaTime();

		// This loop updates players, checks for timeout, respawns if health is below 0,
		// retrieves the player's attacks if there are any, and checks for collision with spawners
		for(var i = 0; i < me.players.length; i++){
			if(me.players[i] == null) continue;
			// check to disconnect players
			if(me.players[i].CheckForTimeout(dt)) {
				me.DisconnectPlayer(i);
				continue;
			}

			me.players[i].Update(dt);
			me.level.FixCollisions(me.players[i]);

			if(me.players[i].health <= 0){ // TODO: add some type of death delay?
				me.players[i].Respawn(me.level.GetRandomSpawnLocation());
			}

			// get player attacks
			if(me.players[i].isAttacking){
				for(var a = 0; a < me.players[i].attacks.length; a++){
					var patk = me.players[i].attacks[a];
					patk.playerID = i;
					me.attacks.push(patk);
				}
			}

			// loop through spawners
			// check if player collided with spawner
			for(var j = 0; j < me.spawners.length; j++){
				if(me.players[i].aabb.IsCollidingWith(me.spawners[j].aabb)){
					me.ActivateSpawner(j, i);
				}
			}
		}
		// end player loop

		// this loop updates eemies and checks for contact with players if they hurt on contact.
		for(var i = 0; i < me.enemies.length; i++){
			me.enemies[i].Update(dt);
			me.level.FixCollisions(me.enemies[i]);

			for(var j = 0; j < me.players.length; j++){
				if(me.players[j] == null) continue;
				if(me.enemies[i].hurtOnContact && me.enemies[i].aabb.IsCollidingWith(me.players[j].aabb)){
					me.players[j].Hurt(me.enemies[i].damage);
					if(me.players[j].health <= 0){
						me.players[j].Respawn(me.level.GetRandomSpawnLocation());
					}
				}
			}
		}

		// this loop checks for player attacks hitting other players and enemies
		for(var i = 0; i < me.attacks.length; i++){
			for(var j = 0; j < me.players.length; j++){
				if(me.players[j] == null) continue;
				var pID = me.attacks[i].playerID;
				if(pID == j) continue; // so players can't hurt themselves
				if(me.attacks[i].aabb.IsCollidingWith(me.players[j].aabb)){
					var damage = me.attacks[i].dmg * me.players[pID].damageMultiplier;
					me.players[j].Hurt(damage);
					if(me.players[j].health <= 0){
						me.players[j].Respawn(me.level.GetRandomSpawnLocation());
					}
				}
			}

			for(var j = me.enemies.length - 1; j >= 0; j--){
				if(me.attacks[i].aabb.IsCollidingWith(me.enemies[j].aabb)){
					var pID = me.attacks[i].playerID;
					var damage = me.attacks[i].dmg * me.players[pID].damageMultiplier;
					me.enemies[j].Hurt(damage);
					if(me.enemies[j].health <= 0){
						me.KillEnemy(j);
						global.Labyrinth.socket.SendRemoveEnemy(me, j);
						continue;
					}
				}
			}
		}
		me.attacks = []; // attacks only exist for 1 frame.

		for(var i = me.pickups.length-1; i >= 0; i--){
			me.pickups[i].Update(dt);
			me.level.FixCollisions(me.pickups[i]);
			global.Labyrinth.socket.SendWorldstatePickups(me);

			for(var j = 0; j < me.players.length; j++){
				if(me.players[j] == null) continue;
				if(me.pickups[i].canPickup && me.pickups[i].aabb.IsCollidingWith(me.players[j].aabb)){
					me.GetPickup(j, i);
					break;
				}
			}
		}

		global.Labyrinth.socket.SendWorldstatePlayers(me);
		global.Labyrinth.socket.SendWorldstateEnemies(me);

		setTimeout(me.GameLoop, global.Config.tick);
	};

	this.ActivateSpawner = function(spawnID, playerID){
		var newEnemies = me.spawners[spawnID].SpawnEnemies();
		for(var i = 0; i < newEnemies.length; i++){
			newEnemies[i].SetTarget(me.players[playerID], playerID);
			me.enemies.push(newEnemies[i]);
			global.Labyrinth.socket.SendAddEnemy(me, me.enemies[i].enemyType);
		}

		var pos = me.level.GetRandomSpawnLocation();
		me.spawners[spawnID].worldX = pos.x + global.Config.tileSize/2;
		me.spawners[spawnID].worldY = pos.y + global.Config.tileSize/2;
		me.spawners[spawnID].Update();

		global.Labyrinth.socket.SendWorldstateSpawners(me);
	};

	this.KillEnemy = function(eID){
		var enemy = me.enemies.splice(eID, 1)[0];
		var newPickups = enemy.DropPickups();
		for(var i = 0; i < newPickups.length; i++){
			me.pickups.push(newPickups[i]);
			global.Labyrinth.socket.SendAddPickup(me, newPickups[i].type, newPickups[i].amount);
		}
	};

	this.GetPickup = function(playerID, pickupID){
		var pickup = me.pickups.splice(pickupID, 1)[0];
		var pl = me.players[playerID];

		switch(pickup.type){
			case PickupType.HPUP:
			pl.AddHealth(pickup.amount);
			break;

			case PickupType.ATKUP:
			pl.damageMultiplier += (pickup.amount / 100.0);
			break;

			case PickupType.SPDUP:
			pl.speedMultiplier += (pickup.amount / 100.0);
			break;

			case PickupType.ENERGYUP:
			pl.AddEnergy(pickup.amount);
			break;
		}

		global.Labyrinth.socket.SendRemovePickup(me, pickupID);
		
	};
};