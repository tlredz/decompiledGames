local TweenService = game:GetService("TweenService")
game:GetService("RunService")
game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local StatusEffectsController = require(ReplicatedStorage.client.legacyControllers.StatusEffectsController)
local PoisonousFungus = {}
PoisonousFungus.__index = PoisonousFungus

function PoisonousFungus:Morph(_, object2)
	self.random = object2:GetRandom(7)
	local v = StatusEffectsController:GetStatusesOfType(self.config.BuffId)[1]
	local v2 = not v and 0 or v.Data.Stack * self.config.RateIncreasePerStack
	self.nextSpawn = self.random:NextNumber(self.config.SpawnIntervalMin, self.config.SpawnIntervalMax) / (v2 + 1)
	self.flashTween = nil
	self.reelTrove:Add(object2.OnLogicStep:Connect(function(p)
		if not object2.active then
			return
		end

		self.nextSpawn -= p

		if self.nextSpawn > 0 then
			return
		end

		self.nextSpawn += self.random:NextNumber(self.config.SpawnIntervalMin, self.config.SpawnIntervalMax) / (v2 + 1)
		self:Trigger(object2)
	end))
end

function PoisonousFungus:SpawnFlipbook(parent)
	local v = parent.AbsoluteSize.X / math.max(parent.AbsoluteSize.Y, 1)
	local number = self.random:NextNumber(0.05, 0.95)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "FungusGlow"
	imageLabel.Image = "rbxassetid://1075864321"
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Size = UDim2.fromScale(8 / v, 8)
	imageLabel.Position = UDim2.fromScale(number, 0.5)
	imageLabel.ZIndex = parent.ZIndex - 1
	imageLabel.ImageColor3 = Color3.fromRGB(153, 0, 255)
	imageLabel.Parent = parent
	self.current.logicTweens:Create(
		imageLabel,
		TweenInfo.new(0.3333333333333333, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Size = UDim2.fromScale(20 / v, 20),
			ImageTransparency = 1
		}
	):Play()
	self.current:DelayLogic(0.3333333333333333, function()
		imageLabel:Destroy()
	end)
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "FungusFlipbook"
	imageLabel2.Image = "rbxassetid://15855917528"
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.ImageRectSize = Vector2.new(256, 256)
	imageLabel2.ImageRectOffset = Vector2.zero
	imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel2.Size = UDim2.fromScale(15 / v, 15)
	imageLabel2.Position = UDim2.fromScale(number, 0.5)
	imageLabel2.ZIndex = parent.ZIndex
	imageLabel2.ImageColor3 = Color3.fromRGB(153, 0, 255)
	imageLabel2.Parent = parent
	self.current.logicTweens:Create(
		imageLabel2,
		TweenInfo.new(0.3333333333333333, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Size = UDim2.fromScale(18 / v, 18)
		}
	):Play()
	task.spawn(function()
		for i = 0, 15 do
			local v3 = math.floor(i / 4)
			imageLabel2.ImageRectOffset = Vector2.new(i % 4 * 256, v3 * 256)
			task.wait(0.020833333333333332)
		end

		imageLabel2:Destroy()
	end)
	return imageLabel2
end

function PoisonousFungus:Trigger(object2)
	local config = self.config
	object2:AddProgress(config.ProgressPerExplosion)
	self:SpawnFlipbook(object2.reel_progress)

	if not self._originalBarColor then
		self._originalBarColor = object2.reel_playerbar.BackgroundColor3
	end

	if not self._originalProgressColor then
		self._originalProgressColor = object2.reel_progress.bar.BackgroundColor3
	end

	if self._barFlashTween then
		self._barFlashTween:Cancel()
	end

	object2.reel_playerbar.BackgroundColor3 = self._originalBarColor
	self._barFlashTween = TweenService:Create(
		object2.reel_playerbar,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
		{
			BackgroundColor3 = config.Color
		}
	)
	self._barFlashTween.Completed:Once(function()
		object2.reel_playerbar.BackgroundColor3 = self._originalBarColor
	end)
	self._barFlashTween:Play()

	if self.flashTween then
		self.flashTween:Cancel()
	end

	object2.reel_progress.bar.BackgroundColor3 = self._originalProgressColor
	self.flashTween = TweenService:Create(
		object2.reel_progress.bar,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
		{
			BackgroundColor3 = config.Color
		}
	)
	self.flashTween.Completed:Once(function()
		object2.reel_progress.bar.BackgroundColor3 = self._originalProgressColor
	end)
	self.flashTween:Play()
end

setmetatable(PoisonousFungus, module)
return PoisonousFungus