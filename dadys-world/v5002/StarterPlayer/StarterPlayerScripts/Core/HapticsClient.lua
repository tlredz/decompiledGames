local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HapticEffectsController = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("HapticEffectsController"))
local Network = require(ReplicatedStorage.SharedUtils:WaitForChild("Network"))
local v = {}
Network:AddAction("PlayHaptic", function(p, ...)
	if typeof(p) == "table" then
		p = p[UserInputService.PreferredInput.Name] or "UIError"
	end

	local v2 = HapticEffectsController:Play(p, ...)

	if v2 then
		v[p] = v2
	end
end)
Network:AddAction("StopHaptic", function(p, ...)
	local v2 = v[p]

	if v2 then
		v2:Stop()
		v[p] = nil
	end
end)