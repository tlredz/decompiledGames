game:GetService("RunService")
game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local RadiantCrystalBehavior = {}
RadiantCrystalBehavior.__index = RadiantCrystalBehavior

function RadiantCrystalBehavior:Morph(_, object2)
	self.sizeReducer = object2:CreateModifier("barSize", "add")
	self.heartbeat = nil
	object2.OnFishMove:Connect(function()
		self:Update()
	end)
end

function RadiantCrystalBehavior:Update()
	local current = self.current
	local config = self.config

	if not current.active then
		return
	end

	if not self.heartbeat then
		self.heartbeat = self.reelTrove:Add(current.OnLogicStep:Connect(function(p)
			if not current.active then
				return
			end

			local v = config.BaseShrinkSpeed * p

			if not current.onbar then
				v *= config.OffBarMultiplier
			end

			self.sizeReducer.Value -= v
		end))
	end
end

setmetatable(RadiantCrystalBehavior, module)
return RadiantCrystalBehavior