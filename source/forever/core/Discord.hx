package forever.core;

#if hxdiscord_rpc
import hxdiscord_rpc.Discord as HxDiscord;
import hxdiscord_rpc.Types;
#end

import lime.app.Application;

class Discord
{
	private static var initialized:Bool = false;
	private static var discPresence:DiscordRichPresence = DiscordRichPresence.create();

	#if hxdiscord_rpc
	public static function initializeRPC():Void
	{
		if (initialized) return;

		final evenHandlers:DiscordEventHandlers = DiscordEventHandlers.create();
		evenHandlers.ready = cpp.Function.fromStaticFunction(onReady);
		evenHandlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		evenHandlers.errored = cpp.Function.fromStaticFunction(onError);

		HxDiscord.Initialize('1031181637863620708', cpp.RawPointer.addressOf(evenHandlers), 1, null);

		Thread.create(() ->
		{
			while (true)
			{
				#if DISCORD_DISABLE_TO_THREAD
				HxDiscord.UpdateConnection();
				#end
				HxDiscord.RunCallbacks();
				Sys.sleep(2);
			}
		});

		Application.current.window.onClose.add(shutdownRPC);

		initialized = true;
	}

	static function onReady(req:cpp.RawConstPointer<DiscordUser>):Void
	{
		final user:String = req[0].username;
		final globalName:String = req[0].username;
		final discrim:String = req[0].discriminator;

		if (Std.parseInt(cast(req[0].discriminator, String)) != 0)
			trace('Successfully connected to user ${user}#${discrim} ($globalName)');
		else
			trace('Successfully connected to user ${user} ($globalName)');

		discPresence.state = null;
		discPresence.details = '';
		discPresence.largeImageKey = 'fel-logo';
		discPresence.largeImageText = 'Forever Engine Legacy';
	}

	static function onError(_code:Int, _message:cpp.ConstCharStar):Void
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:cpp.ConstCharStar):Void
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function changePresence(details:String = '', state:Null<String> = '', ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float):Void
	{
		var startTimestamp:Float = (hasStartTimestamp) ? Date.now().getTime() : 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		discPresence.state = state;
		discPresence.details = details;
		discPresence.smallImageKey = smallImageKey;
		discPresence.largeImageKey = 'fel-logo';
		discPresence.largeImageText = 'Forever Engine Legacy';
		discPresence.startTimestamp = Std.int(startTimestamp * 0.001);
		discPresence.endTimestamp = Std.int(endTimestamp * 0.001);

		HxDiscord.UpdatePresence(cpp.RawConstPointer.addressOf(discPresence));
	}

	public static function shutdownRPC():Void
	{
		HxDiscord.Shutdown();
	}
	#end
}
