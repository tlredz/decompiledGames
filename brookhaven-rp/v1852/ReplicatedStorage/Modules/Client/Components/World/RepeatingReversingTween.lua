local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local v = Component.new({
	Tag = "RepeatingReversingTween"
})

function v.Construct(_) end

function v.Start(p)
	local parts = p.Instance:GetAttribute("TweenProperties"):split(",")
	local attributesByPart = {}

	for _, part in parts do
		attributesByPart[part] = p.Instance:GetAttribute("Value_" .. part)
	end

	TweenService:Create(
		p.Instance,
		TweenInfo.new(
			p.Instance:GetAttribute("TweenDuration"),
			Enum.EasingStyle[p.Instance:GetAttribute("EasingStyle") or "Linear"],
			Enum.EasingDirection[p.Instance:GetAttribute("EasingDirection") or "InOut"],
			-1,
			true,
			p.Instance:GetAttribute("Delay") or 0
		),
		attributesByPart
	):Play()
end

function v:Stop()
	self.active = false
end

return v