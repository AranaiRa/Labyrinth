package as3 {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class AttackEffects extends MovieClip {
		
		private var _type:int;
		private var _framesLeft:int;
		public static var LATERAL:int = 1;
		public static var FRONTAL:int = 2;
		public static var RADIAL:int  = 3;
		
		public function AttackEffects(type:int) {
			_type = type;
			_framesLeft = 11;
			if(_type == LATERAL) gotoAndPlay(1);
			if(_type == FRONTAL) gotoAndPlay(12);
			if(_type == RADIAL) gotoAndPlay(23);
			addEventListener(Event.ENTER_FRAME, Update);
		}
		
		public function Update(e:Event){
			_framesLeft--;
			if(_framesLeft <= 0){
				parent.removeChild(this);
			}
		}
	}
	
}
