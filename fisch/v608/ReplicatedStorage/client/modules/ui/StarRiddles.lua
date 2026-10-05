local createVector = vector.create
game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Players2 = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
require(packages.Signal)
local Trove = require(packages.Trove)
local _ = ReplicatedStorage.shared.modules
local utils = ReplicatedStorage.shared.utils
require(utils.GeneralUtils)
require(utils.NumberUtils)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local LightingController = require(ReplicatedStorage.client.legacyControllers.LightingController)
local CutsceneController = require(ReplicatedStorage.client.legacyControllers.CutsceneController)
local SettingsController = require(ReplicatedStorage.client.legacyControllers.SettingsController)
local playerGui = HudController:GetPlayerGui()
local deviceInsetGui = HudController:GetDeviceInsetGui()
local starRiddles = playerGui:WaitForChild("StarRiddles")
local starfall = workspace:WaitForChild("active"):WaitForChild("constant"):WaitForChild("Starfall")
local music = SoundService:WaitForChild("music")
local remoteEvent = Net:RemoteEvent("StarRiddles/Open", -1)
local starRiddlesScene = script.StarRiddlesScene
local flag = false
local v = CFrame.new(-369.57, 3476.013, -84.851) * CFrame.fromOrientation(0.024626595745639992, 1.2734794887176626, 0)
local v2 = {
	hud = true,
	backpack = true,
	deviceInset = true,
	Return = false,
	quickAccess = false,
	TopbarCentered = true,
	TopbarCenteredClipped = true,
	TopbarStandard = true,
	TopbarStandardClipped = true
}
local StarRiddles = {}
local v3 = false
local v4 = false
local v5 = false
local maid = Trove.new()
local track = nil
local track2 = nil

function StarRiddles.handleLighting(data)
	data.Lighting.Ambient = Color3.fromRGB(70, 70, 70)
	data.Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
	data.Lighting.Brightness = 3
	data.Lighting.ColorShift_Top = Color3.new()
	data.Lighting.ColorShift_Bottom = Color3.new()
	data.Lighting.EnvironmentDiffuseScale = 1
	data.Lighting.EnvironmentSpecularScale = 1
	data.Lighting.ClockTime = 0
	data.Lighting.GeographicLatitude = 0
	data.Lighting.ExposureCompensation = 0
	data.Atmosphere.Density = 0.3
	data.Atmosphere.Offset = 0
	data.Atmosphere.Color = Color3.fromRGB(100, 33, 117)
	data.Atmosphere.Decay = Color3.fromRGB(31, 77, 75)
	data.Atmosphere.Glare = 1
	data.Atmosphere.Haze = 3
	data.BloomEffect.Intensity = 1
	data.BloomEffect.Size = 64
	data.BloomEffect.Threshold = 1.25
	data.ColorCorrectionEffect.Brightness = 0
	data.ColorCorrectionEffect.Contrast = 1
	data.ColorCorrectionEffect.Saturation = 0
	data.ColorCorrectionEffect.TintColor = Color3.fromRGB(184, 249, 255)
	data.DepthOfFieldEffect.FarIntensity = 0
	data.DepthOfFieldEffect.NearIntensity = 0
	data.SunRaysEffect.Intensity = 0
	data.Clouds.Cover = 0
	data.Clouds.Density = 0
	data.BlurEffect.Size = 0
	return data
end

local v6 = 0
local random = Random.new()

function StarRiddles.TickFakeStarfall(p: number)
	if v6 > 0 then
		v6 -= p
		return
	end

	v6 = random:NextNumber(0.3, 1.2) / 2
	local vector2 = Vector3.new(
		0 - math.random(1000, 1300),
		math.clamp(3000 + math.random(700, 800), -160, 10000),
		-500 + math.random(0, 2000)
	)
	local vector3 = Vector3.new(vector2.X - 200, vector2.Y - 800, vector2.Z - 1500)
	local v7 = (vector2 - vector3).Magnitude / math.random(350, 425)
	local clone = starfall:WaitForChild("StarTemplate"):Clone()
	clone.Name = "Star"

	for _, descendant in clone:GetDescendants() do
		if not (descendant:IsA("Trail") or descendant:IsA("BillboardGui") or descendant:IsA("Script")) then
			continue
		end

		descendant.Enabled = true
	end

	clone.Position = vector2
	clone.Parent = starfall
	task.delay(v7 + 1, clone.Destroy, clone)
	TweenService:Create(clone, TweenInfo.new(v7), {
		Position = vector3
	}):Play()
end

function StarRiddles:UpdateHovered()
	local zero = Vector2.zero

	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		if self.currentGamepadInput ~= nil and self.currentGamepadInput.Position.Magnitude > math.max(
			SettingsController:GetSettingValue("consoleDeadzoneLeft"),
			0.1
		) then
			zero = Vector2.new(self.currentGamepadInput.Position.X, self.currentGamepadInput.Position.Y)
		end
	else
		local v7 = (UserInputService:GetMouseLocation() - GuiService:GetGuiInset() - self.wheelCenter) * Vector2.new(
			1,
			-1
		)

		if v7.Magnitude > self.wheelSize.X * 0.15 and v7.Magnitude < self.wheelSize.X * 0.45 then
			zero = v7
		end
	end

	local currentHovered

	if zero ~= Vector2.zero then
		currentHovered = (math.deg(zero.Unit:Angle(-Vector2.yAxis, true) + 3.141592653589793) - starRiddles.wheel.Rotation) // 30 % 12 + 1
	end

	if currentHovered ~= self.currentHovered then
		if self.currentHoveredFrame then
			self.currentHoveredFrame:RemoveTag("WheelSignHover")
		end

		self.currentHovered = currentHovered
		local currentHoveredFrame

		if currentHovered ~= nil then
			currentHoveredFrame = starRiddles.wheel:FindFirstChild((`sign{currentHovered}`))
		end

		self.currentHoveredFrame = currentHoveredFrame

		if self.currentHoveredFrame then
			self.currentHoveredFrame:AddTag("WheelSignHover")
		end
	end
end

function StarRiddles:OnClick()
	self:UpdateHovered()

	if self.currentTargetRotation == nil then
		self.currentTargetRotation = starRiddles.wheel.Rotation
	end

	if self.currentHoveredFrame then
		local v7 = self.currentHoveredFrame.Rotation - self.currentTargetRotation % 360

		if v7 > 180 then
			v7 -= 360
		elseif v7 < -180 then
			v7 += 360
		end

		self.currentTargetRotation += v7
		TweenService:Create(starRiddles.wheel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
			Rotation = 90 - self.currentTargetRotation
		}):Play()
	end

	for _, child in starRiddles.riddles:GetChildren() do
		if child.Name == `riddle{self.currentHovered}` then
			child:AddTag("RiddleDetailsVisible")
		else
			child:RemoveTag("RiddleDetailsVisible")
		end
	end

	if self.currentHovered then
		starRiddles.noselect:RemoveTag("NoSelectFrameVisible")
	else
		starRiddles.noselect:AddTag("NoSelectFrameVisible")
	end
end

function StarRiddles.open(list, p)
	if v4 or v3 or v5 or not (list and localPlayer.Character) then
		return
	end

	v4 = true
	v3 = true
	localPlayer.Character:SetAttribute("StarRiddlesMenu", 0)
	local humanoid = localPlayer.Character:FindFirstChildWhichIsA("Tool") and localPlayer.Character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid:UnequipTools()
	end

	maid:Clean()
	starRiddlesScene.Parent = workspace.active
	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	TweenService:Create(workspace.CurrentCamera, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		CFrame = CFrame.lookAt(
			workspace.CurrentCamera.CFrame.Position + createVector(0, 100, 0),
			workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector + createVector(
				0,
				5000,
				0
			)
		)
	}):Play()
	CutsceneController:FadeToggle(0.9, true)

	for _, screenGui in ipairs(playerGui:GetChildren()) do
		if screenGui:IsA("ScreenGui") and v2[screenGui.Name] ~= nil then
			screenGui.Enabled = false
		end
	end

	deviceInsetGui.Enabled = false
	ProximityPromptService.Enabled = false
	maid:Add(RunService.RenderStepped:Connect(StarRiddles.TickFakeStarfall))

	for _, emitter in starRiddlesScene.CloudParticles:GetChildren() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter.Rate)
		end
	end

	if p then
		for _, v7 in starRiddlesScene.PlayerAvatar:QueryDescendants("BasePart, Decal, ParticleEmitter, Trail, Beam, Fire, Smoke, Sparkles, Explosion") do
			v7.LocalTransparencyModifier = 0
		end

		if not flag then
			flag = true
			local success, result = pcall(function()
				local playerAvatar = starRiddlesScene.PlayerAvatar
				local clone = playerAvatar:Clone()
				local humanoidDescriptionFromUserIdAsync = Players2:GetHumanoidDescriptionFromUserIdAsync(localPlayer.UserId)
				clone.Parent = starRiddlesScene
				clone.Humanoid:ApplyDescriptionAsync(humanoidDescriptionFromUserIdAsync)
				playerAvatar:Destroy()
			end)

			if not success then
				warn((`Failed to load player avatar to scene: {result}`))

				for _, v7 in starRiddlesScene.PlayerAvatar:QueryDescendants("BasePart, Decal, ParticleEmitter, Trail, Beam, Fire, Smoke, Sparkles, Explosion") do
					v7.LocalTransparencyModifier = 1
				end

				flag = false
			end
		end

		if flag then
			if not track2 then
				track2 = starRiddlesScene.PlayerAvatar.Humanoid.Animator:LoadAnimation(script.idle)
			end

			track2:Play()
		end
	else
		for _, v7 in starRiddlesScene.PlayerAvatar:QueryDescendants("BasePart, Decal, ParticleEmitter, Trail, Beam, Fire, Smoke, Sparkles, Explosion") do
			v7.LocalTransparencyModifier = 1
		end
	end

	if not track then
		track = starRiddlesScene.Lyren.Humanoid.Animator:LoadAnimation(script.idle)
	end

	track:Play()

	for _, v7 in starRiddles.wheel:QueryDescendants("> .WheelSign") do
		v7:RemoveTag("WheelSignHover")
		local v8 = list[v7:GetAttribute("SignId")]

		if v8 and v8.Solution then
			v7:AddTag("WheelSignSelected")
		else
			v7:RemoveTag("WheelSignSelected")
		end
	end

	for i, v7 in ipairs(list) do
		local v8 = maid:Add(script.desc:Clone())
		v8.header.sign.Image = v7.Icon
		v8.header.signName.Text = v7.SignName
		v8.riddle.Text = v7.Riddle

		if v7.Solution then
			v8.state.Text = `Star Sign Activated: <b>{v7.Solution}</b>`
		else
			v8.state.Text = "Catch the corresponding fish with any cosmic mutation to activate this Star Sign"
		end

		v8.Name = `riddle{i}`
		v8.Parent = starRiddles.riddles
	end

	TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		Volume = 0
	}):Play()
	StarRiddles.currentGamepadInput = nil
	StarRiddles.currentHovered = nil
	StarRiddles.currentHoveredFrame = nil
	maid:Add(UserInputService.InputChanged:Connect(function(currentGamepadInput, _)
		if v3 and not v5 and currentGamepadInput.KeyCode == Enum.KeyCode.Thumbstick1 then
			StarRiddles.currentGamepadInput = currentGamepadInput
		end
	end))
	maid:Add(UserInputService.InputBegan:Connect(function(currentGamepadInput, gameProcessed)
		if not v3 or v5 then
			return
		end

		if currentGamepadInput.KeyCode == Enum.KeyCode.Thumbstick1 then
			StarRiddles.currentGamepadInput = currentGamepadInput
		elseif currentGamepadInput.KeyCode == Enum.KeyCode.ButtonA or currentGamepadInput.UserInputType == Enum.UserInputType.MouseButton1 or currentGamepadInput.UserInputType == Enum.UserInputType.Touch then
			StarRiddles:OnClick()
		elseif currentGamepadInput.KeyCode == Enum.KeyCode.ButtonB and not (gameProcessed or v4) then
			StarRiddles.close()
		end
	end))
	maid:Add(UserInputService.InputEnded:Connect(function(input, _)
		if v3 and not v5 and input.KeyCode == Enum.KeyCode.Thumbstick1 and StarRiddles.currentGamepadInput == input then
			StarRiddles.currentGamepadInput = nil
		end
	end))
	StarRiddles.wheelPos = starRiddles.wheel.AbsolutePosition
	StarRiddles.wheelSize = starRiddles.wheel.AbsoluteSize
	StarRiddles.wheelCenter = StarRiddles.wheelPos + StarRiddles.wheelSize / 2
	maid:Add(starRiddles.wheel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		StarRiddles.wheelPos = starRiddles.wheel.AbsolutePosition
		StarRiddles.wheelCenter = StarRiddles.wheelPos + StarRiddles.wheelSize / 2
	end))
	maid:Add(starRiddles.wheel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		StarRiddles.wheelSize = starRiddles.wheel.AbsoluteSize
		StarRiddles.wheelCenter = StarRiddles.wheelPos + StarRiddles.wheelSize / 2
	end))
	maid:Add(RunService.RenderStepped:Connect(function()
		StarRiddles:UpdateHovered()
	end))
	ContentProvider:PreloadAsync({
		starRiddlesScene,
		starRiddles,
		script.idle,
		script.Music
	})
	task.wait(1)
	maid:Add(LightingController.HookLighting:BindAtPriority(99999999, StarRiddles.handleLighting))
	LightingController.UpdateLighting(0)
	starRiddles.Enabled = true
	starRiddles.StarRiddlesBg.Enabled = true
	workspace.CurrentCamera.CFrame = v
	workspace.CurrentCamera.Focus = v
	workspace.CurrentCamera.FieldOfView = 51
	script.Music.Volume = 0.25
	script.Music:Play()
	CutsceneController:FadeToggle(1, false)
	v4 = false
end

function StarRiddles.close()
	if v4 or v5 or not v3 then
		return
	end

	v3 = false
	v5 = true
	CutsceneController:FadeToggle(1, true)
	TweenService:Create(script.Music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		Volume = 0
	}):Play()
	task.wait(1)
	maid:Clean()
	LightingController.UpdateLighting(0)

	if track then
		track:Stop()
	end

	if track2 then
		track2:Stop()
	end

	starRiddlesScene.Parent = script
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	workspace.CurrentCamera.FieldOfView = 70
	starRiddles.Enabled = false
	starRiddles.StarRiddlesBg.Enabled = false
	CutsceneController:FadeToggle(1, false)
	TweenService:Create(music, TweenInfo.new(1, Enum.EasingStyle.Linear), {
		Volume = music:GetAttribute("DefaultVolume") * (SettingsController:GetSettingValue("musicVolume") / 100)
	}):Play()
	task.wait(1)

	for _, screenGui in playerGui:GetChildren() do
		if screenGui:IsA("ScreenGui") and v2[screenGui.Name] == true then
			screenGui.Enabled = true
		end
	end

	deviceInsetGui.Enabled = true
	ProximityPromptService.Enabled = true

	if localPlayer.Character then
		localPlayer.Character:SetAttribute("StarRiddlesMenu", nil)
	end

	script.Music:Stop()
	v5 = false
end

function StarRiddles.init()
	remoteEvent.OnClientEvent:Connect(StarRiddles.open)
	starRiddles.closeBtn.Activated:Connect(function()
		if v3 and not (v4 or v5) then
			StarRiddles.close()
		end
	end)
	starRiddles:GetPropertyChangedSignal("Enabled"):Connect(function()
		starRiddles.StarRiddlesBg.Enabled = starRiddles.Enabled
	end)
end

return StarRiddles