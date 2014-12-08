package as3 {
	
	import flash.events.*;
	
	public class GSEnd extends GameState {
		
		public function GSEnd(gsm:GameStateManager, winner:int) {
			super(gsm);
			
			bttnLeave.addEventListener(MouseEvent.CLICK, leaveFunction);
			winnerText.text = "Player "+winner;
		}
		
		public function leaveFunction(e:MouseEvent):void{
			gsm.SwitchToTitle();
		}
		
		public override function Update():void{
			
		}
	}
}
