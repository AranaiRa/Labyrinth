package as3 {
	import flash.display.MovieClip;
	
	public class GameStateManager extends MovieClip{
		
		var gsCurrent:GameState;
		public var hosting:Boolean;

		public function GameStateManager() {
			//SwitchToTitle();
			Main.socket.Start();
			SwitchToPlay();
		}
		
		public function Update(dt:Number):void{			
			if(gsCurrent != null){
				gsCurrent.Update();
			}
		}
		
		public function ReceiveLobbyList(rooms:Array, seats:Array):void{
			if(gsCurrent is GSJoin){
				(gsCurrent as GSJoin).ReceiveLobbyList(rooms, seats);
			}
		}
		
		
		
		

    public function SwitchToTitle():void {
			if(gsCurrent != null) removeChild(gsCurrent);
      gsCurrent = new GSTitle(this);
			addChild(gsCurrent);
    }

    public function SwitchToLobby(roomID:uint, seatsFull:uint):void {
			removeChild(gsCurrent);
      gsCurrent = new GSLobby(this, roomID, seatsFull, hosting);
			addChild(gsCurrent);
    }

    public function SwitchToJoin():void {
			removeChild(gsCurrent);
      gsCurrent = new GSJoin(this);
			addChild(gsCurrent);
    }

    public function SwitchToInstructions():void {
			removeChild(gsCurrent);
      //gsCurrent = new GSInstructions(this);
			addChild(gsCurrent);
    }

    public function SwitchToPlay():void {
			if(gsCurrent != null) removeChild(gsCurrent);
      gsCurrent = new GSPlay(this);
			addChild(gsCurrent);
    }

    public function SwitchToEnd():void {
			removeChild(gsCurrent);
     gsCurrent = new GSEnd(this);
			addChild(gsCurrent);
    }

    public function SwitchToCredits():void {
			removeChild(gsCurrent);
       gsCurrent = new GSCredits(this);
			addChild(gsCurrent);
    }
	}
}
