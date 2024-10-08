package engine.states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;

import forever.Controls;
import forever.core.FNFTransition;

/* 
	Music beat state happens to be the first thing on my list of things to add, it just so happens to be the backbone of
	most of the project in its entirety. It handles a couple of functions that have to do with actual music and songs and such.

	I'm not going to change any of this because I don't truly understand how songplaying works, 
	I mostly just wanted to rewrite the actual gameplay side of things.
 */
class MusicBeatState extends FlxUIState
{
	/**
	 * Array of notes showing when each measure/bar STARTS in STEPS
	 * Usually rounded up??
	 */
	public var curBar:Int = 0;

	public var curBeat:Int = 0;
	public var curStep:Int = 0;

	function updateBar() curBar = Math.floor(curBeat * 0.25);
	function updateBeat() curBeat = Math.floor(curStep * 0.25);

	private var controls(get, never):Controls;
	inline function get_controls():Controls
		return forever.PlayerSettings.player1.controls;

	// class create event
	override function create()
	{
		// dump
		Paths.clearStoredMemory();
		if ((!Std.isOfType(this, PlayState)) && (!Std.isOfType(this, engine.states.editors.OriginalChartingState)))
			Paths.clearUnusedMemory();

		// state stuffs
		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new FNFTransition(0.5, true));

		/*
		if (transIn != null)
			trace('reg ' + transIn.region);
		*/

		super.create();

		// For debugging
		FlxG.watch.add(Conductor, "songPosition");
		FlxG.watch.add(this, "curBeat");
		FlxG.watch.add(this, "curStep");
	}

	// class 'step' event
	override function update(elapsed:Float)
	{
		updateContents();
		super.update(elapsed);
	}

	public function updateContents()
	{
		updateCurStep();
		updateBeat();
		updateBar();

		// delta time bullshit
		var trueStep:Int = curStep;
		for (i in storedSteps)
			if (i < oldStep)
				storedSteps.remove(i);
		for (i in oldStep...trueStep)
		{
			if (!storedSteps.contains(i) && i > 0)
			{
				curStep = i;
				stepHit();
				skippedSteps.push(i);
			}
		}
		if (skippedSteps.length > 0)
		{
			//trace('skipped steps $skippedSteps');
			skippedSteps = [];
		}
		curStep = trueStep;

		//
		if (oldStep != curStep && curStep > 0 && !storedSteps.contains(curStep))
			stepHit();
		oldStep = curStep;
	}

	var oldStep:Int = 0;
	var storedSteps:Array<Int> = [];
	var skippedSteps:Array<Int> = [];

	public function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();

		// trace('step $curStep');
		if (!storedSteps.contains(curStep))
			storedSteps.push(curStep);
		else
			trace('SOMETHING WENT WRONG??? STEP REPEATED $curStep');
	}

	public function beatHit():Void
	{
		// used for updates when beats are hit in classes that extend this one
	}
}

class MusicBeatSubState extends FlxSubState
{
	public function new()
	{
		super();
	}

	/**
	 * Array of notes showing when each measure/bar STARTS in STEPS
	 * Usually rounded up??
	 */
	public var curBar: Int = 0;
	public var curBeat:Int = 0;
	public var curStep:Int = 0;

	function updateBar() curBar = Math.floor(curBeat * 0.25);
	function updateBeat() curBeat = Math.floor(curStep * 0.25);

	private var controls(get, never):Controls;
	inline function get_controls():Controls
		return forever.PlayerSettings.player1.controls;

	// class 'step' event
	override function update(elapsed:Float)
	{
		updateContents();
		super.update(elapsed);
	}

	public function updateContents()
	{
		updateCurStep();
		updateBeat();
		updateBar();

		// delta time bullshit
		var trueStep:Int = curStep;
		for (i in storedSteps)
			if (i < oldStep)
				storedSteps.remove(i);
		for (i in oldStep...trueStep)
		{
			if (!storedSteps.contains(i) && i > 0)
			{
				curStep = i;
				stepHit();
				skippedSteps.push(i);
			}
		}
		if (skippedSteps.length > 0)
		{
			//trace('skipped steps $skippedSteps');
			skippedSteps = [];
		}
		curStep = trueStep;

		//
		if (oldStep != curStep && curStep > 0 && !storedSteps.contains(curStep))
			stepHit();
		oldStep = curStep;
	}

	var oldStep:Int = 0;
	var storedSteps:Array<Int> = [];
	var skippedSteps:Array<Int> = [];

	public function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}
}
