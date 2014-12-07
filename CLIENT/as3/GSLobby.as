package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;	
	
	public class GSLobby extends GameState {
		
		public var players:Array = new Array(null, null, null, null, null, null, null, null);
		var nameTexts:Array = new Array();
		var alerts:Array = new Array();
		var roomID:uint;
		var playerID:uint;
		var hosting:Boolean = false;
		
		public function GSLobby(gsm:GameStateManager, roomID:uint, playerID:uint) {
			super(gsm);

			this.roomID = roomID;
			this.playerID = playerID;

			this.players[playerID] = new Player(1);
			if(playerID == 0) hosting = true;
			
			nameTexts.push(name1, name2, name3, name4, name5, name6, name7, name8);
			lobbyText.text = "Lobby #" + roomID;

			if(hosting){
				name1.text = "Player 1 (You)";
				waitingForHost.visible = false;
			}else{
				name1.text = "Player 1 (Host)";
				nameTexts[playerID].text = "Player " + (playerID + 1) + " (You)";
				bttnStart.visible = false;
			}
			
			bttnStart.addEventListener(MouseEvent.CLICK, HandleStart);
			bttnBack.addEventListener(MouseEvent.CLICK, HandleBack);
		}

		public function UpdateLobby(fullSeats:uint):void{
			for(var i:int = 7; i >= 0; i--){
				if(i == 0 || i == playerID){
					if(i != 0) fullSeats >>= 1; // skip host and yourself
					continue;
				}

				if(fullSeats & 128 == 128){
					nameTexts[i].text = "Player " + (i+1);
				}else{
					nameTexts[i].text = "empty seat";
				}
				fullSeats >>= 1;
			}
		}
		
		public function HandleStart(e:MouseEvent):void{
			Main.socket.SendPacketStartGame(roomID);
		}
		
		public function HandleBack(e:MouseEvent):void{
			gsm.SwitchToTitle();
			// send leave packet
		}		
	}
}
