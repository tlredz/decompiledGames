local MusicPlayer = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}
MusicPlayer.Playing = false
MusicPlayer.CurrentPlaylist = "Generic"
MusicPlayer.PlaylistQueues = {}
MusicPlayer.CurrentlyPlaying = nil
MusicPlayer.Playlists = {}
local folder = Instance.new("Folder")
folder.Name = "Music"
folder.Parent = game.Players.LocalPlayer

function TweenTrackVolume(p, p2, p3, callback)
	if v[p] then
		v[p]:Stop()
		v[p] = nil
	end

	local v2 = p2 - p.Volume

	if math.abs(v2) == 0 then
		return
	end

	local v3 = math.abs(v2) * p3
	local volume = p.Volume
	local tweenModule = Client.TweenModule.new(function(p4)
		p.Volume = volume + v2 * p4
	end, v3)

	if callback then
		tweenModule:BindToComplete(function(p4)
			if p4 then
				callback()
			end
		end)
	end

	v[p] = tweenModule
	tweenModule:Start()
end

function MusicPlayer:Pause(_)
	MusicPlayer.Playing = false

	if MusicPlayer.CurrentlyPlaying then
		MusicPlayer.CurrentlyPlaying.Track:Pause()
	end
end

function GenerateQueueFromPlaylist(p)
	local playlist = MusicPlayer.Playlists[p]
	local result = {}

	for k, v2 in pairs(playlist) do
		local _ = "Song" .. v2
		local sound = Instance.new("Sound")
		sound.SoundId = "http://www.roblox.com/asset/?id=" .. v2
		sound.Archivable = false
		sound.Name = k
		sound.Parent = folder
		table.insert(result, sound)
	end

	RandomiseArray(result)

	for i = 1, #result do
		table.insert(result, result[i])
	end

	MusicPlayer.PlaylistQueues[p] = result
	return result
end

function ClearCurrentlyPlaying()
	if MusicPlayer.CurrentlyPlaying and MusicPlayer.CurrentlyPlaying.EndedEvent then
		MusicPlayer.CurrentlyPlaying.EndedEvent:Disconnect()
		MusicPlayer.CurrentlyPlaying.EndedEvent = nil
	end

	MusicPlayer.CurrentlyPlaying = nil
end

function MusicPlayer.SetPlaylist(_, currentPlaylist, _)
	if MusicPlayer.CurrentPlaylist == currentPlaylist then
		return
	end

	MusicPlayer.CurrentPlaylist = currentPlaylist

	if MusicPlayer.CurrentlyPlaying then
		local track = MusicPlayer.CurrentlyPlaying.Track
		TweenTrackVolume(track, 0, 1, function()
			track:Pause()
		end)
	end

	ClearCurrentlyPlaying()

	if MusicPlayer.Playing then
		MusicPlayer:Resume(1)
	end
end

function MusicPlayer:Resume(p)
	MusicPlayer.Playing = true

	if MusicPlayer.CurrentlyPlaying then
		TweenTrackVolume(MusicPlayer.CurrentlyPlaying.Track, 0.5, 0.4)
		MusicPlayer.CurrentlyPlaying.Track:Resume()
	else
		local currentPlaylist = MusicPlayer.CurrentPlaylist
		local v2 = MusicPlayer.PlaylistQueues[currentPlaylist] or GenerateQueueFromPlaylist(currentPlaylist)
		local track = v2[1]
		MusicPlayer.CurrentlyPlaying = {
			Track = track
		}

		if p then
			track.Volume = 0
			TweenTrackVolume(track, 0.5, p)
		else
			TweenTrackVolume(track, 0.5, 0.4)
		end

		MusicPlayer.CurrentlyPlaying.EndedEvent = track.Ended:Connect(function()
			table.remove(v2, 1)
			table.insert(v2, track)

			if MusicPlayer.CurrentlyPlaying and MusicPlayer.CurrentlyPlaying.Track == track then
				ClearCurrentlyPlaying()

				if currentPlaylist == MusicPlayer.CurrentPlaylist and MusicPlayer.Playing then
					MusicPlayer:Resume()
				end
			end
		end)
		track:Resume()
	end
end

function RandomiseArray(list)
	for i = 1, #list do
		local v2 = math.random(#list)
		local v3 = list[v2]
		local v4 = list[i]
		list[i] = v3
		list[v2] = v4
	end
end

function MusicPlayer.Init() end

return MusicPlayer