local ControlToProgress = {}
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.packages.Trove)
local module = require("./PassiveHandler")

function ControlToProgress.Morph(data, _, object)
	local modifier = object:CreateModifier("progressefficiency", "add")
	local modifier2 = object:CreateModifier("barSize", "add")
	data.reelTrove:Add(object.OnLogicStep:Connect(function()
		if not data.current then
			return
		end

		local v = math.max(data.config.MaxBarSize, data.current.minBarSize)
		local v2 = math.max(data.current.barSize - modifier2.Value - v, 0)
		modifier.Value = v2 * data.config.ConversionRatio
		modifier2.Value = -v2
	end))
end

setmetatable(ControlToProgress, module)
return ControlToProgress