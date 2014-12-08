package as3 {
	
	import flash.display.MovieClip;
	import flash.net.DatagramSocket;
	import flash.events.DatagramSocketDataEvent;
	import flash.utils.ByteArray;
	
	// an object for sending 
	public class MySocket extends DatagramSocket {

		// server/client address info
		var ipClient:String = "10.0.0.10";//"10.252.20.249";//
		var ipServer:String = "10.0.0.10";//
		var portClient:int = 4326;
		var portServer:int = 1236;
		
		// constructor
		function MySocket() {
			
		}
		
		// sets up the socket to begin sending/receiving packets
		public function Start():void {
			addEventListener(DatagramSocketDataEvent.DATA, HandleData);
			bind(portClient, ipClient);
			receive();  
		}
		
		// the event handler for receiving incoming packets
		// e	datagramsocketevent	the event that triggered the handler
		// return void
		function HandleData(e:DatagramSocketDataEvent):void {
			var type:uint = e.data.readUnsignedByte(); // get message type
			switch(type){
				case Protocol.BROADCAST_LOBBY_LIST:
					var numRooms:uint = e.data.readUnsignedByte();
					//trace("packet received: lobby list");
					//trace("Rooms received: " + numRooms);
					var rooms:Array = new Array();
					var seats:Array = new Array();
					if(numRooms > 0){
						for(var i:int = 0; i < numRooms; i++){
							var roomID:uint = e.data.readUnsignedByte();
							var seatsAvail:uint = e.data.readUnsignedByte();
							rooms.push(roomID);
							seats.push(seatsAvail);
						}
						
						Main.gsm.ReceiveLobbyList(rooms, seats);
					}
					break;
				case Protocol.LOBBY_FULL:
					trace("packet received: lobby full error");
					break;
				case Protocol.JOIN_ACCEPT:		
					trace("packet received: join request accepted");
					var roomID:uint = e.data.readUnsignedByte();
					var playerID:uint = e.data.readUnsignedByte();
					Main.gsm.SwitchToLobby(roomID, playerID);
					break;
				case Protocol.LOBBY_STATE:		
					trace("packet received: update lobby seats");
					var seatsFull:uint = e.data.readUnsignedByte();
					Main.gsm.UpdateLobby(seatsFull);
					break;
				case Protocol.START_ACCEPT:
					Main.gsm.SwitchToPlay();
					break;
				case Protocol.WORLDSTATE_PLAYERINFO:
					var numPlayers:uint = e.data.readUnsignedByte();
					for(var i:int = 0; i < numPlayers; i++){
						var pID:uint = e.data.readUnsignedByte();
						var px:Number = e.data.readFloat();
						var py:Number = e.data.readFloat();
						//trace("Player " + pID + " is at position (" + px + ", " + py + ")");
						Main.gsm.ReceiveWorldstatePlayer(pID, px, py);
					}
					break;
				case Protocol.STAT_UPDATE:
					var hp:uint = e.data.readUnsignedShort();
					var maxhp:uint = e.data.readUnsignedShort();
					var energy:uint = e.data.readUnsignedShort();
					var maxenergy:uint = e.data.readUnsignedShort();
					//trace("Receiving health: " + hp + "/" + maxhp);
					//trace("Receiving energy: " + energy + "/" + maxenergy);
					Main.gsm.UpdateStats(hp, maxhp, energy, maxenergy);
					break;
				case Protocol.ADD_ENEMY:
					var eType:uint = e.data.readUnsignedByte();
					Main.gsm.AddEnemy(eType);
					break;
				case Protocol.REMOVE_ENEMY:
					var eID:uint = e.data.readUnsignedByte();
					Main.gsm.RemoveEnemy(eID);
					break;
				case Protocol.WORLDSTATE_ENEMYINFO:
					var numEnemies:uint = e.data.readUnsignedByte();
					for(var i:int = 0; i < numEnemies; i++){
						var pID:uint = e.data.readUnsignedByte();
						var playerID:uint = e.data.readUnsignedByte();
						var px:Number = e.data.readFloat();
						var py:Number = e.data.readFloat();
						//trace("Enemy " + pID + " is at position (" + px + ", " + py + ")");
						Main.gsm.ReceiveWorldstateEnemy(pID, playerID, px, py);
					}
					break;
				case Protocol.WORLDSTATE_SPAWNERINFO:
					var numSpawners:uint = e.data.readUnsignedByte();
					for(var i:int = 0; i < numSpawners; i++){
						var pID:uint = e.data.readUnsignedByte();
						var px:Number = e.data.readFloat();
						var py:Number = e.data.readFloat();
						Main.gsm.ReceiveWorldstateSpawner(pID, px, py);
					}
					break;
				case Protocol.ADD_PICKUP:
					var pType:uint = e.data.readUnsignedByte();
					var pAmount:uint = e.data.readUnsignedByte();
					Main.gsm.AddPickup(pType, pAmount);
					break;
				case Protocol.REMOVE_PICKUP:
					var pID:uint = e.data.readUnsignedByte();
					Main.gsm.RemovePickup(pID);
					break;
				case Protocol.WORLDSTATE_PICKUPINFO:
					var numPickups:uint = e.data.readUnsignedByte();
					for(var i:int = 0; i < numPickups; i++){
						var pID:uint = e.data.readUnsignedByte();
						var px:Number = e.data.readFloat();
						var py:Number = e.data.readFloat();
						Main.gsm.ReceiveWorldstatePickups(pID, px, py);
					}
					break;
				default:
			}
		}
		
		// creates and sends a HOST packet
		function SendPacketHostLobby():void {
			var data:ByteArray = new ByteArray();
			data.writeByte(Protocol.HOST_LOBBY);
			// start countdown for host accept
			SendPacket(data);
		}
		
		// creates and sends a JOIN packet
		function SendPacketJoinLobby(roomID:int):void {
			var data:ByteArray = new ByteArray();
			data.writeByte(Protocol.JOIN_LOBBY);
			data.writeByte(roomID);
			SendPacket(data);
		}
		
		// creates and sends a LEAVE packet
		function SendPacketLeaveLobby(roomID:int):void {
			var data:ByteArray = new ByteArray();
			data.writeByte(Protocol.LEAVE_LOBBY);
			data.writeByte(roomID);
			SendPacket(data);
		}
		
		// creates and sends a START packet
		function SendPacketStartGame(roomID:int):void {
			var data:ByteArray = new ByteArray();
			data.writeByte(Protocol.START_GAME);
			data.writeByte(roomID);
			SendPacket(data);
		}
		
		// creates and sends an input packet and caches it.
		// pc	playercommand	the command to send to the server
		// @return void
		function SendPacketInput(bits:uint):void {
			var data:ByteArray = new ByteArray();
			data.writeByte(Protocol.INPUT);
			data.writeByte(bits);
			SendPacket(data);
		}
		
		// sends any packets that you give to it.
		// buff	bytearray	the packet to send.
		function SendPacket(buff:ByteArray):void {
			try {
				send(buff, 0, buff.length, ipServer, portServer);
				
			} catch (e:Error) {
				trace("error sending: " + e.toString());
			}
		}
	}
}
