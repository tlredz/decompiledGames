local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
local _ = ReplicatedStorage.resources.replicated.fishing.customreels.venomfangrod
local module = require("./PassiveHandler")
local VenomfangRod = {
	Morph = function(p, p2)
		local position = p2.Position
		local count = 0
		p.reelTrove:Add(RunService.Heartbeat:Connect(function()
			count += 1

			if count % 2 == 0 then
				p2.Position = position + UDim2.fromScale(
					Random.new():NextNumber(-0.01, 0.01),
					Random.new():NextNumber(-0.02, 0.02)
				)
				p2.Rotation = Random.new():NextNumber(-3, 3)
			end
		end))
	end
}
setmetatable(VenomfangRod, module)
return VenomfangRod