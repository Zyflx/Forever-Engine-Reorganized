#if !macro
#if (flixel > "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
#end

#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import sys.thread.Thread;
import sys.thread.Mutex;
#end

#if desktop
import forever.core.Discord;
#end

import openfl.utils.Assets;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxSort;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

import forver.util.*;

import engine.graphics.FNFSprite;

import engine.states.PlayState;
import engine.states.MusicBeat.MusicBeatState;
import engine.states.MusicBeat.MusicBeatSubState;

import forver.core.components.Conductor;
import forver.core.components.Highscore;
import forever.core.components.Timings;

using StringTools;