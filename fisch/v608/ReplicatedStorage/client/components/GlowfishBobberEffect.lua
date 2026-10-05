game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local shared = ReplicatedStorage.shared
local world = ReplicatedStorage:WaitForChild("world")
local Component = require(packages.Component)
local GeneralUtils = require(shared.utils.GeneralUtils)
local Trove = require(packages.Trove)
local v = Component.new({
	Tag = "GlowfishBobber"
})

function v:Construct()
	self.trove = Trove.new()
end

function v.Start(p)
	local function tryApply()
		for _, part in p.Instance:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			local originalColor = part:GetAttribute("OriginalColor")

			if not originalColor then
				part:SetAttribute("OriginalColor", part.Color)
				originalColor = part.Color
			end

			local nightColor = part:GetAttribute("NightColor")
			local color = world.cycle.Value == "Night" and nightColor or originalColor
			GeneralUtils.fastTween(part, TweenInfo.new(2), {
				Color = color
			})
		end
	end

	tryApply()
	p.trove:Add(world.cycle:GetPropertyChangedSignal("Value"):Connect(function()
		tryApply()
	end))
end

function v.Stop(p)
	p.trove:Destroy()
end

return v