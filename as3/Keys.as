package as3 {
	
	import flash.events.*;
	
	/***
	 * This static class keeps track of what relevant keys are being pressed.
	 ***/
	public class Keys {
		
		static var Left:Boolean = false;
		static var Right:Boolean = false;
		static var Jump:Boolean = false;
		static var JumpPrev:Boolean = false;
		
		static var Attack1:Boolean = false;
		static var Attack1Prev:Boolean = false;
		
		static var Attack2:Boolean = false;
		static var Attack2Prev:Boolean = false;
		
		static var Energy1:Boolean = false;
		static var Energy1Prev:Boolean = false;
		
		static var Energy2:Boolean = false;
		static var Energy2Prev:Boolean = false;
		
		static var Energy3:Boolean = false;
		static var Energy3Prev:Boolean = false;
		
		/***
	 	 * This method is called from the event listener function.
		 * The parameters are the KeyboardEvent from the listener, to get the keyCode,
		 * and a boolean which is True if it's a KEY_DOWN event and False for KEY_UP
	 	 ***/
		static function KeyPressed(e:KeyboardEvent, b:Boolean):void{
			//trace(e.keyCode);
			switch(e.keyCode){
				case 37: case 65: // left arrow, a
				Left = b;
				break;
				
				case 39: case 68: // right arrow, d
				Right = b;
				break;
				
				case 32: // space
				Jump = b;
				break;
				
				case 81: case 49: case 73: // q/1/i		// i have 5 attack buttons, what will the other 2 be?
				Attack1 = b;
				break;
				
				case 87: case 50: case 79: // w/2/o
				Energy1 = b;
				break;
				
				case 69: case 51: case 80: // e/3/p
				Energy2 = b;
				break;
			}
		}
		
		static function OnPress(key:String):Boolean{
			switch(key){
				case "Attack1":
					return (!Attack1Prev && Attack1);
					break;
				case "Energy1":
					return (!Energy1Prev && Energy1);
					break;
				case "Energy2":
					return (!Energy2Prev && Energy2);
					break;
			}
				
			return false;
		}
		
		//0QWE PJLR
		static function MakeBitfield():uint {
			var bits:uint = 0;
			if(OnPress("Attack1")) bits |= 1<<6;
			if(OnPress("Energy1")) bits |= 1<<5;
			if(OnPress("Energy2")) bits |= 1<<4;
			if(JumpPrev) bits |= 1<<3;
			if(Jump) bits |= 1<<2;
			if(Left) bits |= 1<<1;
			if(Right) bits |= 1;
			return bits;
		}
		
		static function Update():void{
			JumpPrev = Jump;
			Attack1Prev = Attack1;
			Attack2Prev = Attack2;
			Energy1Prev = Energy1;
			Energy2Prev = Energy2;
			Energy3Prev = Energy3;
		}
	}
}
