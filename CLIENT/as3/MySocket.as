package as3 {
	
	import flash.display.MovieClip;
	import flash.net.DatagramSocket;
	import flash.events.DatagramSocketDataEvent;
	import flash.utils.ByteArray;
	
	// an object for sending 
	public class MySocket extends DatagramSocket {

		// server/client address info
		var ipClient:String = "10.252.20.131";
		var ipServer:String = "10.252.20.131";
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
					trace("packet received: lobby list");
					trace("Rooms received: " + numRooms);
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
					var seatsFull:uint = e.data.readUnsignedByte();
					Main.gsm.SwitchToLobby(roomID, seatsFull);
					break;
				case Protocol.START_ACCEPT:
					Main.gsm.SwitchToPlay();
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
		function SendPacketInput():void {
			var data:ByteArray = new ByteArray();
			data.writeByte(Protocol.INPUT);
			data.writeByte(Keys.MakeBitfield());
			SendPacket(data);
			trace("packet sent: input");
		}
		
		// sends any packets that you give to it.
		// buff	bytearray	the packet to send.
		function SendPacket(buff:ByteArray):void {
			try {
				trace(ipServer + ":" + portServer);
				send(buff, 0, buff.length, ipServer, portServer);
				
			} catch (e:Error) {
				trace("error sending: " + e.toString());
			}
		}
	}
}
