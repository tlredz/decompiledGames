local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
game:GetService("RunService")
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require(ReplicatedStorage.shared.modules.library.rods)
local fx = require(ReplicatedStorage.shared.modules.fx)
local module = require("./PassiveHandler")
local slashes = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing"):WaitForChild("slashes")
ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing")
ReplicatedStorage:WaitForChild("world")
local Impaling = {
	Stab = function(self, _: number?)
		local v = self.config.StabDamage * (self.current.data.SlashDamageReduction or 1)
		self.current:AddProgress(v)

		if self.config.StunTime and not self.current.data.SlashDisableStun then
			self.current:FreezeFish(self.config.StunTime)
			self.current.core.fish:DelayNextMovement(0)
		end

		self.current.OnSlash:Fire(self.config.SourceType, self.config.SourceName, v)
		local clone = script.impaleFx:Clone()
		clone.ImageColor3 = self.config.VfxColor
		clone.Parent = self.current.reel_bar.fish
		task.spawn(function()
			for i = 0, 128, 128 do
				for i2 = 0, 896, 128 do
					if i2 == 256 and i == 0 then
						self.current.fx:SpawnShake(self.reel, 0.1, 0.5, 0.02, false)
					end

					clone.ImageRectOffset = Vector2.new(i2, i)
					task.wait(0.025)
				end
			end

			clone:Destroy()
		end)
		fx:PlaySound(slashes:FindFirstChild(self.config.SoundName), self.reel, true)
	end,
	IsInMiddle = function(self, p2: number)
		if not self.config.MiddleThreshold then
			return true
		end

		if self.current.barSize <= 0 then
			return false
		end

		local v = self.current.barSize * self.config.MiddleThreshold
		return self.current.barPosition - v / 2 < p2 and p2 < self.current.barPosition + v / 2
	end,
	Morph = function(self, p, object2)
		object2:Preload(script:GetChildren())
		local clone = script.impaleZone:Clone()
		clone.Size = UDim2.fromScale(self.config.MiddleThreshold, 1)

		if self.config.MiddleThreshold then
			clone.Parent = p.playerbar
		end

		local random = object2:GetRandom(20 + self.config.StabChance)
		local v = 0
		self.reelTrove:Add(object2.OnLogicStep:Connect(function(p2)
			if not self.current or not self.current.active or self.current.isPaused then
				return
			end

			clone.BackgroundTransparency = self:IsInMiddle(self.current.fishPosition) and 0 or 0.5
			v += p2

			if v >= self.config.RollInterval then
				v -= self.config.RollInterval

				if random:NextNumber(0, 100) < self.config.StabChance and self:IsInMiddle(self.current.fishPosition) then
					self:Stab()
				end
			end
		end))
	end
}
setmetatable(Impaling, module)
return Impaling