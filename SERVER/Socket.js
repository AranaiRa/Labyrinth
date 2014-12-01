
var dgram = require("dgram");
var Protocol = require("./Protocol.js").Protocol;
var Game = require("./Game.js").Game;

exports.Socket = function(){
	var me = this;
	this.socket = dgram.createSocket("udp4");
	this.socket.on("message", function(buff, rinfo){

		var type = buff.readUInt8(0);

		var player = global.Labyrinth.players.GetByAddr(rinfo);

		//console.log("Received message from " + rinfo.address + ":" + rinfo.port);

		if(player == null) { // player wasn't in collection yet
			if(type == Protocol.HOST_LOBBY || type == Protocol.JOIN_LOBBY){ // if it was a join request, add them
				console.log("player joined");
				player = global.Labyrinth.players.Add(rinfo);
				player.Refresh();
			} else { // if not a join request, just disconnect them
				//console.log("disconnecting player");
				//me.SendDisconnect(rinfo);
			}
		}

		// else, player is not null.

		// udp is not connection based, so if we want to tell if they're disconnected, keep track of the last time they sent a packet. if it's been too long, they timed out.
		// this function says they received a packet so don't time out them.
		//player.Refresh();

		switch(type){
			case Protocol.HOST_LOBBY:
				if(!player.hosting){
					var roomID = ++global.Labyrinth.roomID;
					console.log("Player " + player.id + " created room " + roomID);
					player.hosting = true;
					global.Labyrinth.gamelist.Add(new Game(roomID));
					global.Labyrinth.gamelist.games[roomID].players.push(player);
					me.SendJoinAccept(player, roomID);
					if(roomID == 1) me.Update();
				}else{
					// something went wrong;
					// server thought this player was hosting already but they sent another host request
				}
				break;
			case Protocol.JOIN_LOBBY:
				var roomID = buff.readUInt8(1);			console.log("Player " + player.id + " wants to join room " + roomID);
				global.Labyrinth.gamelist.games[roomID].players.push(player);
				break;
			case Protocol.LEAVE_LOBBY:
				break;
			case Protocol.START_GAME:
				var roomID = buff.readUInt8(1);
				me.SendStartAccept(roomID);
				break;
			case Protocol.INPUT:
				break;
			case Protocol.BROADCAST_LOBBY_LIST:
				console.log("because it gets broadcasted so yknow.");
				break;
			default:
				console.log("received an unkown packet type: "+type);
		}
	});

	this.socket.on("listening", function(){
		console.log("listening on port " + global.Labyrinth.PORT);
	});

	this.Listen = function(){
		this.socket.bind(global.Labyrinth.PORT);
	};

	this.Update = function(){
		me.BroadcastLobbyList();
		setTimeout(me.Update, 4000);
	}

	this.Send = function(buff, rinfo){
		//console.log("Attempting to send data to " + rinfo.address + ":" + rinfo.port);
		me.socket.send(buff, 0, buff.length, rinfo.port, rinfo.address, function(err, bytes){

		});
	};

	this.SendToPlayers = function(buff, players){
		for(var i = 0; i < players.length; i++){
			me.socket.send(buff, 0, buff.length, players[i].rinfo.port, players[i].rinfo.address, function(err, bytes){

			});
		}
	}

	this.Broadcast = function(buff){
		var rinfo = {port:global.Labyrinth.CLIENTPORT, address:global.Labyrinth.BROADCASTIP};
		//console.log("Attempting to broadcast data to " + rinfo.address + ":" + rinfo.port);
		
		me.socket.send(buff, 0, buff.length, rinfo.port, rinfo.address, function(err, bytes){

		});
	};

	//////////////////////////////////// SEND FUNCTIONS

	this.BroadcastLobbyList = function(){
		console.log("Broadcasting " + global.Labyrinth.gamelist.length + " lobbies.");
		var buff = new Buffer(2 + global.Labyrinth.gamelist.length*2);
		buff.writeUInt8(Protocol.BROADCAST_LOBBY_LIST, 0);
		buff.writeUInt8(global.Labyrinth.gamelist.length, 1);
		for(var i = 1; i < global.Labyrinth.gamelist.length + 1; i++){
			//console.log("Game added with ID: " + global.Labyrinth.gamelist.games[i].id + " at position " + (2 * i));
			if(!global.Labyrinth.gamelist.games[i].players.length < 8 && !global.Labyrinth.gamelist.games[i].started){
				buff.writeUInt8(global.Labyrinth.gamelist.games[i].id, 2*i);
				buff.writeUInt8(8 - global.Labyrinth.gamelist.games[i].players.length, 3*i);
			}
		}

		me.Broadcast(buff);
	};

	this.SendJoinAccept = function(player, roomID){
		var buff = new Buffer(3);
		buff.writeUInt8(Protocol.JOIN_ACCEPT, 0);
		buff.writeUInt8(roomID, 1);
		buff.writeUInt8(8 - global.Labyrinth.gamelist.games[roomID].players.length, 2);
		me.Send(buff, player.rinfo);
	};

	this.SendStartAccept = function(roomID){
		var buff = new Buffer(1);
		buff.writeUInt8(Protocol.START_ACCEPT, 0);
		me.SendToPlayers(buff, global.Labyrinth.gamelist.games[roomID].players);
	};

	/*this.SendUpdate = function(){
		var num = global.Labyrinth.game.players.length;
		if(num <= 0) return;

		var len = 18 + 17 * num;
		var x = 18;
		var buff = new Buffer(len);
tc
		buff.writeUInt32BE(Protocol.id, 0);
		buff.writeUInt8(Protocol.MSG_UPDATE, 4);
		buff.writeUInt32BE(0, 5);  // server seq#
		buff.writeUInt32BE(0, 13); // ack bitfield
		buff.writeUInt8(num, 17);
		global.Labyrinth.game.players.Loop(function(){
			var ps = this.getPrevState();
			buff.writeUInt8(this.id, x);
			buff.writeFloatBE(ps.px, x+01);
			buff.writeFloatBE(ps.py, x+05);
			buff.writeFloatBE(ps.vx, x+09);
			buff.writeFloatBE(ps.vy, x+13);
			x += 17;
		});
		global.Labyrinth.game.players.Loop(function(){
			if(this.hasSentInput){
				var pc = this.getPrevCommand();
				var seq = (pc == null) ? 0 : pc.seq;
				buff.writeUInt32BE(seq, 9)
				me.Send(buff, this.rinfo);
			} else {
				me.sendConnect(this);
			}
		});

	};*/

};