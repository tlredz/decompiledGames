local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Client.Music.MusicContext)
local MusicsConfig = require(ReplicatedStorage.Modules.Shared.DB.Musics.MusicsConfig)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local InstanceMusicContext = {}
InstanceMusicContext.__index = InstanceMusicContext

function InstanceMusicContext.new(instance, maxVolume: number)
	return (setmetatable({
		_janitor = Janitor.new(),
		instance = instance,
		maxVolume = maxVolume,
		signal = Signal.new()
	}, InstanceMusicContext))
end

function InstanceMusicContext.GetStatus(p)
	local soundId = p.instance.SoundId
	local v, v2 = soundId:find("rbxassetid://", 1, true)
	local trackId, songName

	if v == 1 then
		trackId = assert((tonumber(soundId:sub(v2 + 1))))
		songName = MusicsConfig.GetMusicFromId(trackId).SongName
	end

	return {
		volume = math.round((p.instance:GetAttribute("StoredVolume") or p.instance.Volume) / p.maxVolume * 100),
		isPlaying = p.instance.IsPlaying,
		track = songName,
		trackId = trackId
	}
end

function InstanceMusicContext.OnStatusUpdate(p)
	return p.signal
end

function InstanceMusicContext.Play(p)
	Remotes.fireServerComponent(p.instance, "MusicPlay")
end

function InstanceMusicContext.Select(p, p2: number)
	Remotes.fireServerComponent(p.instance, "MusicSelect", p2)
end

function InstanceMusicContext.Stop(p)
	Remotes.fireServerComponent(p.instance, "MusicStop")
end

function InstanceMusicContext.Volume(p, p2: number)
	Remotes.fireServerComponent(p.instance, "MusicVolume", p2)
end

function InstanceMusicContext:Listen()
	self._janitor:Add(Remotes.connectComponentRemote(self.instance, "MusicUpdated", function()
		self.signal:Fire()
	end))
end

function InstanceMusicContext:Destroy()
	self._janitor:Destroy()
end

return InstanceMusicContext