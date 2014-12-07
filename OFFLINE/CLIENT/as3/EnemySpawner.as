package as3 {
	
	import flash.display.MovieClip;
	
	
	public class EnemySpawner extends MovieClip {
		
		public var aabb:AABB;
		
		var worldX:Number, worldY:Number;
		
		public function EnemySpawner(x:int, y:int) {
			aabb = new AABB(x, y, width, height);
			worldX = x;
			worldY = y;
		}
		
		public function Update(cam:Camera):void{
			this.x = worldX + cam.x;
			this.y = worldY + cam.y;
			
			aabb.Update(worldX, worldY);
		}
		
		public function SpawnEnemies():Array{
			var enemies:Array = new Array();
			var turretSpawned:Boolean = false;
			var eTypesAvailable:Array = [Enemy.TURRET, Enemy.HOPPER, Enemy.AERIAL, Enemy.RANGER];
			var numToSpawn:int = Random.Range(1, 5);
			for(var i:int = 0; i < numToSpawn; i++){
				var rx:Number = Random.Range(aabb.Left, aabb.Right);
				var ry:Number = Random.Range(aabb.Top, aabb.Bottom);
				if(turretSpawned) eTypesAvailable.shift(); // removes TURRET from possible enemies if a turret has already spawned
				
				switch(Random.ChooseOne(eTypesAvailable)){
					case Enemy.TURRET:
						enemies.push(new EnemyTurret(rx, ry));
						turretSpawned = true;
						break;
					case Enemy.HOPPER:
						enemies.push(new EnemyHopper(rx, ry));
						break;
					case Enemy.AERIAL:
						enemies.push(new EnemyAerial(rx, ry));
						break;
					case Enemy.RANGER:
						enemies.push(new EnemyRanger(rx, ry));
						break;
				}
			}
			return enemies;
		}
	}
}
