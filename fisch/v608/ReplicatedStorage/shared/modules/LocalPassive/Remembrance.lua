local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("ContentProvider")
game:GetService("RunService")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require(ReplicatedStorage.shared.modules.library.rods)
require(ReplicatedStorage.shared.modules.fx)
require(ReplicatedStorage.shared.modules.library.fish)
require(ReplicatedStorage.client.legacyControllers.StatusEffectsController)
require(ReplicatedStorage.client.legacyControllers.CompanionController)
local module = require("./PassiveHandler")
ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing")
local Remembrance = {
	OnFishMove = function(self, p: number, p2: number)
		if self.config.DarkFishFollowBar then
			self.darkFishTarget = self.random:NextNumber(
				self.current.barPosition - self.current.barSize / 2,
				self.current.barPosition + self.current.barSize / 2
			)
		else
			local v = math.max(math.max(self.current.resilience, 20) / 100, 0.8) * 0.8
			local minFishPosition = math.max(self.current.minFishPosition, self.darkFishTarget - v / 2)
			local maxFishPosition = math.min(self.current.maxFishPosition, self.darkFishTarget + v / 2)
			local v2 = self.current.maxFishPosition - self.current.minBarPosition
			local v3 = self.current.minFishPosition + v2 / 2

			if maxFishPosition - minFishPosition < v and maxFishPosition - minFishPosition < v2 then
				if v2 <= v then
					minFishPosition = self.current.minFishPosition
					maxFishPosition = self.current.maxFishPosition
				else
					local v4 = v - (maxFishPosition - minFishPosition)

					if v3 < self.darkFishTarget then
						maxFishPosition = math.min(self.current.maxFishPosition, maxFishPosition + v4)
					else
						minFishPosition = math.max(self.current.minFishPosition, minFishPosition - v4)
					end
				end
			end

			self.darkFishTarget = self.random:NextNumber(minFishPosition, maxFishPosition)
		end

		if math.abs(self.darkFishTarget - p) < self.config.DarkFishMinDistance then
			self.darkFishTarget = p + math.sign(0.5 - p) * self.config.DarkFishMinDistance
		end

		self.darkFishMoveTime = p2 / self.config.DarkFishSpeedMultiplier
	end,
	TickMove = function(self, p: number)
		if self.config.RespectFreeze and (self.current.core.fish.MovementPaused or self.current.frozenUntil > tick()) then
			return
		end

		local v = p / self.current.movementfactor
		local smoothDamp, darkFishVelocity = TweenService:SmoothDamp(
			self.darkFishPosition,
			self.darkFishTarget,
			self.darkFishVelocity,
			self.darkFishMoveTime,
			self.config.DarkFishMaxSpeed,
			v
		)
		self.darkFishPosition = smoothDamp
		self.darkFishVelocity = darkFishVelocity

		if self.darkFishPosition >= 1 then
			self.darkFishPosition = 1

			if self.darkFishVelocity > 0 then
				self.darkFishVelocity = 0
			end
		elseif self.darkFishPosition <= 0 then
			self.darkFishPosition = 0

			if self.darkFishVelocity < 0 then
				self.darkFishVelocity = 0
			end
		end

		self.darkFish.Position = UDim2.fromScale(self.darkFishPosition, 0.459)
	end,
	Tick = function(self, p: number)
		if not (self.current and self.current.active) then
			return
		end

		self:TickMove(p)
		local v = 0
		local isInBar = self.current:IsInBar(self.darkFishPosition, 0.01)

		if isInBar then
			v += math.lerp(1, self.current.progressefficiency, self.config.RespectProgressSpeedRatio) * 0.2 * (p * 60)
		elseif self.current.onbar then
			v -= math.lerp(1, self.current.progressefficiency, self.config.RespectProgressSpeedRatio) * 0.2 * (p * 60)
		end

		if self.current.onbar and not isInBar then
			self._progressSpeedModifier.Value += self.config.PerfectionProgressSpeedBoost * p
			self._forcedProgressSpeedModifier.Value += self.config.PerfectionForcedProgressSpeedBoost * p
		else
			self._progressSpeedModifier.Value = math.max(
				self._progressSpeedModifier.Value - self.config.PerfectionProgressSpeedBoost * p,
				0
			)
			self._forcedProgressSpeedModifier.Value = math.max(
				self._forcedProgressSpeedModifier.Value - self.config.PerfectionForcedProgressSpeedBoost * p,
				0
			)
		end

		if not self.current.progressLocked then
			self._progressModifier.Value += v * self.config.DarkFishProgressRatio
		end
	end,
	Morph = function(self, parent, object2)
		self.random = object2:GetRandom(61)
		self._progressModifier = object2:CreateModifier("progress", "add")
		self._progressSpeedModifier = object2:CreateModifier("progressefficiency", "add")
		self._forcedProgressSpeedModifier = object2:CreateModifier("progressefficiency", "force_add")
		self.darkFishPosition = 0.3
		self.darkFishVelocity = 0
		self.darkFishTarget = 0.4
		self.darkFishMoveTime = 1
		local darkFish

		if parent:FindFirstChild("darkfish") then
			darkFish = parent.darkfish:Clone()
		else
			darkFish = script.darkfish:Clone()
		end

		self.darkFish = darkFish
		self.darkFish.Visible = true
		self.darkFish.Position = UDim2.fromScale(self.darkFishPosition, 0.459)
		self.darkFish.Parent = parent
		self.reelTrove:Add(function()
			self.darkFish = nil
		end)
		self.reelTrove:Add(object2.OnLogicStep:Connect(function(p: number)
			self:Tick(p)
		end))
		object2.OnFishMove:Connect(function(p, p2)
			if p2 == 0 then
				return
			end

			self:OnFishMove(p, p2)
		end)
	end
}
setmetatable(Remembrance, module)
return Remembrance