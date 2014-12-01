package as3 {
	
	import flash.display.MovieClip;
	import flash.events.*;	
	import flash.system.Security;
	
	public class GSJoin extends GameState {
		
		var roomID:int;
		
		public function GSJoin(gsm:GameStateManager) {
			super(gsm);
			
			if(stage) Init();
			else addEventListener(Event.ADDED_TO_STAGE, Init);
			
			bttnJoin.addEventListener(MouseEvent.CLICK, HandleJoin);
			bttnJoin.visible = false;
			bttnBack.addEventListener(MouseEvent.CLICK, HandleBack);
		}

		private function Init(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
			lobbyList.addEventListener(Event.CHANGE, UpdateSelection);
		}
		
		public function ReceiveLobbyList(rooms:Array, seats:Array):void{
			lobbyList.removeAll();
			for(var i:int = 0; i < rooms.length; i++){
				lobbyList.addItem( {label:"Lobby #" + rooms[i] + " : " + seats[i] + " seats available",     data:rooms[i]} );
			}
		}
		
		public function UpdateSelection(e:Event){
			roomID = e.target.selectedItem.data;
			selectedLobbyText.text = "Selected Lobby: #" + roomID;
			if(!bttnJoin.visible) bttnJoin.visible = true;
		}

		public function HandleJoin(e:MouseEvent):void{
			Main.socket.SendPacketJoinLobby(roomID);
		}
		
		public function HandleBack(e:MouseEvent):void{
			gsm.SwitchToTitle();
		}
		
		public override function Update():void{
		
		}
	}
}
