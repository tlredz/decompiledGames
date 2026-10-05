local Finisher = {}
game:GetService("ReplicatedStorage")
game:GetService("RunService")
local module = require("./PassiveHandler")

function Finisher.MorphSpear(p, _, object)
	local v = table.create(#p.config.ModifierNames)

	for k, modifierName in p.config.ModifierNames do
		v[k] = object:CreateModifier(modifierName, "multiply")
	end

	p.reelTrove:Add(object.OnLogicStep:Connect(function()
		local v2 = not (object.progress >= p.config.ProgressThreshold) and 1 or p.config.StatMultiplier

		for _, v3 in ipairs(v) do
			v3.Value = v2
		end
	end))
end

setmetatable(Finisher, module)
return Finisher