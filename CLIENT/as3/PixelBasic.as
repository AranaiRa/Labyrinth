package as3 {
	
	import flash.display.MovieClip;
	import flash.display.*;
	import flash.utils.*;
	
	public class PixelBasic extends MovieClip {
		
		public function PixelBasic() {
			setInterval(CleanUp, 1500);
			trace("initialized");
		}
		
		function CleanUp():void{
			trace("cleaning up");
			this.parent.removeChild(this);
		}
	}
	
}
