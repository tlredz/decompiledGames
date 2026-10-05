local LocomotionTracks = {}
LocomotionTracks.__index = LocomotionTracks
local v = {
	"Idle",
	"Walk",
	"Run",
	"Left",
	"Right",
	"Back",
	"Fall",
	"Stop",
	"Land",
	"CaughtIdle"
}
local v2 = {
	Stop = true,
	Land = true
}

function LocomotionTracks.new(animator, assets)
	return (setmetatable({
		animator = animator,
		assets = assets,
		tracks = {},
		entries = {},
		nextCheck = 0
	}, LocomotionTracks))
end

function LocomotionTracks:refresh(at)
	if at < self.nextCheck then
		return
	end

	self.nextCheck = at + 1

	for _, v3 in v do
		local asset = self.assets[v3]

		if not asset then
			continue
		end

		local entry = self.entries[v3]

		if entry and entry.track and entry.track.Length > 0 then
			continue
		end

		local v4 = not entry and 0 or math.min(60, math.max(1, entry.attempt) * 20) or 0

		if entry and at - entry.at < v4 then
			continue
		end

		local attempt = not entry and 1 or entry.attempt + 1 or 1

		if entry and entry.track then
			entry.track:Destroy()
			self.tracks[v3] = nil
		end

		local v6 = asset
		local success, result = pcall(function()
			return self.animator:LoadAnimation(v6.animation)
		end)
		local v7 = {
			at = at,
			attempt = attempt
		}
		self.entries[v3] = v7

		if success then
			result.Name = "CoH_" .. v3
			result.Looped = not v2[v3]
			result.Priority = v3 == "CaughtIdle" and Enum.AnimationPriority.Action2 or v2[v3] and Enum.AnimationPriority.Action or Enum.AnimationPriority.Movement
			v7.track = result
			self.tracks[v3] = result
		elseif attempt == 1 then
			warn("Animation temporarily unavailable; will retry:", v3, result)
		end
	end
end

function LocomotionTracks.ready(p)
	return p ~= nil and p.Length > 0
end

function LocomotionTracks.coreReady(p)
	return LocomotionTracks.ready(p.tracks.Idle) and LocomotionTracks.ready(p.tracks.Walk) and LocomotionTracks.ready(p.tracks.Run)
end

function LocomotionTracks.weights(p, items)
	local result = {}

	for k, item in items do
		if not LocomotionTracks.ready(p.tracks[k]) then
			if k == "Left" or k == "Right" or k == "Back" then
				k = LocomotionTracks.ready(p.tracks.Walk) and "Walk" or "Run"
			else
				k = (k == "Fall" or k == "CaughtIdle") and "Idle" or k
			end
		end

		if LocomotionTracks.ready(p.tracks[k]) then
			result[k] = (result[k] or 0) + item
		end
	end

	return result
end

function LocomotionTracks.destroy(p)
	for _, track in p.tracks do
		track:Stop(0.1)
		track:Destroy()
	end

	table.clear(p.tracks)
	table.clear(p.entries)
end

return LocomotionTracks