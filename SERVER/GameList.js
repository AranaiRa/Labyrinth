
var Player = require("./Player.js").Player;
var PlayerList = require("./PlayerList.js").PlayerList;
var Game = require("./Game.js").Game;

exports.GameList = function(){

	this.games = {}; // object, but it's an associative array
	this.length = 0;
	this.gameID = 0;

	this.Get = function(index){
		if(this.games.hasOwnProperty(index)) return this.games[index];
		return null;
	};

	// so you can use the object like an array, but rather than index, looks at rinfo to see if it matches
	this.Get = function(index){
		for(key in this.games){
			if(this.games[key].MatchesAddr(index)) {
				return this.games[key];
			}
		}
	};
	
	this.Add = function(game){
		while(this.Get(++this.gameID)) {} // if it returns a game, someone already has that id. so loops until the ID is not taken.
		
		// if receives rinfo, add new game. if receives game... (??)
		if(!(game instanceof Game)) {
			game = new Game(this.gameID, game);
		} else {
			game.id = this.gameID;
		}

		this.games[this.gameID] = game;
		this.length++;
		return game;
	};

	// can receive a game or index; if it receives a game, gets the index of that game
	this.Remove = function(index){
		if(index instanceof Game) index = index.id;

		// if the game is in that array, remove it
		if(this.games.hasOwnProperty(index)) {
			delete this.games[index]; // removes that 'property' from the object (removes game from the array)
			this.length--;
			return true;
		}
		console.log("failed");
		return false;
	};

	// pass in a function, and for every game, calls that function by passing in the game
	// inside of the function parameter, 'this' refers to the game(??)
	this.Loop = function(func){
		for(key in this.games){
			func.call(this.games[key]);
		}
	};

	
	this.State = function(){
		var state = {};
		this.loop(function(){
			
		});
	};
};