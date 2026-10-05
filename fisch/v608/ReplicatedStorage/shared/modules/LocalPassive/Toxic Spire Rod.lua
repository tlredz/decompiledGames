local ToxicSpireRod = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local module = require("./PassiveHandler")
require(ReplicatedStorage.packages.Trove)
local color = Color3.fromRGB(67, 1, 153)

function ToxicSpireRod.Morph(p, p2, object)
	local lastTime = tick()
	local imageColor3 = p2.fish.icon.ImageColor3
	local v = object.fish.Mutation == "Toxic"
	local modifier = object:CreateModifier("movementfactor", "multiply")
	local modifier2 = object:CreateModifier("progressefficiency", "add")
	p.reelTrove:Add(RunService.Heartbeat:Connect(function()
		if not object.ready then
			lastTime = tick()
		end

		if v then
			modifier.Value = 5
			modifier2.Value = 0.7
			p2.fish.BackgroundColor3 = color
			p2.fish.icon.ImageColor3 = color
		else
			modifier.Value = math.min(1, (tick() - lastTime) / 15) * 4 + 1
			modifier2.Value = 0
			p2.fish.BackgroundColor3 = imageColor3:Lerp(color, (object.movementfactor - 1) / 4)
			p2.fish.icon.ImageColor3 = imageColor3:Lerp(color, (object.movementfactor - 1) / 4)
		end
	end))
end

setmetatable(ToxicSpireRod, module)
return ToxicSpireRod