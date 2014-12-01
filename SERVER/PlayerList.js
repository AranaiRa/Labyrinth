
var Player = require("./Player.js").Player;

exports.PlayerList = function(){

	this.players = {}; // object, but it's an associative array
	this.length = 0;
	this.playerID = 0;

	this.Get = function(index){
		if(this.players.hasOwnProperty(index)) return this.players[index];
		return null;
	};

	// so you can use the object like an array, but rather than index, looks at rinfo to see if it matches
	this.GetByAddr = function(rinfo){
		for(key in this.players){
			if(this.players[key].MatchesAddr(rinfo)) {
				return this.players[key];
			}
		}
	};
	
	this.Add = function(player){
		while(this.Get(++this.playerID)) {} // if it returns a player, someone already has that id. so loops until the ID is not taken.
		// if receives rinfo, add new player. if receives player... (??)
		if(!(player instanceof Player)) {
			player = new Player(this.playerID, player);
		} else {
			player.id = this.playerID;
		}

		this.players[this.playerID] = player;
		this.length++;
		return player;
	};

	// can receive a player or index; if it receives a player, gets the index of that player
	this.Remove = function(index){
		if(index instanceof Player) index = index.id;

		// if the player is in that array, remove it
		if(this.players.hasOwnProperty(index)) {
			delete this.players[index]; // removes that 'property' from the object (removes player from the array)
			this.length--;
			return true;
		}
		console.log("failed");
		return false;
	};

	// pass in a function, and for every player, calls that function by passing in the player
	// inside of the function parameter, 'this' refers to the player(??)
	this.Loop = function(func){
		for(key in this.players){
			func.call(this.players[key]);
		}
	};

	
	this.State = function(){
		var state = {};
		this.loop(function(){
			
		});
	};
};