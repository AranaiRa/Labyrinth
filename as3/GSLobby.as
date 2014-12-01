package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;	
	
	public class GSLobby extends GameState {
		
		public var players:Array = new Array(null, null, null, null, null, null, null, null);
		var nameTexts:Array = new Array();
		var alerts:Array = new Array();
		var roomID:uint;
		
		public function GSLobby(gsm:GameStateManager, roomID:uint, seatsFull:uint, hosting:Boolean) {
			super(gsm);
			this.roomID = roomID;
			
			nameTexts.push(name1, name2, name3, name4, name5, name6, name7, name8);
			lobbyText.text = "Lobby #" + roomID;
			if(hosting){
				name1.text = "Player 1 (You)";
				waitingForHost.visible = false;
				for(var i:int = 1; i < seatsFull; i++){
					nameTexts[i].text = "Player " + (i+1);
				}
			}else{
				bttnStart.visible = false;
				name1.text = "Player 1 (Host)";
			}
			
			bttnStart.addEventListener(MouseEvent.CLICK, HandleStart);
			bttnBack.addEventListener(MouseEvent.CLICK, HandleBack);
		}
		
		public function HandleStart(e:MouseEvent):void{
			Main.socket.SendPacketStartGame(roomID);
		}
		
		public function HandleBack(e:MouseEvent):void{
			gsm.SwitchToTitle();
		}		
	}
}
