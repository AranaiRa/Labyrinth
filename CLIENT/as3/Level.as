﻿package as3 {
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	
	public class Level extends MovieClip{

		var levelData:LevelData = new LevelData();
		var size:uint = 64; //tile size
		var grid:Array;
		var tiles:Array;
		
		public function Level() {
			grid = new Array(levelData.width);
			tiles = new Array();
			
			for (var i:uint = 0; i < levelData.width; i++){
				grid[i] = new Array();
				for (var j:uint = 0; j < levelData.height; j++){
					var pixel:uint = levelData.getPixel(i, j); 
					if(pixel.toString(16) == "0"){
						grid[i].push(1);
						var t:Tile = new Tile(size*i, size*j);
						tiles.push(t);
						addChild(t);
					}else{
						grid[i].push(0);
					}
				} // end j loop
			} // end i loop
		} 
		
		public function Update(cam:Camera):void{
			for(var i:int = 0; i < tiles.length; i++){
				tiles[i].Update(cam);
			}
		}

		public function GridToWorld(n:Number):Number{
				return (n * size) - (size/2);
		}

		public function WorldToGrid(n:Number):int{
				return (int)((n + size/2) / size);
		}
		
		public function CheckCollisionAt(px:int, py:int):Boolean {
			if (px < 0) return false; // this allows player to move outside grid area
			if (py < 0) return false;
			if (px >= grid.length) return false;
			if (py >= grid[0].length) return false;

			return (grid[px][py] > 0);
		}
		
		public function FixCollisions(player:Player):Boolean {

			var collision:Boolean = false;
			
			var minX:int = WorldToGrid(player.aabb.Left);
			var maxX:int = WorldToGrid(player.aabb.Right);
			var minY:int = WorldToGrid(player.aabb.Top);
			var maxY:int = WorldToGrid(player.aabb.Bottom);

			for (var py:int = minY; py <= maxY; py++) {
				for (var px:int = minX; px <= maxX; px++) {
					if (CheckCollisionAt(px, py)) {
						// solve for collision
						collision = true;

						var omitTop:Boolean = false;
						var omitLeft:Boolean = false;
						var omitRight:Boolean = false;
						var omitBottom:Boolean = false;

						if (CheckCollisionAt(px, py - 1)) omitBottom = true;
						if (CheckCollisionAt(px - 1, py)) omitLeft = true;
						if (CheckCollisionAt(px + 1, py)) omitRight = true;
						if (CheckCollisionAt(px, py + 1)) omitTop = true;

						var aabb:AABB = new AABB(px * size, py * size, size, size);
						aabb.Update(px*size, py*size);
						player.FixCollisionWithStaticAABB(aabb, omitTop, omitRight, omitBottom, omitLeft);
					}
				}
			}
			if (!collision) {
				player.grounded = false;
			}

			return collision;
		}
		
		public function GetValidSpawnLocation():DisplayObject {
			trace(grid);
			
			var target:int = Random.Range(1,100);
			var px:Number = 0;
			var py:Number = 0;
			
			for (var i:uint = 0; i < levelData.width; i++){
				for (var j:uint = 0; j < levelData.height; j++){
					var pixel:uint = levelData.getPixel(i, j); 
					if(pixel.toString(16) == "0"){
						target--;
						if(target == 0){
							px = j;
							py = i;
						}
					}
				} // end j loop
			} // end i loop
			
			var d:DisplayObject = new DisplayObject();
			d.x = GridToWorld(px);
			d.y = GridToWorld(py);
			
			return d;
		}
	}	
}
