local Forgiving = {}
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")

function Forgiving.MorphSpear(p, _, object)
	object:GetRandom(51)
	local count = 0
	p.reelTrove:Add(object.core.simplifiedInput.OnCorrectInput:Connect(function(p2, p3)
		if p2 == p3 then
			count += 1

			if count >= 5 then
				object.core.simplifiedInput.AcceptAny = true
			end
		else
			count = 0
			object.core.simplifiedInput.AcceptAny = false
		end
	end))
	p.reelTrove:Add(object.core.simplifiedInput.OnIncorrectInput:Connect(function()
		count = 0
		object.core.simplifiedInput.AcceptAny = false
	end))
end

setmetatable(Forgiving, module)
return Forgiving