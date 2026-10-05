local NorthPole = {}
NorthPole.__index = NorthPole
game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")

function NorthPole.Morph(p, _, object)
	local modifier = object:CreateModifier("progressefficiency", "force_add")
	local modifier2 = object:CreateModifier("progressefficiency", "add")
	p.reelTrove:Add(object.OnLogicStep:Connect(function()
		if object.onbar then
			modifier.Value = 0.1
			modifier2.Value = 0.4
		else
			modifier.Value = 0
			modifier2.Value = 0
		end
	end))
end

setmetatable(NorthPole, module)
return NorthPole