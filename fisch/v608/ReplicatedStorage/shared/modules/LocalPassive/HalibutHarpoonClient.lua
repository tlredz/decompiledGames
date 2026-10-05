local createVector = vector.create
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContextActionService")
game:GetService("UserInputService")
game:GetService("SoundService")
game:GetService("GuiService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
game:GetService("LogService")
require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.packages.Net)
local SaneDebris = require(ReplicatedStorage.shared.modules.SaneDebris)
local rarities = require(ReplicatedStorage.shared.modules.library.rarities)
local evalColorSequence = require(ReplicatedStorage.shared.utils.evalColorSequence)
local fx = require(ReplicatedStorage.shared.modules.fx)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local module = require("./PassiveHandler")
require("@self/Types")
local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function getPlayerPos()
	local character = localPlayer.Character

	if not character then
		return createVector(0, 0, 0)
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart.Position
	end

	return createVector(0, 0, 0)
end

local HalibutHarpoonClient = {
	MorphHarpoon = true,
	Morph = function(self, _, object)
		local halibutHarpoon_RemoteConfig = object.data.HalibutHarpoon_RemoteConfig
		self.currentConfig = halibutHarpoon_RemoteConfig

		if not halibutHarpoon_RemoteConfig then
			return
		end

		self.currentConfig = halibutHarpoon_RemoteConfig
		self.random = object:GetRandom(12)
		self.random_crit = object:GetRandom(-12)
		self.hitCount = 0
		self.moveFactor = object:CreateModifier("movementfactor", "multiply")
		self.moveFactor.Value = 1

		if fish[object.fish.Name] and fish[object.fish.Name].ForcedProgressEfficiency and fish[object.fish.Name].ForcedProgressEfficiency < 0.5 then
			self.nextWave = math.min(
				halibutHarpoon_RemoteConfig.HarpoonInterval,
				self.config.MaximumDelayOnTheFirstWaveOfHarpoonsAgainstAForcedProgressSpeedFish
			)
		else
			self.nextWave = 0
		end

		object.BuildEndingData:Bind(function(p)
			p.HalibutHarpoon_HitCount = self.hitCount
			return p
		end)

		if halibutHarpoon_RemoteConfig.ExtraAbilities.PullFish then
			self.nextPull = halibutHarpoon_RemoteConfig.ExtraAbilities.PullFish.PullCooldown
		else
			self.nextPull = nil
		end
	end,
	SpawnHarpoon = function(self, object, p: number)
		local config = self.config
		local fishPos = object.fishPos

		if not fishPos then
			local character = localPlayer.Character

			if character then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				fishPos = not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) and createVector(0, 0, 0) or humanoidRootPart.Position
			else
				fishPos = createVector(0, 0, 0)
			end
		end

		local clone = script.Harpoon:Clone()
		local unitVector = random:NextUnitVector()

		if object.type == "reel" then
			local Y = fishPos.Y
			local playerPos = getPlayerPos() -- equivalent call inferred; original call site unknown

			if Y < playerPos.Y then
				if unitVector.Y < 0 then
					unitVector *= createVector(1, -1, 1)
				end

				unitVector += createVector(0, 0.25, 0)
			end
		end

		local v = self.currentConfig.BaitRarity and rarities.Rarities[self.currentConfig.BaitRarity]

		if v then
			local color = v.Color

			if v.ColorGradient then
				color = evalColorSequence(v.ColorGradient, random:NextNumber())
			end

			clone.Material = Enum.Material.Neon
			clone.Color = color
			clone.Trail.Color = ColorSequence.new(color)
			clone.Trail.Brightness = 5
		else
			clone.Material = Enum.Material.Metal
			clone.Color = Color3.fromRGB(90, 90, 90)
			clone.Trail.Color = ColorSequence.new(Color3.fromRGB(90, 90, 90))
			clone.Trail.Brightness = 1
		end

		local cFrame = CFrame.lookAt(fishPos + unitVector * config.HarpoonDistance * 1.5, fishPos) * clone.PivotOffset:Inverse()
		local cFrame2 = CFrame.lookAt(fishPos + unitVector * config.HarpoonDistance, fishPos) * clone.PivotOffset:Inverse()
		local cFrame3 = CFrame.lookAlong(fishPos, -unitVector) * clone.PivotOffset:Inverse()
		clone.CFrame = cFrame
		clone.LocalTransparencyModifier = 1
		clone.Trail.LocalTransparencyModifier = 1
		clone.Parent = workspace.active.debrisfx
		object.logicTweens:CreateAndPlay(
			clone,
			TweenInfo.new(config.WarningTime * 0.75, Enum.EasingStyle.Exponential),
			{
				CFrame = cFrame2,
				LocalTransparencyModifier = 0
			}
		)
		object.logicTweens:CreateAndPlay(clone.Trail, TweenInfo.new(config.WarningTime / 2, Enum.EasingStyle.Quint), {
			LocalTransparencyModifier = 0
		})
		fx:PlaySound(script.Shoot, object.reel, true)
		object:WaitLogic(config.WarningTime)

		if not (object.active and self.currentConfig) then
			clone:Destroy()
			return
		end

		object.logicTweens:CreateAndPlay(clone, TweenInfo.new(config.FlightTime, Enum.EasingStyle.Linear), {
			CFrame = cFrame3
		})
		local clone2 = script.harpoonContainer:Clone()
		clone2.Rotation = random:NextNumber(-25, 25)
		clone2.harpoon.Position = UDim2.fromScale(0, -10)
		clone2.Position = UDim2.fromScale(p, 0.5)
		local parent

		if object.type == "reel" then
			parent = object.reel_bar
		else
			parent = object.reel_progress
		end

		clone2.Parent = parent
		object.logicTweens:Create(clone2.harpoon, TweenInfo.new(config.FlightTime, Enum.EasingStyle.Linear), {
			Position = UDim2.fromScale(0, 0)
		}):Play()
		object:WaitLogic(config.FlightTime)
		clone2:Destroy()

		if not (object.active and self.currentConfig) then
			clone:Destroy()
			return
		end

		clone.Transparency = 1
		SaneDebris:AddItem(clone, 1)
		local v6 = not (self.random_crit:NextNumber(0, 100) < self.currentConfig.HarpoonCritChance) and 0 or self.currentConfig.HarpoonCritDamageBonus
		local v7 = self.currentConfig.HarpoonDamage + v6

		if object.type == "reel" and not (object.onbar and object:IsInBar(p)) then
			fx:PlaySound(script.HarpoonMiss, object.reel, true)
		else
			object:AddProgress(v7)
			self.hitCount += 1
			fx:PlaySound(script.HarpoonImpact2, object.reel, true)

			if v6 > 0 then
				fx:PlaySound(script.CritSound, object.reel, true)
				local clone3 = script.critContainer:Clone()
				clone3.Position = UDim2.fromScale(p, -0.1)
				clone3.critText.TextColor3 = Color3.fromRGB(255, 255, 255)
				clone3.critText.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
				local parent2

				if object.type == "reel" then
					parent2 = object.reel_bar
				else
					parent2 = object.reel_progress
				end

				clone3.Parent = parent2
				TweenService:Create(clone3.critText, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
					TextColor3 = Color3.fromRGB(255, 155, 32),
					TextStrokeColor3 = Color3.fromRGB(74, 58, 30)
				}):Play()
				TweenService:Create(clone3.critText, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
					Position = UDim2.fromScale(0, -3)
				}):Play()
				task.delay(0.5, function()
					if not object.active then
						clone3:Destroy()
						return
					end

					TweenService:Create(clone3.critText, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
						TextTransparency = 1,
						TextStrokeTransparency = 1
					}):Play()
					task.wait(0.5)
					clone3:Destroy()
				end)
			end
		end
	end,
	StartWave = function(self, object2)
		self.moveFactor.Value = self.config.WarningMovementFactor
		local v

		if object2.type == "reel" then
			local v2 = math.max(object2.fishPosition - object2.barSize * self.config.MaxSpawnDistanceRatio, 0.1)
			local v3 = math.min(object2.fishPosition + object2.barSize * self.config.MaxSpawnDistanceRatio, 0.9)
			local number = self.random:NextNumber(v2, v3)

			if object2.fishPosition < number then
				v2 = v3
			end

			v = math.lerp(number, v2, self.config.DistanceSkewRatio)
		else
			v = 0.5
		end

		local integer = self.random:NextInteger(self.currentConfig.HarpoonCountMin, self.currentConfig.HarpoonCountMax)

		for i = 1, self.random:NextNumber(0, 100) < self.config.SucksNowChance and 1 or integer do
			object2:DelayLogic(
				(i - 1) * (self.config.WarningTime * 0.5 / self.currentConfig.HarpoonCountMax),
				function()
					if not object2.active then
						return
					end

					self:SpawnHarpoon(
						object2,
						v + self.random:NextNumber(
							-self.config.HarpoonHitboxSize / 2,
							self.config.HarpoonHitboxSize / 2
						)
					)
				end
			)
		end

		if object2.type == "reel" then
			local clone = script.warningContainer:Clone()
			clone.warning.UIScale.Scale = 0
			clone.Position = UDim2.fromScale(v, -0.5)
			clone.Parent = object2.reel_bar
			object2.logicTweens:Create(clone.warning.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
				Scale = 1
			}):Play()

			if self.current.rodSkin == "Pufferfish Harpoon" then
				clone.warning.ImageColor3 = Color3.fromRGB(160, 160, 160)
				object2.logicTweens:Create(
					clone.warning,
					TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{
						ImageColor3 = Color3.fromRGB(91, 91, 91)
					}
				):Play()
			else
				object2.logicTweens:Create(
					clone.warning,
					TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{
						ImageColor3 = Color3.fromRGB(45, 48, 136)
					}
				):Play()
			end

			if self.nextPull and self.nextPull <= 0 and self.currentConfig.ExtraAbilities.PullFish then
				self.nextPull += self.currentConfig.ExtraAbilities.PullFish.PullCooldown
				local v2 = 1 / self.currentConfig.ExtraAbilities.PullFish.PullStrength
				object2.core.fish:ForceMoveTo(v, v2)
				object2.core.fish:DelayNextMovement(v2 + 1)
			end

			object2:DelayLogic(self.config.WarningTime, function()
				if not object2.active then
					clone:Destroy()
					return
				end

				object2.logicTweens:Create(clone.warning.UIScale, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
					Scale = 0
				}):Play()
				object2:WaitLogic(0.25)
				clone:Destroy()

				if object2.active then
					self.moveFactor.Value = 1
				end
			end)
		end
	end,
	TickLogic = function(self, p, p2: number)
		if p.type == "stab" or not (p.active and self.currentConfig) then
			return
		end

		self.nextWave -= p2

		if self.nextPull then
			self.nextPull -= p2
		end

		if self.nextWave < 0 then
			self.nextWave += self.currentConfig.HarpoonInterval + self.config.WarningTime
			self:StartWave(p)
		end
	end
}
setmetatable(HalibutHarpoonClient, module)
return HalibutHarpoonClient