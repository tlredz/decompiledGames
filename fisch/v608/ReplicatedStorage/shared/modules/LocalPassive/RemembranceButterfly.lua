local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local v = { Vector2.new(0, 0), Vector2.new(256, 0), (Vector2.new(0, 256)) }
local RemembranceButterfly = {
	SpawnButterfly = function(self)
		local clone = script.butterfly:Clone()

		if self.config.FlipbookAsset then
			clone.Image = self.config.FlipbookAsset
		end

		clone.ImageTransparency = 1
		clone.Position = UDim2.new(0.5, -500, 0, -500)
		clone.Parent = self.reel.playerbar
		local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		self.current.logicTweens:Create(clone, tweenInfo, {
			Position = UDim2.fromScale(0.5, 0.5),
			ImageTransparency = 0
		}):Play()
		self.current.logicTweens:Create(self._resilienceModifier, tweenInfo, {
			Value = self.config.MovementFactor
		}):Play()
		self.current.logicTweens:Create(self._accelModifier, tweenInfo, {
			Value = self.config.AccelMultiply
		}):Play()
		task.spawn(function()
			local WAIT_INTERVAL = 0.05
			local lastTime = tick()

			repeat
				clone.ImageRectOffset = v[3]
				task.wait(WAIT_INTERVAL)
				clone.ImageRectOffset = v[2]
				task.wait(WAIT_INTERVAL)
				clone.ImageRectOffset = v[1]
				task.wait(WAIT_INTERVAL)
			until tick() - lastTime >= 2
		end)
		self.current:WaitLogic(2)
		clone.ImageRectOffset = v[1]
		self.current:WaitLogic(self.config.Duration)

		if not clone.Parent then
			return
		end

		self.current.logicTweens:Create(clone, tweenInfo, {
			Position = UDim2.new(0.5, 500, 0, -500),
			ImageTransparency = 1
		}):Play()
		self.current.logicTweens:Create(self._resilienceModifier, tweenInfo, {
			Value = 1
		}):Play()
		self.current.logicTweens:Create(self._accelModifier, tweenInfo, {
			Value = 1
		}):Play()
		task.spawn(function()
			local WAIT_INTERVAL = 0.05
			local lastTime = tick()

			repeat
				clone.ImageRectOffset = v[3]
				task.wait(WAIT_INTERVAL)
				clone.ImageRectOffset = v[2]
				task.wait(WAIT_INTERVAL)
				clone.ImageRectOffset = v[1]
				task.wait(WAIT_INTERVAL)
			until tick() - lastTime >= 2
		end)
		self.current:WaitLogic(2)
	end,
	Morph = function(self, _, object2)
		local random = object2:GetRandom(61)
		self._resilienceModifier = object2:CreateModifier("movementfactor", "multiply")
		self._accelModifier = object2:CreateModifier("accel", "multiply")
		self.reelTrove:Add(task.spawn(function()
			object2:WaitUntilReady()

			while object2.active do
				object2:WaitLogic(self.config.AttemptInterval)

				if not object2.active then
					break
				end

				if not (random:NextNumber(0, 100) < self.config.Chance) then
					continue
				end

				self:SpawnButterfly()
				object2:WaitLogic(self.config.Cooldown)
			end
		end))
	end
}
setmetatable(RemembranceButterfly, module)
return RemembranceButterfly