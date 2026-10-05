local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local module = require("./PassiveHandler")
local fish = require(ReplicatedStorage.shared.modules.library.fish)

local function modifierValue(value)
	if typeof(value) == "number" then
		return value
	end

	return value.Value
end

local GenericHuntForcedProgress = {
	Morph = function(p, _, object)
		local v = fish[object.fish.Name]

		if not (v and v.IsHuntFish) then
			return
		end

		local config = p.config
		local v2 = object:GetRandom(7):NextNumber(config.MinPercent, config.MaxPercent) / 100
		local modifier = object:CreateModifier("progressefficiency", "add")
		local modifier2 = object:CreateModifier("progressefficiency", "force_add")
		p.reelTrove:Connect(object.OnLogicStep, function()
			local progressefficiency = object._active_modifiers.progressefficiency

			if not progressefficiency then
				return
			end

			local v3 = 0

			for _, value in progressefficiency.add or {} do
				if value == modifier then
					continue
				end

				if typeof(value) ~= "number" then
					value = value.Value
				end

				v3 += value
			end

			for _, value in progressefficiency.multiply or {} do
				if typeof(value) ~= "number" then
					value = value.Value
				end

				v3 *= value
			end

			local v4 = math.max(v3 - 1, 0) * v2
			modifier.Value = -v4
			modifier2.Value = v4
		end)
	end
}
setmetatable(GenericHuntForcedProgress, module)
return GenericHuntForcedProgress