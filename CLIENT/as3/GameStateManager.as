package as3 {
	import flash.display.MovieClip;
	
	public class GameStateManager extends MovieClip{
		
		var gsCurrent:GameState;
		public var hosting:Boolean;

		public function GameStateManager() {
			SwitchToTitle();
			Main.socket.Start();
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
		
		public function ReceiveWorldstatePlayer(pID:uint, px:Number, py:Number):void{
			if(gsCurrent is GSPlay){
				(gsCurrent as GSPlay).ReceiveWorldstatePlayer(pID, px, py);
			}
		}

		public function UpdateStats(hp:uint, maxhp:uint, energy:uint, maxenergy:uint):void{
			if(gsCurrent is GSPlay){
				(gsCurrent as GSPlay).UpdateStats(hp, maxhp, energy, maxenergy);
			}
		}

		public function AddEnemy(eType:uint):void{
			if(gsCurrent is GSPlay){
				(gsCurrent as GSPlay).AddEnemy(eType);
			}
		}

		public function RemoveEnemy(eID:uint):void{
			if(gsCurrent is GSPlay){
				(gsCurrent as GSPlay).RemoveEnemy(eID);
			}
		}
		
		public function ReceiveWorldstateEnemy(pID:uint, playerID:uint, px:Number, py:Number):void{
			if(gsCurrent is GSPlay){
				(gsCurrent as GSPlay).ReceiveWorldstateEnemy(pID, playerID, px, py);
			}
		}

		public function ReceiveWorldstateSpawner(pID:uint, px:Number, py:Number):void{
			if(gsCurrent is GSPlay){
				(gsCurrent as GSPlay).ReceiveWorldstateSpawner(pID, px, py);
			}
		}

		public function AddPickup(pType:uint, pAmount:uint):void{
			if(gsCurrent is GSPlay){
				(gsCurrent as GSPlay).AddPickup(pType, pAmount);
			}
		}

		public function RemovePickup(pID:uint):void{
			if(gsCurrent is GSPlay){
				(gsCurrent as GSPlay).RemovePickup(pID);
			}
		}

		public function ReceiveWorldstatePickups(pID:uint, px:Number, py:Number):void{
			if(gsCurrent is GSPlay){
				(gsCurrent as GSPlay).ReceiveWorldstatePickups(pID, px, py)
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
