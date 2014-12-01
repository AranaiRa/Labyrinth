
var PlayerList = require("./PlayerList.js").PlayerList;

exports.Game = function(gameID){

	var me = this;
	this.id = gameID;
	this.players = [];
	this.started = false;
	this.time = 0; // gametime

	this.DisconnectPlayer = function(player){
		if(this.players.remove(player)){
			// TODO: broadcast disconnect to all other players
			console.log("disconnect player (timeout)")
		}
	};

	// gets deltatime and sets gametime
	this.GetDeltaTime = function(){
		var t = Date.now();
		var dt = t - this.systime;
		this.time += dt;
		return dt;
	};
	
	this.GameLoop = function(){ // in this function, use `me` instead of `this`
		var dt = me.GetDeltaTime();

		me.players.Loop(function(){
			this.Update(dt);
		});

		global.Labyrinth.socket.SendUpdate();

		setTimeout(me.GameLoop, global.Labyrinth.tick);
	};
};