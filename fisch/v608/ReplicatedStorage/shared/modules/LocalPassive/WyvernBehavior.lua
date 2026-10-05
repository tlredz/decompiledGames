local WyvernBehavior = {}
game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local fx = require(ReplicatedStorage.shared.modules.fx)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local module = require("./PassiveHandler")
require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules"):WaitForChild("library"):WaitForChild("rods"))

function WyvernBehavior:Morph(parent, object2)
	object2:Preload({ script })
	self.random = object2:GetRandom(6)
	self.lastAttack = 0
	self.container = script.wyvernContainer:Clone()
	self.container.Parent = parent
	object2.OnFishMove:Connect(function()
		self:OnFishMove()
	end)
	self.current.OnReady:Once(function()
		while object2:WaitLogic(self.config.FollowTriggerInterval) and self.current and self.current.active and not self.current.isPaused do
			if self.current.core.fish.MovementBehavior.Name == "Follow" or self.config.ForcedTriggerInterval then
				task.spawn(self.OnFishMove, self)
			end
		end
	end)
end

function WyvernBehavior:OnFishMove()
	if tick() - self.lastAttack < self.config.Cooldown then
		return
	end

	if self.random:NextNumber(0, 100) < self.config.TriggerChance then
		self:Attack()
	end
end

function WyvernBehavior:Attack()
	self.lastAttack = tick()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fadeOut(p, p2: number)
		self.current.logicTweens:CreateAndPlay(p, TweenInfo.new(p2 * 0.9, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 1
		})
	end

	local v

	if self.current.barSize >= 0.5 - self.config.AttackWidth / 2 and self.current.barSize < 1 - self.config.AttackWidth then
		local v2 = self.config.AttackWidth + self.current.barSize / 2
		v = self.random:NextNumber(v2, 0.5 - v2)

		if self.random:NextInteger(1, 2) == 2 then
			v = 0.5 - v
		end
	else
		v = self.random:NextNumber(self.config.AttackWidth, 1 - self.config.AttackWidth)
	end

	local noteContainer = self.reel:FindFirstChild("noteContainer")

	if noteContainer and self.current.core.fish.MovementBehavior.Name ~= "Follow" then
		for _, image in noteContainer:GetChildren() do
			if not (image:IsA("ImageLabel") and math.abs(image.Position.X.Scale - v) < 0.3) then
				continue
			end

			if v > 0.5 then
				v -= 0.3
			else
				v += 0.3
			end
		end
	end

	local clone = script.warning:Clone()
	local absoluteSize = self.reel.Parent.AbsoluteSize
	local absolutePosition = self.reel.Parent.AbsolutePosition
	local absolutePosition2 = self.reel.AbsolutePosition
	local v2 = absoluteSize.Y - absolutePosition.Y - absolutePosition2.Y
	clone.Size = UDim2.new(self.config.AttackWidth, 0, 0, absoluteSize.Y + GuiService:GetGuiInset().Y)
	clone.Position = UDim2.new(v, 0, 0, v2)
	clone.wyvern.Visible = false
	clone.Parent = self.container

	for _ = 1, 4 do
		clone.BackgroundTransparency = 0.5
		clone.borderLeft.BackgroundTransparency = 0
		clone.borderRight.BackgroundTransparency = 0
		fadeOut(clone, self.config.WarningTime / 4) -- equivalent call inferred; original call site unknown
		fadeOut(clone.borderLeft, self.config.WarningTime / 4) -- equivalent call inferred; original call site unknown
		fadeOut(clone.borderRight, self.config.WarningTime / 4) -- equivalent call inferred; original call site unknown
		fx:PlaySound(script.WarningSound, self.reel, false)
		self.current:WaitLogic(self.config.WarningTime / 4)
	end

	self.current.logicTweens:CreateAndPlay(clone.exclamation, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		TextTransparency = 1
	})
	clone.wyvern.Position = UDim2.fromScale(0, 0)
	clone.wyvern.AnchorPoint = Vector2.new(0, 1)
	clone.wyvern.Visible = true
	script.Woosh:Play()
	self.current.logicTweens:CreateAndPlay(clone.wyvern, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		Position = UDim2.fromScale(0, 1),
		AnchorPoint = Vector2.new(0, 0),
		Visible = false
	})
	self.current:WaitLogic(0.3)

	if self.current:IsInBar(v, self.config.AttackWidth * 0.65) then
		self:OnHit(v)
	end

	self.current:WaitLogic(0.7)
	clone:Destroy()
end

function WyvernBehavior:OnHit(p: number)
	local barSize = self.current.barSize
	self.current:AddProgress(-self.current.progress * self.config.ProgressReduce)
	local flag = false

	if self.current.barSize < 0.9 then
		if self.current.barPosition - self.current.barSize / 2 < 0.05 then
			self.current.barPosition = self.current.barSize / 2 * self.config.ControlReduce
			flag = true
		elseif self.current.barPosition + self.current.barSize / 2 > 0.95 then
			self.current.barPosition = 1 - self.current.barSize / 2 * self.config.ControlReduce
			flag = true
		end
	end

	local modifier = self.current:CreateModifier("barSize", "multiply")
	modifier.Value = self.config.ControlReduce
	self.current.fx:SpawnShake(self.reel, 0.15, 0.25, 0.01, false)
	script.Impact:Play()

	if not SettingsController:GetSettingValue("photosensitiveMode") then
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Brightness = 0.5
		colorCorrectionEffect.Parent = Lighting
		TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
			Brightness = 0
		}):Play()
		task.delay(0.25, colorCorrectionEffect.Destroy, colorCorrectionEffect)
	end

	local backgroundColor3 = self.current.reel_progress.bar.BackgroundColor3
	self.current.reel_progress.bar.BackgroundColor3 = Color3.fromRGB(255, 16, 60)
	TweenService:Create(self.current.reel_progress.bar, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
		BackgroundColor3 = backgroundColor3
	}):Play()

	if barSize < 1 - self.config.AttackWidth then
		self.current.logicTweens:CreateAndPlay(
			modifier,
			TweenInfo.new(self.config.Duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
			{
				Value = 1
			}
		)
	end

	if flag then
		self.current.core.rod.CurrentVelocity = 0
		self.current.core.rod.CurrentAcceleration = 0
	elseif self.config.ImpulseStrength and self.config.ImpulseStrength > 0 then
		local v = math.sign(self.current.barPosition - p)
		self.current.core.rod:ApplyImpulse(v * self.config.ImpulseStrength)
	end
end

setmetatable(WyvernBehavior, module)
return WyvernBehavior