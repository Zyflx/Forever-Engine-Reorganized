package engine.objects.gameplay;

import flixel.ui.FlxBar;

class ClassHUD extends FlxTypedGroup<FlxBasic>
{
	var game(get, never):PlayState;

	// set up variables and stuff here
	var scoreBar:FlxText;

	// fnf mods
	var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';

	var cornerMark:FlxText; // engine mark at the upper right corner
	var centerMark:FlxText; // song display name and difficulty at the center

	public var autoplayMark:FlxText; // autoplay indicator at the center
	public var autoplaySine:Float = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	private var stupidHealth:Float = 0;

	private var timingsMap:Map<String, FlxText> = [];

	var infoDisplay:String = CoolUtil.dashToSpace(PlayState.SONG.song);
	var diffDisplay:String = CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);
	var engineDisplay:String = "FOREVER ENGINE v" + Main.gameVersion;

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();
		createHealthBar();
		createHUDText();
		updateScoreText();
	}

	public function createHealthBar() {
		// le healthbar setup
		var barY = FlxG.height * 0.875;
		if (Init.trueSettings.get('Downscroll'))
			barY = 64;

		healthBarBG = new FlxSprite(0,
			barY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('healthBar', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
		healthBarBG.screenCenter(X);
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		iconP1 = new HealthIcon(PlayState.SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height * 0.5);
		add(iconP1);

		iconP2 = new HealthIcon(PlayState.SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height * 0.5);
		add(iconP2);
	}

	var counterTextSize:Int = 20;
	var counterLeft = (Init.trueSettings.get('Counter') == 'Left');

	public function createHUDText() {
		scoreBar = new FlxText(FlxG.width * 0.5, Math.floor(healthBarBG.y + 40), 0, scoreDisplay);
		scoreBar.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE);
		scoreBar.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		scoreBar.antialiasing = true;
		add(scoreBar);

		cornerMark = new FlxText(0, 0, 0, engineDisplay);
		cornerMark.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE);
		cornerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		cornerMark.setPosition(FlxG.width - (cornerMark.width + 5), 5);
		cornerMark.antialiasing = true;
		add(cornerMark);

		centerMark = new FlxText(0, (Init.trueSettings.get('Downscroll') ? FlxG.height - 40 : 10), 0, '- ${infoDisplay + " [" + diffDisplay}] -');
		centerMark.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE);
		centerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		centerMark.screenCenter(X);
		centerMark.antialiasing = true;
		add(centerMark);

		// counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			var judgementNameArray:Array<String> = [];
			for (i in Timings.judgementsMap.keys())
				judgementNameArray.insert(Timings.judgementsMap.get(i)[0], i);
			judgementNameArray.sort(sortByShit);
			for (i in 0...judgementNameArray.length)
			{
				var textAsset:FlxText = new FlxText(5
					+ (!counterLeft ? (FlxG.width - 10) : 0),
					(FlxG.height * 0.5)
					- (counterTextSize * (judgementNameArray.length * 0.5))
					+ (i * counterTextSize), 0, '', counterTextSize);
				if (!counterLeft)
					textAsset.x -= textAsset.text.length * counterTextSize;

				textAsset.setFormat(Paths.font("vcr.ttf"), counterTextSize, FlxColor.WHITE, counterLeft ? LEFT : RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				textAsset.borderSize = 1.5;
				timingsMap.set(judgementNameArray[i], textAsset);
				add(textAsset);
			}
		}

		autoplayMark = new FlxText(-5, (Init.trueSettings.get('Downscroll') ? centerMark.y - 60 : centerMark.y + 60), FlxG.width - 800, '[AUTOPLAY]\n', 32);
		autoplayMark.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		autoplayMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		autoplayMark.visible = game.plrStrums.autoplay;
		autoplayMark.screenCenter(X);
		// repositioning for it to not be covered by the receptors
		if (Init.trueSettings.get('Centered Notefield'))
		{
			if (Init.trueSettings.get('Downscroll'))
				autoplayMark.y = autoplayMark.y - 125;
			else
				autoplayMark.y = autoplayMark.y + 125;
		}
		add(autoplayMark);
	}

	function sortByShit(Obj1:String, Obj2:String):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Timings.judgementsMap.get(Obj1)[0], Timings.judgementsMap.get(Obj2)[0]);

	override public function update(elapsed:Float)
	{
		// pain, this is like the 7th attempt
		healthBar.percent = (game.health * 50);

		var iconLerp = 1 - Main.framerateAdjust(0.15);
		// iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.initialWidth, iconP1.width, iconLerp)));
		// iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.initialWidth, iconP2.width, iconLerp)));

		// the new way of scaling the icons lmao
		iconP1.scale.set(FlxMath.lerp(1, iconP1.scale.x, iconLerp), FlxMath.lerp(1, iconP1.scale.y, iconLerp));
		iconP2.scale.set(FlxMath.lerp(1, iconP2.scale.x, iconLerp), FlxMath.lerp(1, iconP2.scale.y, iconLerp));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		iconP1.updateAnim(healthBar.percent);
		iconP2.updateAnim(100 - healthBar.percent);

		if (autoplayMark.visible)
		{
			autoplaySine += 180 * (elapsed * 0.25);
			autoplayMark.alpha = 1.0 - Math.sin((Math.PI * autoplaySine) / 80);
		}
	}

	private final divider:String = " • ";

	public function updateScoreText()
	{
		scoreDisplay = 'Score: ${game.songScore}';
		if (Init.trueSettings.get('Display Accuracy'))
		{
			var comboDisplay:String = (Timings.comboDisplay != '' ? ' [${Timings.comboDisplay}] ' : '');
			scoreDisplay += divider + 'Accuracy: ${Math.floor(Timings.getAccuracy() * 100) / 100}%' + comboDisplay;
			scoreDisplay += divider + 'Combo Breaks: ${game.misses}';
			scoreDisplay += divider + 'Rank: ${Timings.returnScoreRating().toUpperCase()}';
		}

		scoreBar.text = '$scoreDisplay\n';
		scoreBar.screenCenter(X);

		// update counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			for (i in timingsMap.keys())
			{
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${Timings.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!counterLeft ? (FlxG.width - 10) : 0) - (!counterLeft ? (6 * counterTextSize) : 0));
			}
		}

		// update game
		PlayState.detailsSub = scoreBar.text;
		PlayState.updateRPC(false);
	}

	public function beatHit()
	{
		if (!Init.trueSettings.get('Reduced Movements'))
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
	}

	@:noCompletion
	function get_game():PlayState
		return PlayState.current;
}
