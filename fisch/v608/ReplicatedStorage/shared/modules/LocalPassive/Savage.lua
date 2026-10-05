local Savage = {}
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")

function Savage.MorphSpear(p, _, object)
	local random = object:GetRandom(51)
	local flag = false
	p.reelTrove:Add(object.core.simplifiedInput.OnCorrectInput:Connect(function(p2, p3)
		if flag then
			flag = false
		elseif random:NextNumber(0, 100) < p.config.TriggerChance then
			flag = true
			object.core.simplifiedInput.OnCorrectInput:Fire(p2, p3)
		end
	end))
end

setmetatable(Savage, module)
return Savage