local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local LeviathanBehavior = {}
LeviathanBehavior.__index = LeviathanBehavior
LeviathanBehavior.MorphSpear = true
LeviathanBehavior.MorphHarpoon = true

function LeviathanBehavior:Morph(_, object2)
	self.whipCount = 0
	self.lastLeviathanWhip = 0
	self.accelMultiply = object2:CreateModifier("accel", "multiply")
	local barResizer

	if object2.type ~= "harpoon" then
		barResizer = object2:CreateModifier("barSize", "multiply")
	end

	self.barResizer = barResizer
	self.random = object2:GetRandom(5)
	object2.OnFishMove:Connect(function()
		self:Update(object2)
	end)
end

function LeviathanBehavior:Update(object)
	local config = self.config

	if not object.active then
		return
	end

	local cooldown = config.Cooldown

	if object.type == "stab" then
		cooldown /= 4
	end

	local serverTimeNow = Workspace:GetServerTimeNow()

	if not (serverTimeNow < self.lastLeviathanWhip + cooldown / 2) then
		self.lastLeviathanWhip = serverTimeNow + cooldown / 2

		if math.max(config.BaseChance * (1 - self.whipCount * 0.1), config.BaseChance * 0.5) > self.random:NextNumber(
			0,
			100
		) and object.progress >= config.MinimumProgress then
			self.whipCount += 1
			object:AddProgress(object.progress * -config.ProgressLossRatio)
			object.logicTweens:Create(
				object.reel_progress.bar,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
				{
					BackgroundColor3 = config.Color
				}
			):Play()
			fx:ShakeScreen(Players.LocalPlayer, 2.5, config.SizeReduceDuration)
			fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.growl, object.reel, true)

			if object.type == "harpoon" then
				object:TweenModifier(
					"movementfactor",
					"multiply",
					config.AccelMultiply,
					1,
					TweenInfo.new(config.AccelMultiplyDuration)
				)
				local v = math.max(self.config.BarSizeReduction // 0.1, 1)

				for _ = 1, v do
					local button = object.core.pullButtons:SpawnButton()
					button.progressMultiplier /= v
					button:ModifyDespawnTime("add", 3)
					object:WaitLogic(1 / v)
				end
			else
				self.barResizer.Value = 1 - config.BarSizeReduction
				task.spawn(function()
					local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

					for _ = 1, 25 do
						local rotation = math.random(-3, 3)
						local tween = TweenService:Create(object.reel_playerbar, tweenInfo, {
							Rotation = rotation
						})
						tween:Play()
						tween.Completed:Wait()
					end

					TweenService:Create(object.reel_playerbar, TweenInfo.new(0.2), {
						Rotation = 0
					}):Play()
				end)
				object:DelayLogic(config.SizeReduceDuration, function()
					self.barResizer.Value = 1
				end)
				self.accelMultiply.Value = config.AccelMultiply
				object:DelayLogic(config.AccelMultiplyDuration, function()
					self.accelMultiply.Value = 1
				end)
			end
		end
	end
end

setmetatable(LeviathanBehavior, module)
return LeviathanBehavior