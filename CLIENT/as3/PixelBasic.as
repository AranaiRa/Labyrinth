package as3 {
	
	import flash.display.MovieClip;
	import flash.display.*;
	import flash.utils.*;
	
	public class PixelBasic extends MovieClip {
		
		var id:uint;
		
		public function PixelBasic() {
			id = setInterval(CleanUp, 1500);
		}
		
		function CleanUp():void{
			clearInterval(id);
			this.parent.removeChild(this);
		}
	}
	
}
