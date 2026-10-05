game:GetService("ReplicatedStorage")
game:GetService("RunService")
local module = require("./PassiveHandler")
Random.new()
local Precision = {
	Morph = function(p, _, object)
		p._accelVal = object:CreateModifier("barMoveSpeed", "multiply")
		p._accelVal.Value = 1
	end,
	TickLogic_Rod = function(p, p2)
		if not p._accelVal then
			return
		end

		local _accelVal = p._accelVal

		if p2.onbar then
		end

		_accelVal.Value = p.config.OnBarAccel
	end
}
setmetatable(Precision, module)
return Precision