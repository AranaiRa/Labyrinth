package as3 {
	
	import flash.display.MovieClip;
	
	
	public class EnemyTurret extends Enemy {
						
		public function EnemyTurret() {
			super();
		}
		
		public override function Update(cam:Camera, player:Player):void{
			super.Update(cam, player);		
		}
	}	
}
