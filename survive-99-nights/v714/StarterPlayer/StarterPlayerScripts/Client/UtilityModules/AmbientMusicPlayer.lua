local createVector = vector.create
local AmbientMusicPlayer = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}
local childrenByName = {}
local v2 = {}
AmbientMusicPlayer.CurrentlyPlaying = nil
local position = createVector(0, 0, 0)

function TweenTrackVolume(p, p2, p3, callback)
	if v[p] then
		v[p]:Stop()
		v[p] = nil
	end

	local v3 = p2 - p.Volume

	if math.abs(v3) == 0 then
		return
	end

	local v4 = math.abs(v3) * p3
	local volume = p.Volume
	local tweenModule = Client.TweenModule.new(function(p4)
		p.Volume = volume + v3 * p4
	end, v4)

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

function GetClosestMusicZone()
	if localPlayer.Character then
		position = localPlayer.Character:GetPivot().Position
	end

	local v3 = 1e999
	local v4 = nil

	for _, v5 in pairs(v2) do
		local v6 = math.abs(position.Y - v5.Position.Y)
		local magnitude = ((position - v5.Position) * createVector(1, 0, 1)).Magnitude

		if not (math.abs(v6) < v5.MaxHeight and magnitude < v5.MaxRadius and magnitude < v3) then
			continue
		end

		v4 = v5
		v3 = magnitude
	end

	return v4
end

function UpdateClosestMusicZone()
	local v3 = GetClosestMusicZone()
	local trackName

	if v3 then
		trackName = v3.TrackName or nil
	end

	local v4 = AmbientMusicPlayer.CurrentlyPlaying and AmbientMusicPlayer.CurrentlyPlaying ~= trackName and childrenByName[AmbientMusicPlayer.CurrentlyPlaying]

	if v4 then
		TweenTrackVolume(v4, 0, 1, function(p)
			if p then
				v4:Pause()
			end
		end)
	end

	local v5 = trackName and AmbientMusicPlayer.CurrentlyPlaying ~= trackName and childrenByName[trackName]

	if v5 then
		v5.Volume = 0
		v5:Resume()
		local volume = v3.Volume or 0.5
		TweenTrackVolume(v5, volume, 1)
	end

	AmbientMusicPlayer.CurrentlyPlaying = trackName
end

function LoopUpdateMusicZones()
	while true do
		UpdateClosestMusicZone()
		task.wait(1)
	end
end

function MusicEmitterAdded(object)
	if v2[object] then
		return
	end

	local attributes = object:GetAttributes()
	attributes.Position = object.Position
	v2[object] = attributes
	UpdateClosestMusicZone()
end

function MusicEmitterRemoved(p)
	v2[p] = nil
	UpdateClosestMusicZone()
end

function LoadMusicZones()
	Client.Utility.ForAllTagged("MusicEmitter", MusicEmitterAdded, MusicEmitterRemoved)

	for _, child in pairs(game.SoundService:GetChildren()) do
		childrenByName[child.Name] = child
	end
end

function AmbientMusicPlayer.Init()
	task.spawn(function()
		LoadMusicZones()
		Client.Events.PlayerTeleported:Connect(function()
			UpdateClosestMusicZone()
		end)
		LoopUpdateMusicZones()
	end)
end

return AmbientMusicPlayer