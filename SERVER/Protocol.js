//var PlayerCommand = require("./PlayerCommand.js").PlayerCommand;

exports.Protocol = {
	////////////// CLIENT:
	HOST_LOBBY:1,
	JOIN_LOBBY:2,
	LEAVE_LOBBY:3,
	START_GAME:4,
	INPUT:5,
	////////////// SERVER:
	BROADCAST_LOBBY_LIST: 6,
	LOBBY_FULL: 7,
	JOIN_ACCEPT: 8,
	BROADCAST_LOBBY_STATE: 9,
	START_ACCEPT: 10,
	TIME_LEFT: 11,
	WORLDSTATE_PLAYERINFO: 12,
	WORLDSTATE_PLAYERATTACKINFO: 13,
	WORLDSTATE_SPAWNERINFO: 14,
	WORLDSTATE_ENEMYINFO: 15,
	WORLDSTATE_PICKUPINFO: 16,
	GAMEOVER: 17
};