
var Socket = require("./Socket.js").Socket;
var PlayerList = require("./PlayerList.js").PlayerList;
var GameList = require("./GameList.js").GameList;
var Game = require("./Game.js").Game;

global.Labyrinth = {
	BROADCASTIP:"10.252.20.132",//"10.0.0.255",//"255.255.255.255";
	PORT:1236, // !!!!!!
	CLIENTPORT:4326,
	tick:33,
	roomID:0,
	players:new PlayerList(),
	gamelist:new GameList(),
	socket:new Socket(),
	Start:function(){
		this.socket.Listen();
	},
	Play:function(id){ // call this to start the gameloop
		this.gamelist.Get(id).GameLoop();
	},
};

global.Labyrinth.Start();