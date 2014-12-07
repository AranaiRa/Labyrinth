package as3 {
	
 	import flash.display.StageScaleMode;
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.utils.*;
	
	public class Main extends MovieClip {
		
		var time:int = 0; // milliseconds since launching application
		public static var gsm:GameStateManager;
		public static var timeElapsed:Number = 0;
		public static var socket:MySocket = new MySocket();
		
		public function Main() {
			if(stage) Init();
			else addEventListener(Event.ADDED_TO_STAGE, Init);
			
			addEventListener(Event.ENTER_FRAME, Update);
			
			gsm = new GameStateManager();
			addChild(gsm);
		}
		
		function GetDeltaTime():Number{
			var timeNew:int = getTimer();
			var timeDelta:Number = (timeNew - time) / 1000;
			time = timeNew;
			return timeDelta;
		}
		
		public function Update(e:Event){
			var dt:Number = GetDeltaTime();
			timeElapsed += dt;
			
			gsm.Update(dt);
		}
		
		public function Init(e:Event = null):void{
			removeEventListener(Event.ADDED_TO_STAGE, Init);
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}		
	}
}
