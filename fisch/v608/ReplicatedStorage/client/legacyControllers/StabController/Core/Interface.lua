local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local GamepadService = game:GetService("GamepadService")
local localPlayer = Players.LocalPlayer
require(ReplicatedStorage.packages.Trove)
local fx = require(ReplicatedStorage.shared.modules.fx)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
local mutations = require(ReplicatedStorage.shared.modules.fishing.mutations)
local fishing = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("fishing")
require("../Types")
local Interface = {}
Interface.__index = Interface

function Interface.new(current)
	local object = setmetatable({}, Interface)
	object.current = current
	object.trove = current.trove:Extend()
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
	object.StartStopAnim_Enabled = true
	object.StartStopAnim_StartTime = 1
	object.StartStopAnim_EndTimeSuccess = 0.75
	object.StartStopAnim_EndTimeFail = 1.15
	object.ReelSound_Enabled = true
	object.ReelSound_Sound = humanoidRootPart and humanoidRootPart:FindFirstChild("reeling")
	object.ReelSound_ActiveVolume = 0.15
	object.ReelSound_InactiveVolume = 0.08
	object.InputSounds_Enabled = true
	object.InputSounds_Left = fishing.dirchangeleft
	object.InputSounds_Right = fishing.dirchangeright
	object.BounceSounds_Enabled = true
	object.BounceSounds_Sound = fishing.bounce
	object.InputGuide_Enabled = true
	object.InputGuide_ActiveColor = Color3.fromRGB(88, 109, 129)
	object.InputGuide_InactiveColor = Color3.fromRGB(239, 239, 239)
	object.InputGuide_GuiPC = object.current.reel_bar:FindFirstChild("pc")
	object.InputGuide_GuiMobile = object.current.reel_bar:FindFirstChild("mobile")
	object.InputGuide_GuiXbox = object.current.reel_playerbar:FindFirstChild("xboxcontrol")
	object.BarArrows_Enabled = true
	object.CameraFOV_Enabled = true
	object.CameraFOV_ActiveFOV = 55
	object.CameraFOV_InactiveFOV = 56
	object.CameraFOV_SpringVelocity = 0
	object.CameraFOV_AnimTime = 0.2
	object.ShinyNotify_Enabled = true
	object.MutationNotify_Enabled = true
	object.ColorShift_Enabled = true
	object.ColorShift_StartColor = Color3.fromRGB(99, 42, 42)
	object.ColorShift_EndColor = Color3.fromRGB(89, 126, 89)
	object.ColorShift_MiddleColor = Color3.new(1, 1, 1)
	object.ApexGradients_Enabled = true
	object.OnBarEffects_Enabled = true
	object.OnBarEffects_ColorChangeEnabled = true
	object.CameraShake_Enabled = true
	object.CameraShake_CurrentShake = nil
	object.DisableNavigation_Enabled = true

	for k, v in current.reel:GetAttributes() do
		if object[k] ~= nil then
			object[k] = v
		end
	end

	object.trove:Add(function()
		object.CameraShake_Enabled = false

		if object.CameraShake_CurrentShake then
			object.CameraShake_CurrentShake.Stop()
		end
	end)
	return object
end

function Interface:Start()
	if self.StartStopAnim_Enabled then
		local screenpos = self.current.data.screenpos or self.current.reel_bar.Position
		self.current.reel_bar.Position += UDim2.fromScale(0, 0.5)
		TweenService:Create(
			self.current.reel_bar,
			TweenInfo.new(self.StartStopAnim_StartTime, Enum.EasingStyle.Exponential),
			{
				Position = screenpos
			}
		):Play()
	end

	self.trove:Add(self.current.OnBarDirectionChange:Connect(function(p: number)
		if self.Disabled or not self.current.active then
			return
		end

		if self.InputSounds_Enabled then
			local inputSounds_Right

			if p == 1 then
				inputSounds_Right = self.InputSounds_Right
			else
				inputSounds_Right = self.InputSounds_Left
			end

			if inputSounds_Right then
				fx:PlaySound(inputSounds_Right, self.current.reel, false)
			end
		end

		if self.InputGuide_Enabled then
			local inputGuide_ActiveColor = p == 1 and self.InputGuide_ActiveColor or self.InputGuide_InactiveColor

			if self.InputGuide_GuiPC then
				self.InputGuide_GuiPC.ImageColor3 = inputGuide_ActiveColor
			end

			if self.InputGuide_GuiMobile then
				self.InputGuide_GuiMobile.ImageColor3 = inputGuide_ActiveColor
			end

			if self.InputGuide_GuiXbox then
				self.InputGuide_GuiXbox.ImageColor3 = inputGuide_ActiveColor
			end
		end

		if self.BarArrows_Enabled then
			self.current.reel_playerbar.left.Visible = p < 0
			self.current.reel_playerbar.right.Visible = p > 0
		end

		if self.CameraShake_Enabled then
			if self.CameraShake_CurrentShake then
				self.CameraShake_CurrentShake.Stop()
			end

			self.CameraShake_CurrentShake = fx:ShakeScreen(localPlayer, p > 0 and 1 or 0, -1)
		end
	end))

	if self.ShinyNotify_Enabled and not self.Disabled then
		task.delay(0.8, function()
			local shiny = self.current.fish.Shiny
			local sparkling = self.current.fish.Sparkling

			if not (shiny or sparkling) then
				fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.popup, self.current.reel, false)
				return
			end

			local frame = Instance.new("Frame")
			frame.Name = "SpecialContainer"
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromScale(1, 0.175)
			frame.AnchorPoint = Vector2.new(0, 0.5)
			frame.Position = UDim2.fromScale(0, 0.5)
			frame.BackgroundTransparency = 1
			local uIListLayout = Instance.new("UIListLayout")
			uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			uIListLayout.FillDirection = Enum.FillDirection.Horizontal
			uIListLayout.Padding = UDim.new(0.05, 0)
			uIListLayout.Parent = frame
			frame.Parent = self.current.reel
			self.trove:Add(frame)

			local function createStar(image, imageColor)
				local clone = script.Shiny:Clone()
				clone.Parent = frame
				clone.Image = image
				clone.ImageColor3 = imageColor
				clone.Size = UDim2.fromScale(1, 1)
				clone.ImageTransparency = 0
				local clone2 = clone:Clone()
				clone2.Position = UDim2.fromScale(0.5, 0.5)
				clone2.Size = UDim2.fromScale(1, 1)
				clone2.Parent = clone
				TweenService:Create(clone2, TweenInfo.new(0.5), {
					Size = UDim2.fromScale(1.5, 1.5),
					ImageTransparency = 1
				}):Play()
				TweenService:Create(clone, TweenInfo.new(1), {
					ImageTransparency = 1
				}):Play()
			end

			if shiny then
				fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.shiny, self.current.reel, false)

				if not SettingsController:GetSettingValue("photosensitiveMode") then
					local frame2 = Instance.new("Frame")
					local uIGradient = Instance.new("UIGradient")
					uIGradient.Rotation = 90
					uIGradient.Transparency = NumberSequence.new(1, 0)
					uIGradient.Parent = frame2
					frame2.BackgroundTransparency = 1
					frame2.BackgroundColor3 = Color3.fromRGB(255, 225, 134)
					frame2.Size = UDim2.fromScale(1, 1)
					frame2.BorderSizePixel = 0
					frame2.Parent = localPlayer.PlayerGui:WaitForChild("over")
					TweenService:Create(frame2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
						BackgroundTransparency = 0.6
					}):Play()
					self.trove:Add(frame2)
					task.wait(0.3)
					frame2:Destroy()
				end

				createStar("rbxassetid://115495107196442", Color3.fromRGB(255, 225, 134))
			end

			if sparkling then
				createStar("rbxassetid://129869580684051", Color3.fromRGB(255, 184, 126))

				if not shiny then
					fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.shine, self.current.reel, false)
				end
			end

			task.delay(2, function()
				frame:Destroy()
			end)
		end)
	end

	local v = self.MutationNotify_Enabled and not self.Disabled and self.current.data.ShowMutation and self.current.fish.Mutation and mutations.Mutations[self.current.fish.Mutation]

	if v then
		task.delay(0.25, function()
			local clone = script.mutationIndicator:Clone()
			local color

			if typeof(v.Color) == "ColorSequence" then
				color = v.Color
			else
				color = ColorSequence.new(v.Color)
			end

			clone.gradient.UIGradient.Color = color
			clone.mutationName.UIGradient.Color = color
			clone.mutationName.Text = v.Display
			TweenService:Create(clone.gradient, TweenInfo.new(2, Enum.EasingStyle.Linear), {
				ImageTransparency = 1
			}):Play()

			if SettingsController:GetSettingValue("photosensitiveMode") then
				clone.gradient.ImageTransparency = 1
			end

			TweenService:Create(clone.mutationName, TweenInfo.new(2, Enum.EasingStyle.Linear), {
				TextTransparency = 1
			}):Play()
			clone.Parent = localPlayer.PlayerGui:WaitForChild("over")
		end)
	end

	if self.ApexGradients_Enabled then
		local v2 = fish[self.current.fish.Name]

		if v2.BiteColor then
			self.current.reel_playerbar.BackgroundColor3 = v2.BiteColor
			local apexGradient = self.current.reel_playerbar:FindFirstChild("ApexGradient")

			if apexGradient then
				apexGradient.Enabled = true
			end

			self.OnBarEffects_ColorChangeEnabled = false
		end
	end

	local backgroundColor3 = self.current.reel_playerbar.BackgroundColor3
	local backgroundTransparency = self.current.reel_playerbar.BackgroundTransparency
	self.trove:Add(self.current.OnFishEnterBar:Connect(function()
		if not self.OnBarEffects_Enabled then
			return
		end

		self.current.reel_playerbar.BackgroundTransparency = backgroundTransparency

		if self.OnBarEffects_ColorChangeEnabled and self.ColorShift_Enabled then
			self.current.reel_playerbar.BackgroundColor3 = backgroundColor3
		end
	end))
	self.trove:Add(self.current.OnFishExitBar:Connect(function()
		if not self.OnBarEffects_Enabled then
			return
		end

		self.current.reel_playerbar.BackgroundTransparency = math.clamp(backgroundTransparency + 0.2, 0, 1)
	end))

	if self.InputGuide_Enabled then
		self:UpdateInputUI()
		self.trove:Add(UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
			if self.InputGuide_Enabled then
				self:UpdateInputUI()
			end
		end))
	end

	self.trove:Add(self.current.PreMinigameEnd:Connect(function(p)
		local currentCamera = workspace.CurrentCamera

		if currentCamera and self.CameraFOV_Enabled then
			if p then
				TweenService:Create(currentCamera, TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					FieldOfView = 70
				}):Play()
			else
				TweenService:Create(
					currentCamera,
					TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 1),
					{
						FieldOfView = 70
					}
				):Play()
			end
		end

		if self.StartStopAnim_Enabled then
			local position = self.current.reel_bar.Position + UDim2.fromScale(0, 1)
			self.current.reel_bar:SetAttribute("RootPosition", position)

			if p then
				TweenService:Create(
					self.current.reel_bar,
					TweenInfo.new(
						self.StartStopAnim_EndTimeSuccess,
						Enum.EasingStyle.Quad,
						Enum.EasingDirection.In,
						0,
						false,
						0.1
					),
					{
						Position = position
					}
				):Play()
			else
				TweenService:Create(
					self.current.reel_bar,
					TweenInfo.new(
						self.StartStopAnim_EndTimeFail,
						Enum.EasingStyle.Quint,
						Enum.EasingDirection.In,
						0,
						false,
						0.1
					),
					{
						Position = position,
						Rotation = 45
					}
				):Play()
			end
		end
	end))
	self.trove:Add(self.current.OnBarBounce:Connect(function(_, p)
		if self.BounceSounds_Enabled and self.BounceSounds_Sound and math.abs(p) > 0.1 then
			fx:PlaySound(self.BounceSounds_Sound, self.current.reel, true)
		end
	end))
	self.trove:Connect(GuiService:GetPropertyChangedSignal("SelectedObject"), function()
		self:DisableNavigation()
	end)
	self.trove:Connect(GamepadService:GetPropertyChangedSignal("GamepadCursorEnabled"), function()
		self:DisableNavigation()
	end)
end

function Interface:DisableNavigation()
	if not self.DisableNavigation_Enabled then
		return
	end

	if GamepadService.GamepadCursorEnabled then
		GamepadService:DisableGamepadCursor()
	end

	if GuiService.SelectedObject then
		GuiService.SelectedObject = nil
	end
end

function Interface:UpdateInputUI()
	local preferredInput = UserInputService.PreferredInput

	if self.InputGuide_GuiPC then
		self.InputGuide_GuiPC.Visible = preferredInput == Enum.PreferredInput.KeyboardAndMouse
	end

	if self.InputGuide_GuiXbox then
		self.InputGuide_GuiXbox.Visible = preferredInput == Enum.PreferredInput.Gamepad
	end

	if self.InputGuide_GuiMobile then
		self.InputGuide_GuiMobile.Visible = preferredInput == Enum.PreferredInput.Touch
	end
end

function Interface:Disable()
	self.Disabled = true
end

function Interface.Stop(p)
	p.trove:Clean()
end

function Interface:Tick(p: number)
	if self.Disabled then
		return
	end

	if self.ReelSound_Enabled and self.ReelSound_Sound then
		self.ReelSound_Sound.Volume = self.current.onbar and self.ReelSound_ActiveVolume or self.ReelSound_InactiveVolume
		self.ReelSound_Sound.PlaybackSpeed = math.clamp(self.current.progress / 100, 0.8, 1.2) + 0.1
	end

	local currentCamera = workspace.CurrentCamera

	if self.CameraFOV_Enabled and currentCamera and (not self.current.ready or self.current.active) then
		local smoothDamp, cameraFOV_SpringVelocity = TweenService:SmoothDamp(
			currentCamera.FieldOfView,
			self.CameraFOV_InactiveFOV,
			self.CameraFOV_SpringVelocity,
			self.CameraFOV_AnimTime or 0.2,
			nil,
			p
		)
		currentCamera.FieldOfView = smoothDamp
		self.CameraFOV_SpringVelocity = cameraFOV_SpringVelocity
	end

	if self.ColorShift_Enabled then
		local v = math.clamp(self.current.progress / 100, 0, 1)
		local lerped = self.ColorShift_StartColor:Lerp(self.ColorShift_EndColor, v)
		local colorSequence = ColorSequence.new({
			ColorSequenceKeypoint.new(0, lerped),
			ColorSequenceKeypoint.new(0.1, lerped),
			ColorSequenceKeypoint.new(0.2, self.ColorShift_MiddleColor),
			ColorSequenceKeypoint.new(0.8, self.ColorShift_MiddleColor),
			ColorSequenceKeypoint.new(0.9, lerped),
			ColorSequenceKeypoint.new(1, lerped)
		})
		self.current.reel_bar.stroke.UIGradient.Color = colorSequence
		self.current.reel_bar.licon.ImageColor3 = lerped
		self.current.reel_bar.ricon.ImageColor3 = lerped

		if not self.current.onbar and self.OnBarEffects_Enabled and self.OnBarEffects_ColorChangeEnabled then
			self.current.reel_playerbar.BackgroundColor3 = lerped
		end
	end
end

return Interface