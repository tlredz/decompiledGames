local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local EffectsEvent = require(ReplicatedStorage.Communication.ServerAndClient.Effects.EffectsEvent)
return function(list)
	for _, v in ipairs(list) do
		local character = v.Character

		if character == nil then
			continue
		end

		Utility.ClearChildren(character:FindFirstChild("SHCS"))
		EffectsEvent.ToClient(v, "reset_cooldowns")
	end
end