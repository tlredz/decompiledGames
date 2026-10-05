local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Debris = game:GetService("Debris")
game:GetService("Lighting")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("TextChatService")
game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.ClientGameModules.CameraShaker)
local v2 = require3(ReplicatedStorage2.Controllers.EncryptedAssetController)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Promise)
require3(ReplicatedStorage2.Shared.CutsceneUtil)
require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Shared.FastUtils)
require3(ReplicatedStorage2.Controllers.UI.DialogueController)
require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local _ = script:FindFirstAncestorWhichIsA("ModuleScript").Shared
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true
raycastParams.CollisionGroup = "Players"
raycastParams.RespectCanCollide = true

local function loadPlayersCharacter(clone)
	local v5 = #Players:GetPlayers()
	local pivot = clone:FindFirstChild("FLOOR"):GetPivot()
	local v6 = math.random() * 3.141592653589793 * 2
	local clones = {}

	for k, v7 in Players:GetPlayers() do
		local clone2 = ReplicatedStorage2.Assets.R6:Clone()
		local v9 = v7
		task.spawn(pcall, function()
			clone2.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(v9.UserId))
		end)
		local _ = v7.Character
		local v10 = k / v5 * 3.141592653589793 * 2 + v6
		local position = pivot * (Vector3.new(math.sin(v10), 0, (math.cos(v10))) * 72.5)
		local raycastResult = workspace:Raycast(
			position + createVector(0, 100, 0),
			createVector(0, -200, 0),
			raycastParams
		)

		if raycastResult then
			position = raycastResult.Position
		end

		clone2.HumanoidRootPart.Anchored = true
		clone2:PivotTo(CFrame.lookAt(position, (Vector3.new(pivot.Position.X, position.Y, pivot.Position.Z))) + createVector(
			0,
			4.5,
			0
		))
		clone2.Parent = clone.Players
		table.insert(clones, clone2)
	end

	return clones
end

task.defer(function()
	v2:RequestAsset("rbxassetid://86553108866816")
	ReplicatedStorage2.Music.Brazil_Map.SoundId = "rbxassetid://86553108866816"
end)
return function(data)
	if data.CutsceneStarted then
		data.CutsceneStarted()
	end

	if not ReplicatedStorage2.Music.Brazil_Map.IsLoaded then
		task.spawn(function()
			ContentProvider:PreloadAsync({ ReplicatedStorage2.Music.Brazil_Map })
		end)
	end

	local maid = v3.new()
	local extra = data.Extra or {}
	local startTime = extra.StartTime

	if extra.EndTime - startTime < 15 then
		if data.CutsceneFinished then
			data.CutsceneFinished()
		end
	else
		local clone = maid:Clone(ReplicatedStorage2.Assets.Events.AdminAbuse.BrazilEvent.Brazil_Map)
		clone:PivotTo(extra.FloorPosition + createVector(0, 1000, 0))
		local aura = clone.Aura
		local awokein = clone.Awokein
		local cameras = clone.Cameras
		local VFX = clone.VFX

		if data.CutsceneLoaded then
			data.CutsceneLoaded(true)
		end

		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Parent = currentCamera
		Debris:AddItem(colorCorrectionEffect, 15)
		local colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect2.Parent = currentCamera
		Debris:AddItem(colorCorrectionEffect, 15)
		v4.fastTween(colorCorrectionEffect, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			TintColor = Color3.fromRGB(0, 0, 0)
		})
		v4.fastTween(currentCamera, TweenInfo.new(0.95, Enum.EasingStyle.Sine), {
			FieldOfView = 85
		})
		task.wait(1)
		v4.fastTween(colorCorrectionEffect, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			TintColor = Color3.fromRGB(255, 255, 255)
		})
		clone.Parent = workspace.Runtime
		local v5 = loadPlayersCharacter(clone)

		for _, v6 in v5 do
			maid:Add(v6)
			local humanoid = v6:FindFirstChild("Humanoid")
			local animator = humanoid and humanoid:FindFirstChild("Animator")

			if not animator then
				continue
			end

			local track = animator:LoadAnimation(script.Animation)
			track.Looped = true
			track:Play()
		end

		currentCamera.CameraType = Enum.CameraType.Scriptable
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

			table.clear(v5)
		end)
		currentCamera.FieldOfView = 75
		v4.fastTween(currentCamera, TweenInfo.new(7.8, Enum.EasingStyle.Sine), {
			FieldOfView = 120
		})
		cameras.MainCam.CFrame = cameras.Cam1.CFrame
		v4.fastTween(cameras.MainCam, TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			CFrame = cameras.Cam2.CFrame
		})
		local v6 = maid:Add(v.new(Enum.RenderPriority.Last.Value + 1, function(p)
			currentCamera.CFrame = cameras.MainCam.CFrame * p
		end), "Stop")
		v6:Start()
		local shakeSustain = v6:ShakeSustain(v.Presets.RoughDriving)
		task.delay(6, function()
			shakeSustain:StartFadeOut(0.9)
		end)
		v4.fastTween(aura.PrimaryPart, TweenInfo.new(7.9, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
			CFrame = aura.PrimaryPart.CFrame - createVector(0, 300, 0)
		})
		task.wait(7.9)
		colorCorrectionEffect2.Brightness = -1
		colorCorrectionEffect2.Contrast = 5
		colorCorrectionEffect2.Saturation = 1.2

		if shakeSustain then
			maid:Remove(shakeSustain)
		end

		shakeSustain = maid:Add(v.new(Enum.RenderPriority.Last.Value + 1, function(p)
			currentCamera.CFrame = cameras.MainCam.CFrame * p
		end), "Stop")
		local explosion = v.Presets.Explosion
		shakeSustain = shakeSustain:Shake(explosion)
		currentCamera.FieldOfView = 95
		v4.fastTween(currentCamera, TweenInfo.new(2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			FieldOfView = 85
		})

		for _, emitter in aura.PrimaryPart:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		awokein:PivotTo(awokein:GetPivot() * CFrame.new(0, 100, 0))
		task.wait(0.1)
		task.defer(function()
			if not workspace.Map:FindFirstChild("Brazil_Map") then
				return
			end

			ReplicatedStorage2.Music.Brazil_Map:Play()
		end)
		v4.fastTween(cameras.MainCam, TweenInfo.new(2, Enum.EasingStyle.Back), {
			CFrame = cameras.Cam3.CFrame
		})
		v4.fastTween(colorCorrectionEffect, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Brightness = 2
		})
		task.delay(0.1, function()
			colorCorrectionEffect2.Brightness = 0
			colorCorrectionEffect2.Contrast = 0
			colorCorrectionEffect2.Saturation = 0
			task.wait(0.45)
			v4.fastTween(colorCorrectionEffect, TweenInfo.new(0.75, Enum.EasingStyle.Sine), {
				Brightness = 0
			})
		end)
		task.wait(0.25)

		for _, effect in VFX:GetDescendants() do
			if effect:IsA("ParticleEmitter") or effect:IsA("Beam") then
				effect.Enabled = true
			elseif effect.Name == "NeonPart" then
				effect.Transparency = 0
			end
		end

		VFX.Discoball.PrimaryPart.Script.Enabled = true
		task.wait(0.25)

		if shakeSustain then
			maid:Remove(shakeSustain)
		end

		shakeSustain = maid:Add(v.new(Enum.RenderPriority.Last.Value + 1, function(p)
			currentCamera.CFrame = cameras.MainCam.CFrame * p
		end), "Stop")
		shakeSustain:Start()
		local earthquake2 = v.Presets.Earthquake2
		shakeSustain = shakeSustain:ShakeSustain(earthquake2)
		task.wait(3)
		shakeSustain:StartFadeOut(1.5)
		task.wait(1)
		v4.fastTween(colorCorrectionEffect, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Brightness = 2
		})
		task.wait(0.5)
		v4.fastTween(colorCorrectionEffect, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			Brightness = 0
		})
		maid:Clean()
		task.defer(function()
			ReplicatedStorage2.Remotes.ResetFOV:Fire()
		end)

		if data.CutsceneFinished then
			data.CutsceneFinished()
		end
	end
end