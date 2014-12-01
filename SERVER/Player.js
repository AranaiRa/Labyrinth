
//var MathHelpers = require("./MathHelpers.js");
//var PlayerCommand = require("./PlayerCommand.js").PlayerCommand;
//var PlayerState = require("./PlayerState.js").PlayerState;

exports.Player = function(playerID, rinfo){
	var me = this;
	this.id = playerID;
	this.hosting = false;
	this.rinfo = rinfo;
	this.timeSinceLastPacket = 0;

	/*//////////////////////// GAME VARIABLES:
	this.aabb:AABB;
	this.worldX, worldY;
	this.speedX = 0;
	this.speedY = 0;
	this.maxSpeedX = 500;
	this.maxSpeedY = 650;
	this.a = 1500;

	this.grounded = false;

	this.jumpJuice;
	this.jumpJuiceMax = 1.8;

	this.hasJetpack = false;
	this.hasDoubleJump = false;
	this.jumpsLeft:int = 2;

	this.health:int = 100;
	this.maxHealth:int = 100;
	this.hurtTimer = 0;
	this.hurtTimerMax = 1.5;
	*/////////////////////////

	// keeps track of how long it's been since last packet
	this.Refresh = function(){
		this.timeSinceLastPacket = 0;
	};
	
	// checks to see if it's time to disconnect them, if it's been too long since packets were received.
	this.CheckForTimeout = function(dt){
		this.timeSinceLastPacket += dt;
		if(this.timeSinceLastPacket >= 10000) return true;

		return false;
	};

	this.Disconnect = function(){
		global.Labyrinth.game.DisconnectPlayer(me);
	};

	// used to tell if, when packet is received, which player it was from, by comparing the rinfo IP address.
	this.MatchesAddr = function(rinfo){
		if(rinfo.address != this.rinfo.address) return false;
		if(rinfo.port != this.rinfo.port) return false;
		return true;
	}

	this.Update = function(dt){
		if(this.CheckForTimeout(dt)) {
			this.disconnect();
			return;
		}

		////////////////////////// GAME UPDATE:

	};
};