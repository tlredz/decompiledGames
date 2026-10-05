local VerdantOath = {}
local TweenService = game:GetService("TweenService")
game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local module = require("./PassiveHandler")
require(ReplicatedStorage.shared.modules.fx)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
ReplicatedStorage:WaitForChild("world")

function VerdantOath:IsOnSplitBar()
	if self.current.onbar then
		return false
	end

	return math.abs(self.current.fishPosition - self.current.barPosition) <= self.splitBarSize + self.current.barSize
end

local function flashRed(colors)
	local v = colors:IsA("UIStroke") and "Color" or colors:IsA("ImageLabel") and "ImageColor3" or colors:IsA("Frame") and "BackgroundColor3" or nil

	if not v then
		return
	end

	if not colors:GetAttribute("OriginalColor") then
		colors:SetAttribute("OriginalColor", colors[v])
	end

	colors[v] = Color3.fromRGB(255, 69, 52)
	TweenService:Create(colors, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		[v] = colors:GetAttribute("OriginalColor")
	}):Play()
end

function VerdantOath:ExitedFx()
	if self.playingExited then
		return
	end

	self.playingExited = true
	self.current.core.fish.Disabled = true
	self.current.core.rod.Paused = true
	self.current.core.minigame.Disabled = true
	self.current.fx:SpawnShake(self.reel, 0.15, 0.25, 0.01, false)
	script.ExitGreenZone:Play()

	if not SettingsController:GetSettingValue("photosensitiveMode") then
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Brightness = 0.5
		colorCorrectionEffect.Parent = Lighting
		TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			Brightness = 0
		}):Play()
		task.delay(0.25, colorCorrectionEffect.Destroy, colorCorrectionEffect)
	end

	self.reel.playerbar.greenZone.BackgroundTransparency = 1
	TweenService:Create(self.reel.playerbar.greenZone, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		BackgroundTransparency = 0
	}):Play()
	flashRed(self.reel.stroke)
	flashRed(self.reel.playerbar.stroke)
	flashRed(self.reel.playerbar.Shine)
	flashRed(self.reel.playerbar.leftSplit)
	flashRed(self.reel.playerbar.rightSplit)
	flashRed(self.reel.Shine)
	flashRed(self.reel.licon)
	flashRed(self.reel.ricon)
	flashRed(self.reel.progress.bar)
	flashRed(self.reel.progress.stroke)
	flashRed(self.reel.progress.Shine)
	task.wait(0.25)
	self.current.core.fish.Disabled = false
	self.current.core.rod.Paused = false
	self.current.core.minigame.Disabled = false
	self.playingExited = false
	self.current.core.fish:CancelMovement(true)
end

function VerdantOath:Morph(p, object2)
	object2:Preload(script:GetChildren())
	object2.core.ui.ColorShift_Enabled = false
	self.splitBarSize = math.max(object2.barSize, self.config.MinSplitBarSize)
	local playerbar = p.playerbar
	local leftSplit = playerbar.leftSplit
	local rightSplit = playerbar.rightSplit
	local shine = playerbar.Shine
	self.current.core.fish.CurrentMaxSpeed = self.config.MaxFishSpeed
	local modifier = object2:CreateModifier("barSize", "force")
	modifier.Value = self.config.InitialSize
	local modifier2 = object2:CreateModifier("progress", "add")
	local modifier3 = object2:CreateModifier("resilience", "multiply")
	leftSplit.Position = UDim2.fromScale(0.5, 0)
	leftSplit.UIAspectRatioConstraint.AspectRatio = self.splitBarSize * 5
	rightSplit.Position = UDim2.fromScale(0.5, 0)
	rightSplit.UIAspectRatioConstraint.AspectRatio = self.splitBarSize * 5
	self.reelTrove:Add(object2.core.fish.OnMovementAttempted:BindAtPriority(100000, function(p2, p3, p4, p5)
		if object2.progress >= self.config.StopMovementAfter then
			return false, p3, p4, p5
		end

		return p2, p3, p4, p5
	end))
	task.spawn(function()
		script.PreBarBreak2:Play()
		task.wait(1)
		object2.fx:SpawnShake(p, 0.005, 0.2, 0.01, false, 1.2)
		script.PreBarBreak1:Play()
		task.wait(0.2)
		TweenService:Create(leftSplit, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
			Position = UDim2.fromScale(0, 0)
		}):Play()
		TweenService:Create(rightSplit, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
			Position = UDim2.fromScale(1, 0)
		}):Play()
		script.BarBreak1:Play()
		script.BarBreak2:Play()
		shine.ImageTransparency = 0.25
		TweenService:Create(shine, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			ImageTransparency = 0.64
		}):Play()
		object2:WaitUntilReady()

		if object2:GetRandom(5):NextInteger(1, 100) <= 20 then
			object2:TweenModifier("progress", "add", 0, 60, TweenInfo.new(0.5))
			local backgroundColor3 = p.progress.bar.BackgroundColor3
			local tween = TweenService:Create(p.progress.bar, TweenInfo.new(0.25), {
				BackgroundColor3 = Color3.fromRGB(68, 255, 0)
			})
			tween:Play()
			tween.Completed:Once(function()
				tween:Destroy()
				local tween2 = TweenService:Create(p.progress.bar, TweenInfo.new(0.25), {
					BackgroundColor3 = backgroundColor3
				})
				tween2:Play()
				tween2.Completed:Once(function()
					tween2:Destroy()
				end)
			end)
		end

		self.reelTrove:Add(object2.OnLogicStep:Connect(function(p2)
			if object2.isPaused or not object2.active or self.playingExited or object2.progressLocked then
				return
			end

			if object2.onbar then
				modifier.Value = math.min(modifier.Value + self.config.ZoneGrowRate * p2, self.config.MaxGreenZoneSize)
				modifier3.Value = math.map(
					modifier.Value,
					self.config.InitialSize,
					self.config.MaxGreenZoneSize,
					1,
					self.config.MaxResilienceLoss
				)
				self.onSplitBar = false
			elseif self:IsOnSplitBar() then
				if not self.onSplitBar then
					local v = math.clamp(math.abs(self.current.core.fish.CurrentVelocity) * 25, 1, 25)
					object2:AddProgress(-self.config.ExitZonePenalty / v)
					self.onSplitBar = true
					self:ExitedFx()
				end

				modifier.Value -= self.config.ZoneShrinkRate * p2
				modifier2.Value -= self.config.BrokenBarLossRate * p2
			end
		end))
	end)
end

setmetatable(VerdantOath, module)
return VerdantOath