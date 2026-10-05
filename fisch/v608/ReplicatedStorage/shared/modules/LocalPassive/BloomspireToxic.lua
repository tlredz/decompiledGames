local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
local module = require("./PassiveHandler")
ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing"):WaitForChild("slashes")
ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing")
ReplicatedStorage:WaitForChild("world")
local BloomspireToxic = {
	OnSlash = function(self, p: string, _: string, p2: number)
		if self.config.AllowedSources and not table.find(self.config.AllowedSources, p) then
			return
		end

		local v = self.config.DamageRelative and p2 or 1

		if self.config.ProgressSpeed then
			self.psModify.Value += self.config.ProgressSpeed / 100 * v
		end

		if self.config.ForcedProgressSpeed then
			self.psModifyForced.Value += self.config.ForcedProgressSpeed / 100 * v
		end
	end,
	Morph = function(self, _, object2)
		self.psModify = object2:CreateModifier("progressefficiency", "add")
		self.psModifyForced = object2:CreateModifier("progressefficiency", "force_add")
		self.reelTrove:Connect(self.current.OnSlash, function(p: string, p2: string, p3: number)
			self:OnSlash(p, p2, p3)
		end)
		self.reelTrove:Connect(object2.OnLogicStep, function(p: number)
			if not object2.isPaused and object2.active and not object2.onbar then
				if self.config.ProgressSpeedDecay then
					self.psModify.Value = math.max(self.psModify.Value - self.config.ProgressSpeedDecay / 100 * p, 0)
				end

				if self.config.ForcedProgressSpeedDecay then
					self.psModifyForced.Value = math.max(
						self.psModifyForced.Value - self.config.ForcedProgressSpeedDecay / 100 * p,
						0
					)
				end
			end
		end)
	end
}
setmetatable(BloomspireToxic, module)
return BloomspireToxic