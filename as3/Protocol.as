﻿package as3 {
	
	public class Protocol {
		////////////// CLIENT:
		public static var HOST_LOBBY:int = 1;
		public static var JOIN_LOBBY:int = 2;
		public static var LEAVE_LOBBY:int = 3;
		public static var START_GAME:int = 4;
		public static var INPUT:int = 5;
		////////////// SERVER:
		public static var BROADCAST_LOBBY_LIST:int =  6;
		public static var LOBBY_FULL:int =  7;
		public static var JOIN_ACCEPT:int =  8;
		public static var BROADCAST_LOBBY_STATE:int =  9;
		public static var START_ACCEPT:int =  10;
		public static var TIME_LEFT:int =  11;
		public static var WORLDSTATE_PLAYERINFO:int =  12;
		public static var WORLDSTATE_PLAYERATTACKINFO:int =  13;
		public static var WORLDSTATE_SPAWNERINFO:int =  14;
		public static var WORLDSTATE_ENEMYINFO:int =  15;
		public static var WORLDSTATE_PICKUPINFO:int =  16;
		public static var GAMEOVER:int =  17;
	}
}
