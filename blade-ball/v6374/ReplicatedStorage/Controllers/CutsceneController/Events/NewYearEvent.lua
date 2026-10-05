local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.ClientGameModules.CameraShaker)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Shared.CutsceneUtil)
local v3 = require3(ReplicatedStorage2.Shared.FastUtils)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local currentCamera = workspace.CurrentCamera
local _ = script:FindFirstAncestorWhichIsA("ModuleScript").Shared
local cframe = CFrame.new(0, 1e20, 0)
return function(data)
	local WAIT_INTERVAL = 0.5

	if data.CutsceneStarted then
		data.CutsceneStarted()
	end

	local maid = v2.new()
	local map = data.Map or nil
	local extra = data.Extra or {}

	if map and extra.MapPosition then
		map:PivotTo(cframe)
		maid:Add(function()
			if map and map.Parent then
				map:PivotTo(extra.MapPosition)
			end
		end)
	end

	local function UpdateLighting(lighting)
		if not lighting then
			return
		end

		local sky = lighting:FindFirstChildWhichIsA("Sky")

		if sky then
			local sky2 = Lighting:FindFirstChildOfClass("Sky")
			sky.Parent = Lighting

			if sky2 then
				sky2:Destroy()
			end

			maid:Add(sky)
		end

		if lighting:GetAttribute("DoNotChangeNight") then
			workspace:SetAttribute("DoNotChangeNight", true)
			maid:Add(function()
				workspace:SetAttribute("DoNotChangeNight", nil)
			end)
		end

		if lighting:GetAttribute("UseCustomLighting") then
			for _, attributeName in {
				"Ambient",
				"Brightness",
				"ClockTime",
				"ColorShift_Bottom",
				"ColorShift_Top",
				"EnvironmentDiffuseScale",
				"EnvironmentSpecularScale",
				"FogColor",
				"FogStart",
				"FogEnd",
				"GeographicLatitude",
				"OutdoorAmbient"
			} do
				if not (lighting:GetAttribute(attributeName) ~= nil and lighting:GetAttribute(attributeName) ~= Lighting[attributeName]) then
					continue
				end

				local v4 = Lighting[attributeName]
				Lighting[attributeName] = lighting:GetAttribute(attributeName)
				local v5 = attributeName
				maid:Add(function()
					Lighting[v5] = v4
				end)
			end
		end

		local clouds = lighting:FindFirstChild("Clouds")
		local clouds2 = workspace.Terrain:FindFirstChildWhichIsA("Clouds")

		if clouds and clouds2 then
			for _, attributeName in {
				"Color",
				"Cover",
				"Density",
				"Enabled"
			} do
				if not (clouds:GetAttribute(attributeName) ~= nil and clouds:GetAttribute(attributeName) ~= clouds2[attributeName]) then
					continue
				end

				local cloud = clouds2[attributeName]
				clouds2[attributeName] = clouds:GetAttribute(attributeName)
				local v4 = attributeName
				maid:Add(function()
					clouds2[v4] = cloud
				end)
			end
		end

		if lighting:GetAttribute("ExposureCompensation") then
			Lighting.ExposureCompensation = lighting:GetAttribute("ExposureCompensation")
			maid:Add(function()
				Lighting.ExposureCompensation = 0
			end)
		end
	end

	local function EmitEffect(folder)
		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end
	end

	local clone = maid:Clone(script.Assets)
	clone:PivotTo(extra.FloorPosition)
	clone.Parent = workspace.Runtime
	local cams = clone.Cams
	local camPart = clone.CamPart
	local clone2 = maid:Clone(script.WinterMap)
	clone2:PivotTo(extra.FloorPosition)
	clone2.Parent = workspace.Runtime
	local clone3 = maid:Clone(script.NewYearMap)
	clone3:PivotTo(cframe)
	clone3.Parent = workspace.Runtime

	if data.CutsceneLoaded then
		data.CutsceneLoaded(true)
	end

	for _, child in cams:GetChildren() do
		child.Transparency = 1
	end

	for _, part in clone3.Vanity.HappyNewYear:GetChildren() do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end

	for _, child in clone3.Vanity.VFX.Fireworks:GetChildren() do
		child.Enabled = false
	end

	UpdateLighting(clone2:FindFirstChild("Lighting"))
	local cutsceneAssetUI = script.CutsceneAssetUI
	cutsceneAssetUI.Parent = playerGui
	maid:Add(function()
		Debris:AddItem(cutsceneAssetUI, 2)
	end)
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Parent = currentCamera
	maid:Add(colorCorrectionEffect)
	local bloomEffect = Instance.new("BloomEffect")
	bloomEffect.Intensity = 1
	bloomEffect.Size = 56
	bloomEffect.Threshold = 0.5
	bloomEffect.Parent = currentCamera
	maid:Add(bloomEffect)
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = 10
	blurEffect.Parent = currentCamera
	maid:Add(blurEffect)
	currentCamera.FieldOfView = 70
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.CFrame = cams.Cam1A.CFrame
	maid:Add(currentCamera.Changed:Connect(function()
		if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
			currentCamera.CameraType = Enum.CameraType.Scriptable
		end
	end))
	maid:Add(function()
		currentCamera.CameraType = Enum.CameraType.Custom
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

		if humanoid then
			currentCamera.CameraSubject = humanoid
		end
	end)
	local fastTween = v3.fastTween(camPart, TweenInfo.new(8, Enum.EasingStyle.Sine), {
		CFrame = cams.Cam1B.CFrame
	})
	v3.fastTween(bloomEffect, TweenInfo.new(10, Enum.EasingStyle.Linear), {
		Intensity = 1,
		Threshold = 4
	})
	v3.fastTween(blurEffect, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		Size = 0
	})
	local v4 = maid:Add(v.new(Enum.RenderPriority.Last.Value + 1, function(p)
		currentCamera.CFrame = camPart.CFrame * p
	end), "Stop")
	v4:Start()
	local v5 = nil
	task.delay(3, function()
		v5 = v4:ShakeSustain(v.Presets.RoughDriving)
		task.delay(6, function()
			v5:StartFadeOut(0.9)
		end)
	end)
	task.wait(4)
	EmitEffect(clone2.Vanity.Land)
	task.wait(2)
	fastTween:Cancel()
	clone2.Vanity.SnowStorm.SnowFlakes.Enabled = true
	camPart.CFrame = cams.Cam2A.CFrame
	v3.fastTween(camPart, TweenInfo.new(10, Enum.EasingStyle.Sine), {
		CFrame = cams.Cam2B.CFrame
	})
	currentCamera.FieldOfView = 65
	v3.fastTween(currentCamera, TweenInfo.new(10, Enum.EasingStyle.Sine), {
		FieldOfView = 60
	})

	if v5 then
		v5:StartFadeOut(0)
	end

	local cameraShakeInstance = v.CameraShakeInstance.new(3, 10, 10, 0)
	cameraShakeInstance.PositionInfluence = createVector(0.75, 0.75, 0.75)
	cameraShakeInstance.RotationInfluence = createVector(3, 1.25, 1.25)
	v4:ShakeSustain(cameraShakeInstance)
	task.delay(0.5, function()
		for _, child in clone2.Vanity.SnowFlakes:GetChildren() do
			v3.fastTween(child, TweenInfo.new(2, Enum.EasingStyle.Sine), {
				TimeScale = 0
			})
		end
	end)
	v3.fastTween(clone2.Vanity.SnowStorm.SnowFlakes, TweenInfo.new(15, Enum.EasingStyle.Quart), {
		LightEmission = 0.4
	})
	task.wait(8)
	EmitEffect(clone2.Vanity.Land2)
	cameraShakeInstance:StartFadeOut(0)
	local cameraShakeInstance2 = v.CameraShakeInstance.new(4, 10, 0, 2)
	cameraShakeInstance2.PositionInfluence = createVector(1, 1, 1)
	cameraShakeInstance2.RotationInfluence = createVector(4, 1.25, 1.25)
	v4:Shake(cameraShakeInstance2)
	v3.fastTween(cutsceneAssetUI.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		BackgroundTransparency = 0
	})
	v3.fastTween(cutsceneAssetUI.Frame, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	})
	task.wait(WAIT_INTERVAL)
	clone3:PivotTo(extra.FloorPosition)
	clone2:PivotTo(cframe)
	UpdateLighting(clone3:FindFirstChild("Lighting"))
	task.wait(WAIT_INTERVAL)
	v4:ShakeSustain(v.Presets.RoughDriving)
	v3.fastTween(cutsceneAssetUI.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		BackgroundTransparency = 1
	})
	bloomEffect.Intensity = 1
	bloomEffect.Threshold = 0.4
	blurEffect.Size = 10
	colorCorrectionEffect.Brightness = 2
	v3.fastTween(bloomEffect, TweenInfo.new(10, Enum.EasingStyle.Linear), {
		Intensity = 1,
		Threshold = 4
	})
	v3.fastTween(blurEffect, TweenInfo.new(2, Enum.EasingStyle.Linear), {
		Size = 0
	})
	v3.fastTween(colorCorrectionEffect, TweenInfo.new(2, Enum.EasingStyle.Sine), {
		Brightness = 0
	})
	camPart.CFrame = cams.Cam3A.CFrame
	local fastTween2 = v3.fastTween(camPart, TweenInfo.new(6, Enum.EasingStyle.Back), {
		CFrame = cams.Cam3B.CFrame
	})
	v3.fastTween(colorCorrectionEffect, TweenInfo.new(3, Enum.EasingStyle.Sine), {
		Brightness = -0.3,
		Contrast = 0.6
	})
	task.wait(1.7)
	EmitEffect(clone.VFX.PreFireworks)
	task.wait(1.3)
	fastTween2:Cancel()
	colorCorrectionEffect.Brightness = 0
	colorCorrectionEffect.Contrast = 0
	camPart.CFrame = cams.Cam4A.CFrame
	v3.fastTween(camPart, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = cams.Cam4B.CFrame
	})
	bloomEffect.Intensity = 1
	bloomEffect.Threshold = 0.6
	blurEffect.Size = 20
	colorCorrectionEffect.Brightness = 1
	v3.fastTween(bloomEffect, TweenInfo.new(4, Enum.EasingStyle.Linear), {
		Intensity = 0,
		Threshold = 4
	})
	v3.fastTween(blurEffect, TweenInfo.new(1.5, Enum.EasingStyle.Back), {
		Size = 0
	})
	v3.fastTween(colorCorrectionEffect, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
		Brightness = 0
	})
	task.wait(0.2)

	for i = 10, 1, -1 do
		local child = clone.VFX.CooldownSequence.NumbersDown:FindFirstChild("Num" .. i)

		if child then
			EmitEffect(child)

			if i == 4 then
				v3.fastTween(
					currentCamera,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
					{
						FieldOfView = 59
					}
				)
				local cameraShakeInstance3 = v.CameraShakeInstance.new(1, 10, 0, 1)
				cameraShakeInstance3.PositionInfluence = createVector(0.25, 0.25, 0.25)
				cameraShakeInstance3.RotationInfluence = createVector(0.75, 1, 1)
				v4:Shake(cameraShakeInstance3)
			elseif i == 3 then
				v3.fastTween(
					currentCamera,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
					{
						FieldOfView = 57
					}
				)
				local cameraShakeInstance3 = v.CameraShakeInstance.new(3, 10, 0, 1)
				cameraShakeInstance3.PositionInfluence = createVector(0.25, 0.25, 0.25)
				cameraShakeInstance3.RotationInfluence = createVector(1, 1, 1)
				v4:Shake(cameraShakeInstance3)
			elseif i == 2 then
				v3.fastTween(
					currentCamera,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
					{
						FieldOfView = 54
					}
				)
				local cameraShakeInstance3 = v.CameraShakeInstance.new(3, 10, 0, 1)
				cameraShakeInstance3.PositionInfluence = createVector(0.25, 0.25, 0.25)
				cameraShakeInstance3.RotationInfluence = createVector(1.5, 1, 1)
				v4:Shake(cameraShakeInstance3)
			elseif i == 1 then
				v3.fastTween(
					currentCamera,
					TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
					{
						FieldOfView = 50
					}
				)
				local cameraShakeInstance3 = v.CameraShakeInstance.new(3, 10, 0, 1)
				cameraShakeInstance3.PositionInfluence = createVector(0.25, 0.25, 0.25)
				cameraShakeInstance3.RotationInfluence = createVector(2, 1, 1)
				v4:Shake(cameraShakeInstance3)
			end
		end

		task.wait(1)
	end

	EmitEffect(clone.VFX.CooldownSequence.FinalExplosion)
	EmitEffect(clone.VFX.Fireworks)

	for _, child in clone3.Vanity.VFX.Fireworks:GetChildren() do
		child.Enabled = true
	end

	v3.fastTween(currentCamera, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
		FieldOfView = 40
	})
	local cameraShakeInstance3 = v.CameraShakeInstance.new(3, 10, 0, 1)
	cameraShakeInstance3.PositionInfluence = createVector(0.25, 0.25, 0.25)
	cameraShakeInstance3.RotationInfluence = createVector(4, 1, 1)
	v4:Shake(cameraShakeInstance3)
	task.wait(0.3)
	v3.fastTween(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
		FieldOfView = 50
	})
	task.wait(WAIT_INTERVAL)
	v3.fastTween(currentCamera, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		FieldOfView = 65
	})
	task.wait(1.5)

	for _, part in clone3.Vanity.HappyNewYear:GetChildren() do
		if part:IsA("BasePart") then
			part.Transparency = 0
		end
	end

	clone.VFX.CooldownSequence.FinalExplosion:Destroy()

	for _, child in clone3.Vanity.VFX.Top:GetChildren() do
		child.Enabled = true
	end

	for _, child in clone3.Vanity.HappyNewYear.Attachment:GetChildren() do
		child.Enabled = true
	end

	camPart.CFrame = cams.Cam5A.CFrame
	v3.fastTween(camPart, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = cams.Cam5B.CFrame
	})
	blurEffect.Size = 20
	v3.fastTween(blurEffect, TweenInfo.new(2, Enum.EasingStyle.Back), {
		Size = 0
	})
	task.wait(4)
	cutsceneAssetUI.Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	cutsceneAssetUI.Frame.BackgroundTransparency = 1
	v3.fastTween(cutsceneAssetUI.Frame, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		BackgroundTransparency = 0
	})
	task.wait(1.5)
	v3.fastTween(cutsceneAssetUI.Frame, TweenInfo.new(1, Enum.EasingStyle.Sine), {
		BackgroundTransparency = 1
	})
	maid:Clean()
	task.defer(function()
		ReplicatedStorage2.Remotes.ResetFOV:Fire()
	end)

	if data.CutsceneFinished then
		data.CutsceneFinished()
	end
end