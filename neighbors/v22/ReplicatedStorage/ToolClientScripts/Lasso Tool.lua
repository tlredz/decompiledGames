local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local modules = ReplicatedStorage.Modules
local House = require(modules.Neighbors.House)
local Raycast = require(script.Raycast)
local v = Raycast.new()
local localPlayer = Players.LocalPlayer
local lassoSounds = ReplicatedStorage.Assets.Tools.LassoSounds
local _ = {
	MaxDistance = 1024
}
require(modules.Tool)

-- equivalent calls inferred from this helper; original call sites unknown
local function partIsALimb(part)
	if not part:IsA("BasePart") then
		return
	end

	local model = part:FindFirstAncestorOfClass("Model")

	if model and model:FindFirstChildOfClass("Humanoid") then
		return true
	end

	return false
end

return {
	Activated = function(p)
		local v2 = { localPlayer.Character }
		v:UpdateParams(v2)
		local v3 = v:TraceMouse(1024)
		local v4 = false

		if v3 then
			local v5 = partIsALimb(v3.Instance) -- equivalent call inferred; original call site unknown
			v4 = (v3.Instance:IsDescendantOf(House:GetCurrentPrefab().Model) or v3.Instance:IsDescendantOf(House:GetCurrentHouse().Model)) and true or v5 and true or false
		end

		if v3 and (v3.Position - v2[1].PrimaryPart.Position).Magnitude < 32 and v4 then
			local v5 = partIsALimb(v3.Instance) -- equivalent call inferred; original call site unknown
			local instance2 = v3.Instance
			local position = v3.Position

			if p.Tool.RopeEvent:InvokeServer(not v5 and "ClientInstance" or instance2, position) then
				lassoSounds.CreateRope:Play()
			else
				lassoSounds.FailToCreateRope:Play()
			end
		else
			warn("Clicked nothing.")
			lassoSounds.FailToCreateRope:Play()
		end
	end
}