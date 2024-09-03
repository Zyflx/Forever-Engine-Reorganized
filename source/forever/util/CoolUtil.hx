package forever.util;

class CoolUtil
{
	public static final difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];
	public static var difficultyLength = difficultyArray.length;

	public static inline function difficultyFromNumber(number:Int):String
	{
		return difficultyArray[number];
	}

	public static inline function dashToSpace(string:String):String
	{
		return string.replace("-", " ");
	}

	public static inline function spaceToDash(string:String):String
	{
		return string.replace(" ", "-");
	}

	public static inline function swapSpaceDash(string:String):String
	{
		return string.contains('-') ? dashToSpace(string) : spaceToDash(string);
	}

	public static inline function coolTextFile(path:String):Array<String>
	{
		return [for (i in Assets.getText(path).trim().split('\n')) i.trim()];
	}

	public static inline function getOffsetsFromTxt(path:String):Array<Array<String>>
	{
		return [for (i in Assets.getText(path).split('\n')) i.split(' ')];
	}

	public static inline function returnAssetsLibrary(library:String, ?subDir:String = 'assets/images'):Array<String>
	{
		var libraryArray:Array<String> = [];

		#if sys
		var unfilteredLibrary = FileSystem.readDirectory('$subDir/$library');

		for (folder in unfilteredLibrary)
		{
			if (!folder.contains('.'))
				libraryArray.push(folder);
		}
		//trace(libraryArray);
		#end

		return libraryArray;
	}

	public static inline function getAnimsFromTxt(path:String):Array<Array<String>>
	{
		return [for (i in Assets.getText(path).split('\n')) i.split('--')];
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		return [for (i in min...max) i];
	}
}
