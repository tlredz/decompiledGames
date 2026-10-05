local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ChangePlaybackSpeedWithVelocity"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(_) end

function v.SteppedUpdate(p)
	local basePart = p.Instance:FindFirstAncestorWhichIsA("BasePart")

	if not basePart then
		return
	end

	local magnitude = basePart.AssemblyLinearVelocity.Magnitude
	local playbackSpeedRange = p.Instance:GetAttribute("PlaybackSpeedRange")
	local velocityRange = p.Instance:GetAttribute("VelocityRange")
	local playbackSpeed = math.map(
		magnitude,
		velocityRange.Min,
		velocityRange.Max,
		playbackSpeedRange.Min,
		playbackSpeedRange.Max
	)
	p.Instance.PlaybackSpeed = playbackSpeed
end

function v:Stop()
	self._Janitor:Destroy()
end

return v