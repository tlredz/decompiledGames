local Frenzy = {}
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")

function Frenzy.MorphSpear(p, _, object)
	local modifier = object:CreateModifier("progressefficiency", "add")
	p.reelTrove:Add(object.core.simplifiedInput.OnCorrectInput:Connect(function()
		modifier.Value += p.config.ProgressSpeed / 100
	end))
	p.reelTrove:Add(object.core.simplifiedInput.OnIncorrectInput:Connect(function()
		modifier.Value = 0
	end))
end

setmetatable(Frenzy, module)
return Frenzy