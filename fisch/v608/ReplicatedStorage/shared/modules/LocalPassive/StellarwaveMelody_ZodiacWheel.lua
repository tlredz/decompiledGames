game:GetService("ContentProvider")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.packages.Net)
require(ReplicatedStorage.shared.modules.fx)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local module = require("./PassiveHandler")
Random.new()
local StellarwaveMelodyZodiacWheel = {
	NoMock = true,
	HideWheel = function(self)
		if self.wheelHidden then
			return
		end

		self.wheelHidden = true

		if self.wheel then
			TweenService:Create(self.wheel, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Position = UDim2.fromScale(0.5, -0.6)
			}):Play()
		else
			for _, wheelSign in self.wheelSigns do
				local uIScale = wheelSign:FindFirstChildWhichIsA("UIScale")

				if uIScale then
					TweenService:Create(uIScale, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
						Scale = 0
					}):Play()
				end

				task.delay(1, wheelSign.Destroy, wheelSign)
			end
		end

		if self.signbar then
			TweenService:Create(self.signbar, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Position = UDim2.fromScale(0.5, 1.2)
			}):Play()
		end

		TweenService:Create(self.fade, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 1
		}):Play()
		self.current.logicTweens:Create(self.controlBoost, TweenInfo.new(1, Enum.EasingStyle.Quart), {
			Value = self.config.TemporaryControlBuff * (self.signClicks * self.config.BuffRetainAmountPerClick)
		}):Play()
	end,
	BuildWheelSigns = function(self)
		local signOrder = table.create(#self.config.Signs)

		for i = 1, #self.config.Signs do
			signOrder[i] = i
		end

		self.wheel_random:Shuffle(signOrder)
		self.signOrder = signOrder
		self.wheelSigns = table.create(#self.config.Signs)

		for i, v2 in ipairs(signOrder) do
			local sign = self.config.Signs[v2]
			local clone = self.uiFolder.sign:Clone()
			clone.baseSign.Image = sign.base
			clone.glowSign.Image = sign.glow
			clone.Rotation = i * 30 - 15

			if not self.config.ShouldRotateIcons then
				clone.baseSign.Rotation = -clone.Rotation
				clone.glowSign.Rotation = -clone.Rotation
			end

			clone.Name = `sign{i}`
			clone.Parent = self.wheel
			table.insert(self.wheelSigns, clone)

			if v2 <= self.signProgress then
				clone:AddTag("WheelSignSelected")
			end
		end

		self.currentHovered = nil
		self.currentHoveredFrame = nil
	end,
	BuildFishingBarSigns = function(self)
		local signOrder = table.create(#self.config.Signs)

		for i = 1, #self.config.Signs do
			signOrder[i] = i
		end

		self.wheel_random:Shuffle(signOrder)
		self.signOrder = signOrder
		self.wheelSigns = table.create(#self.config.Signs)
		self.current.reel_bar.Interactable = true

		for i, v2 in ipairs(signOrder) do
			if v2 <= self.signProgress then
				continue
			end

			local sign = self.config.Signs[v2]
			local clone = self.uiFolder.sign2:Clone()
			clone.baseSign.Image = sign.base
			clone.glowSign.Image = sign.glow
			clone.glowSign2.Image = sign.glow
			clone.Position = UDim2.fromScale((i - 1) / 11, 0.5)
			clone.Name = `sign{i}`
			clone.UIScale.Scale = 0
			clone.Parent = self.signContainer
			self.wheelSigns[i] = clone
			self.current:DelayLogic((v2 - (self.signProgress + 1)) / 11 * 2.5 + 0.5, function()
				if clone:FindFirstChild("UIScale") and not self.wheelHidden then
					self.current.logicTweens:Create(clone.UIScale, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
						Scale = 1
					}):Play()
				end
			end)

			if v2 <= self.signProgress then
				clone:AddTag("WheelSignSelected")
			end

			local currentHovered = i
			local currentHoveredFrame = clone
			self.reelTrove:Add(clone.Activated:Connect(function()
				self.currentHovered = currentHovered
				self.currentHoveredFrame = currentHoveredFrame
				self:OnClick()
			end))
		end

		self.currentHovered = nil
		self.currentHoveredFrame = nil
	end,
	BuildWheel = function(self)
		local clone = self.uiFolder.wheel:Clone()
		self.wheel = clone
		self:BuildWheelSigns()
		clone.Position = UDim2.fromScale(0.5, -0.6)
		clone.Parent = self.uiContainer
		self.wheelPos = clone.AbsolutePosition
		self.wheelSize = clone.AbsoluteSize
		self.wheelCenter = self.wheelPos + self.wheelSize / 2
		self.reelTrove:Add(clone:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			self.wheelPos = clone.AbsolutePosition
			self.wheelCenter = self.wheelPos + self.wheelSize / 2
		end))
		self.reelTrove:Add(clone:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			self.wheelSize = clone.AbsoluteSize
			self.wheelCenter = self.wheelPos + self.wheelSize / 2
		end))
		self.current.logicTweens:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quart), {
			Position = UDim2.fromScale(0.5, 0.4)
		}):Play()
	end,
	BuildSignBar = function(self)
		local clone = self.uiFolder.signbar:Clone()
		self.signbar = clone
		self.signbarStars = table.create(#self.config.Signs)
		local clone2 = nil

		for i, sign in ipairs(self.config.Signs) do
			clone2 = self.uiFolder.star:Clone()
			clone2.LayoutOrder = i
			clone2.sign.Image = sign.hint
			clone2.Parent = clone
			self.signbarStars[i] = clone2

			if i <= self.signProgress then
				clone2:AddTag("StellarwaveStarActive")
			end
		end

		clone.Position = UDim2.fromScale(0.5, 1.2)
		clone.Parent = self.uiContainer
		clone.UIListLayout.Padding = UDim.new(0, -clone2.AbsoluteSize.X)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
			Position = UDim2.fromScale(0.5, 0.775)
		}):Play()
		TweenService:Create(clone.UIListLayout, TweenInfo.new(1, Enum.EasingStyle.Quint), {
			Padding = UDim.new(0, 0)
		}):Play()
	end,
	Morph = function(self, _, object2)
		self.uiFolder = script.ui:FindFirstChild(self.config.UIFolderName or "default") or script.ui.default
		object2.core.ui.ColorShift_Enabled = false
		object2.core.ui.OnBarEffects_Enabled = false
		object2:Preload({ self.uiFolder })
		self.wheel_random = object2:GetRandom(87)
		self.wheelHidden = false
		self.signProgress = object2.data.ZodiacWheel_StartingProgress or 0
		self.signClicks = 0
		self.missStreak = 0
		self.missCount = 0
		self.controlBoost = object2:CreateModifier("barSize", "add")
		self.controlBoost.Value = self.config.TemporaryControlBuff
		self.currentGamepadInput = nil
		self.currentHovered = nil
		self.currentHoveredFrame = nil
		local v = self.reelTrove:Add(Instance.new("Folder"))
		local styleLink = Instance.new("StyleLink")
		styleLink.StyleSheet = ReplicatedStorage.client.design.StellarwaveMelody
		styleLink.Parent = v
		v.Parent = object2.reel
		self.uiContainer = v
		local v2 = self.reelTrove:Add(self.uiFolder.signContainer:Clone())
		local styleLink2 = Instance.new("StyleLink")
		styleLink2.StyleSheet = ReplicatedStorage.client.design.StellarwaveMelody
		styleLink2.Parent = v2
		v2.Parent = object2.reel_bar
		self.signContainer = v2

		if self.config.AlwaysUseWheel or UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			self:BuildWheel()
		else
			self:BuildFishingBarSigns()
		end

		self:BuildSignBar()
		self.fade = self.reelTrove:Add(self.uiFolder.fade:Clone())
		self.fade.BackgroundTransparency = 1
		self.fade.Parent = HudController:GetOverlayGui()
		TweenService:Create(self.fade, TweenInfo.new(1, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 0.05
		}):Play()
		task.spawn(function()
			object2:WaitLogic(self.config.WheelLifetime)

			if not object2.active then
				return
			end

			self:HideWheel()
		end)
		self.reelTrove:Add(object2.PreMinigameEnd:Once(function()
			self:HideWheel()
		end))
		self.reelTrove:Add(UserInputService.InputChanged:Connect(function(currentGamepadInput, _)
			if self.wheelHidden then
				return
			end

			if currentGamepadInput.KeyCode == Enum.KeyCode.Thumbstick1 then
				self.currentGamepadInput = currentGamepadInput
			end
		end))
		self.reelTrove:Add(UserInputService.InputBegan:Connect(function(currentGamepadInput, _)
			if self.wheelHidden then
				return
			end

			if currentGamepadInput.KeyCode == Enum.KeyCode.Thumbstick1 then
				self.currentGamepadInput = currentGamepadInput
			elseif currentGamepadInput.KeyCode == Enum.KeyCode.ButtonA or (currentGamepadInput.UserInputType == Enum.UserInputType.MouseButton1 or currentGamepadInput.UserInputType == Enum.UserInputType.Touch) and self.config.AlwaysUseWheel then
				self:OnClick()
			end
		end))
		self.reelTrove:Add(UserInputService.InputEnded:Connect(function(input, _)
			if self.wheelHidden then
				return
			end

			if input.KeyCode == Enum.KeyCode.Thumbstick1 and self.currentGamepadInput == input then
				self.currentGamepadInput = nil
			end
		end))
		self.reelTrove:Add(object2.BuildEndingData:Bind(function(p)
			p.ZodiacWheel_ClickCount = self.signClicks
			p.ZodiacWheel_MissCount = self.missCount
			return p
		end))
	end,
	UpdateHovered = function(self)
		local zero = Vector2.zero

		if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
			if self.currentGamepadInput ~= nil and self.currentGamepadInput.Position.Magnitude > math.max(
				SettingsController:GetSettingValue("consoleDeadzoneLeft"),
				0.1
			) then
				zero = Vector2.new(self.currentGamepadInput.Position.X, self.currentGamepadInput.Position.Y)
			end
		else
			if not self.config.AlwaysUseWheel then
				return
			end

			local v = (UserInputService:GetMouseLocation() - GuiService:GetGuiInset() - self.wheelCenter) * Vector2.new(
				1,
				-1
			)

			if v.Magnitude > self.wheelSize.X * 0.25 and v.Magnitude < self.wheelSize.X * 0.75 then
				zero = v
			end
		end

		local currentHovered

		if zero ~= Vector2.zero then
			currentHovered = math.deg(zero.Unit:Angle(-Vector2.yAxis, true) + 3.141592653589793) // (360 / #self.config.Signs) % #self.config.Signs + 1
		end

		if currentHovered ~= self.currentHovered then
			if self.currentHoveredFrame then
				self.currentHoveredFrame:RemoveTag("WheelSignHover")
			end

			self.currentHovered = currentHovered
			local currentHoveredFrame

			if currentHovered ~= nil then
				currentHoveredFrame = self.wheelSigns[currentHovered]
			end

			self.currentHoveredFrame = currentHoveredFrame

			if self.currentHoveredFrame then
				self.currentHoveredFrame:AddTag("WheelSignHover")
			end
		end
	end,
	OnClick = function(self)
		self:UpdateHovered()

		if not self.currentHovered or self.signProgress >= #self.config.Signs then
			return
		end

		local index = table.find(self.signOrder, self.signProgress + 1)

		if self.currentHovered == index then
			self.missStreak = 0

			if self.currentHoveredFrame then
				self.currentHoveredFrame:AddTag("WheelSignSelected")
			end

			self.signProgress += 1
			self.signClicks += 1
			self.signbarStars[self.signProgress]:AddTag("StellarwaveStarActive")

			if self.config.ProgressPerSign then
				self.current:AddProgress(self.config.ProgressPerSign)
			end

			for _, threshold in ipairs(self.config.Thresholds) do
				if self.signProgress ~= threshold.Threshold then
					continue
				end

				if threshold.Progress then
					self.current:AddProgress(threshold.Progress)
				end

				if threshold.Resilience then
					self.current:AddModifier("resilience", "add", threshold.Resilience)
				end

				if not threshold.ProgressSpeed then
					break
				end

				self.current:AddModifier(
					"progressefficiency",
					"add",
					threshold.ProgressSpeed * ((1 - self.config.ForcedProgressRatio) * 0.01)
				)
				self.current:AddModifier(
					"progressefficiency",
					"force_add",
					threshold.ProgressSpeed * (self.config.ForcedProgressRatio * 0.01)
				)
				break
			end

			if self.signClicks >= self.config.HardClickLimit then
				self:HideWheel()
			elseif self.signProgress >= #self.config.Signs then
				local current = self.current
				current:WaitLogic(0.5)

				if current.ready and not current.active then
					return
				end

				self.signProgress = 0

				for _, wheelSign in self.wheelSigns do
					wheelSign:Destroy()
				end

				if self.wheel then
					self:BuildWheelSigns()
				else
					self:BuildFishingBarSigns()
				end

				for _, signbarStar in ipairs(self.signbarStars) do
					signbarStar:RemoveTag("StellarwaveStarActive")
				end
			end
		else
			self.missStreak += 1
			self.missCount += 1

			if self.missStreak >= 4 then
				self:HideWheel()
			end
		end
	end,
	TickLogic_Rod = function(self, _)
		self:UpdateHovered()
	end
}
setmetatable(StellarwaveMelodyZodiacWheel, module)
return StellarwaveMelodyZodiacWheel