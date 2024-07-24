package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.graphics.FlxGraphic;

enum abstract Charm(String) to String {
	var MelodicShell = "Melodic Shell";
	var BaldursBlessing = "Baldur's Blessing";
	var LifebloodSeed = "Lifeblood Seed";
	var CriticalFocus = "Critical Focus";

	var Swindler = "Swindler"; // Shop item, just nld using it, not a real charm
}

class DataSaver {
	public static function getCharmImage(charm:Charm) {
		return Paths.image('charms/$charm/base', 'hymns');
	}

	public static function getDesc(charm:Charm) {
		return Paths.getContent('charms/$charm/desc.txt', 'hymns');
	}

	public static function getCost(charm:Charm) {
		return switch (charm) {
			case MelodicShell: 0;
			case BaldursBlessing: 3;
			case LifebloodSeed: 2;
			case CriticalFocus: 2;
			default: 0;
		}
	}

	public static var isOvercharmed(get, never):Bool;

	private static function get_isOvercharmed() {
		return usedNotches > 5;
	}

	public static final allCharms:Array<Charm> = [MelodicShell, BaldursBlessing, LifebloodSeed, CriticalFocus];
	public static final allCharmsInternal:Array<Charm> = [MelodicShell, BaldursBlessing, LifebloodSeed, CriticalFocus, Swindler];

	public static var allowSaving:Bool = true;

	// needs to be saved
	public static var geo:Int = 0;
	public static var charms:Map<Charm, Bool> = new Map();
	public static var charmsunlocked:Map<Charm, Bool> = new Map();
	public static var songScores:Map<String, Int> = new Map();
	public static var weekScores:Map<String, Int> = new Map();
	public static var songRating:Map<String, Float> = new Map();
	public static var unlocked:Map<String, String> = new Map();
	public static var played:Bool = false;
	public static var elderbugstate:Int = 0;
	public static var slytries:Int = 0;
	public static var usedNotches:Int = 0;

	public static var lichendone:Bool = false;
	public static var diedonfirststeps:Bool = false;
	public static var interacts = [false, false, false];

	public static var charmOrder:Array<Int> = [];
	public static var sillyOrder:Array<Charm> = [];

	public static var curSave:FlxSave = null;
	
	// vars
	public static var saveFile:Int = 1;
	public static var doingsong:String = '';

	public static function setIfNotNull(obj:Dynamic, fieldName:String, value:Dynamic) {
		if (obj != null && value != null) {
			Reflect.setField(obj, fieldName, value);
		}
	}

	public static function retrieveSaveValue(saveKey:String, variable:Dynamic):Dynamic {
		if(curSave == null) {
			checkSave(DataSaver.saveFile);
			return null;
		}

		var value:Dynamic = Reflect.hasField(curSave.data, saveKey);
		if (value) {
			Reflect.setField(DataSaver, variable, value);
			return value;
		}
		
		trace('Error: value ${saveKey} is null');
		return null;
	}

	public static function checkSave(saveFileData:Int){
		if(DataSaver.curSave == null || DataSaver.saveFile != saveFileData){
			//DataSaver.curSave = new FlxSave();
			//DataSaver.curSave.bind('saveData' + DataSaver.saveFile, 'hymns');	
			DataSaver.saveFile = saveFileData;
		}
	}

	public static function saveSettings(?saveFileData:Int) {
		if (!allowSaving)
			return;

		//saveFile = saveFileData;
		checkSave(saveFileData);
		
		if(curSave == null) {
			trace("save file not created");
			return;
		}
		setIfNotNull(curSave.data, 'geo', geo);
		setIfNotNull(curSave.data, 'charms', charms);
		setIfNotNull(curSave.data, 'charmsunlocked', charmsunlocked);
		setIfNotNull(curSave.data, 'songScores', songScores);
		setIfNotNull(curSave.data, 'weekScores', weekScores);
		setIfNotNull(curSave.data, 'songRating', songRating);
		setIfNotNull(curSave.data, 'unlocked', unlocked);
		setIfNotNull(curSave.data, 'played', played);
		setIfNotNull(curSave.data, 'elderbugstate', elderbugstate);
		setIfNotNull(curSave.data, 'charmOrder', charmOrder);
		setIfNotNull(curSave.data, 'slytries', slytries);
		// setIfNotNull(curSave.data, 'usedNotches', usedNotches);
		setIfNotNull(curSave.data, 'doingsong', doingsong);
		setIfNotNull(curSave.data, 'lichendone', lichendone);
		setIfNotNull(curSave.data, 'diedonfirststeps', diedonfirststeps);
		setIfNotNull(curSave.data, 'interacts', interacts);
		setIfNotNull(curSave.data, 'sillyOrder', sillyOrder);

		curSave.flush();
		FlxG.log.add("Settings saved!");
		trace("Saved Savefile");
	}


	public static function setDefaultValues() {
		geo = 0;
		charms = [MelodicShell => false,];
		charmsunlocked = [MelodicShell => false, Swindler => false,];
		songScores = new Map();
		weekScores = new Map();
		songRating = new Map();
		unlocked = new Map();
		played = false;
		elderbugstate = 0;
		charmOrder = [];
		slytries = 0;
		usedNotches = 0;
		doingsong = '';
		lichendone = false;
		diedonfirststeps = false;
		interacts = [false, false, false];
		sillyOrder = [];
	}
	

	
	public static function loadData(note:String) {
		if (!allowSaving)
			return;

		trace(note);
		checkSave(DataSaver.saveFile);
	
		//resetData();
		retrieveSaveValue("geo", "geo");
		retrieveSaveValue("charms", "charms");
		retrieveSaveValue("charmsunlocked", "charmsunlocked");
		retrieveSaveValue("songScores", "songScores");
		retrieveSaveValue("weekScores", "weekScores");
		retrieveSaveValue("songRating", "songRating");
		retrieveSaveValue("unlocked", "unlocked");
		retrieveSaveValue("played", "played");
		retrieveSaveValue("elderbugstate", "elderbugstate");
		retrieveSaveValue("charmOrder", "charmOrder");
		retrieveSaveValue("slytries", "slytries");
		retrieveSaveValue("doingsong", "doingsong");
		retrieveSaveValue("lichendone", "lichendone");
		retrieveSaveValue("diedonfirststeps", "diedonfirststeps");
		retrieveSaveValue("interacts", "interacts");
		if (retrieveSaveValue("sillyOrder", "sillyOrder")!= null ) {
			fixSillyOrder();
		}

		// Etrace(sillyOrder);

		// remove unequipped charms from sillyOrder

		usedNotches = calculateNotches();

		if(curSave!=null){
			curSave.flush();
		}
		FlxG.log.add("Loaded!");
		trace("Loaded Savefile");
	}

	public static function fixSillyOrder() {
		for (charm => equipped in charms) {
			if (!equipped) {
				while (sillyOrder.contains(charm))
					sillyOrder.remove(charm);
			}
		}

		// trace(sillyOrder);

		// remove duplicate charms from sillyOrder
		var silly = [];
		for (charm in sillyOrder) {
			if (!silly.contains(charm))
				silly.push(charm);
		}

		// trace(silly);
		sillyOrder = silly;
	}

	public static function calculateNotches() {
		var notches = 0;
		for (charm => equipped in charms) {
			if (equipped) {
				notches += DataSaver.getCost(charm);
			}
		}
		return notches;
	}

	public static function wipeData(saveFileData:Int) {
		saveFile = saveFileData;

		var curSave:FlxSave = new FlxSave();
		curSave.bind('saveData' + saveFile, 'hymns');
		curSave.erase();

		setDefaultValues();
		FlxG.log.add("Wiped data from SaveFile : " + saveFile);
	}
}
