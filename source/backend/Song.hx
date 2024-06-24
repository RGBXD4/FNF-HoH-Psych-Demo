package backend;

import tjson.TJSON as Json;
import lime.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import backend.Section;

typedef SwagSong = {
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	@:optional var gameOverChar:String;
	@:optional var gameOverSound:String;
	@:optional var gameOverLoop:String;
	@:optional var gameOverEnd:String;

	@:optional var disableNoteRGB:Bool;

	@:optional var arrowSkin:String;
	@:optional var splashSkin:String;
}

class Song {
	private static function onLoadJson(songJson:Dynamic) // Convert old charts to newest format
	{
		if (songJson.gfVersion == null) {
			songJson.gfVersion = songJson.player3;
			songJson.player3 = null;
		}

		if (songJson.events == null) {
			songJson.events = [];
			for (secNum in 0...songJson.notes.length) {
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while (i < len) {
					var note:Array<Dynamic> = notes[i];
					if (note[1] < 0) {
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					} else
						i++;
				}
			}
		}

		return songJson;
	}

	public static function getChartPath(jsonInput:String, folder:String):String {
		// fileName = jsonInput;
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson(formattedFolder + '/' + formattedSong);
		if (FileSystem.exists(moddyFile)) {
			return moddyFile;
		}
		#end

		return Paths.json(formattedFolder + '/' + formattedSong);
	}

	public static function getExistingSongs(list:Array<String>, diffic:String):{
		songs:Array<String>,
		missingSongs:Array<String>
	} {
		var missingSongs:Array<String> = [];
		var songs:Array<String> = [];
		for (song in list) {
			if (Song.doesChartExist(song + diffic, song)) {
				songs.push(song);
			} else {
				missingSongs.push(CoolUtil.trimTextStart(Song.getChartPath(song + diffic, song), "assets/data/"));
			}
		}

		return {
			songs: songs,
			missingSongs: missingSongs
		};
	}

	public static function doesChartExist(jsonInput:String, folder:String):Bool {
		var file = getChartPath(jsonInput, folder);

		#if sys
		return FileSystem.exists(file);
		#else
		return Assets.exists(file, TEXT);
		#end
	}

	public static function getChartData(jsonInput:String, folder:String):String {
		var file = getChartPath(jsonInput, folder);

		#if sys
		return File.getContent(file).trim();
		#else
		return Assets.getText(file, TEXT).trim();
		#end
	}

	public static function loadFromJson(jsonInput:String, folder:String):SwagSong {
		var rawJson:String = getChartData(jsonInput, folder);
		rawJson = rawJson.substr(0, rawJson.lastIndexOf('}') + 1);

		var songJson:SwagSong = parseJSONshit(rawJson);
		if (jsonInput != 'events') {
			StageData.loadDirectory(songJson);
		}
		return songJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong {
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		return onLoadJson(swagShit);
	}
}
