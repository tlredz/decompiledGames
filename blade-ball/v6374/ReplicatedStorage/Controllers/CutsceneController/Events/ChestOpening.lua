local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Lighting = game:GetService("Lighting")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Shared.CutsceneUtil)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Shared.FastUtils)
local v5 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local play = require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
local updateCrateVFX = ReplicatedStorage2.Misc.UpdateCrateVFX
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local shared = script:FindFirstAncestorWhichIsA("ModuleScript").Shared
local cframe = CFrame.new(0, 1e20, 0)
local _ = {
	Tier1 = "rbxassetid://83780768962644",
	Tier2 = "rbxassetid://134858975779767",
	Tier3 = "rbxassetid://80562863480820",
	Tier4 = "rbxassetid://139424675945983",
	Tier5 = "rbxassetid://138605065274280"
}
return function(data)
	if data.CutsceneStarted then
		data.CutsceneStarted()
	end

	local extra = data.Extra or {}
	local maid = v.new()
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Parent = currentCamera
	local clone = maid:Clone(shared.R15Camera)
	clone:PivotTo(cframe)
	clone.Parent = workspace.Runtime
	local clone2 = maid:Clone(shared.ChestOpening.Player)
	clone2:PivotTo(cframe)
	clone2.Parent = workspace.Runtime
	local clone3 = maid:Clone(shared.ChestOpening.Chest)
	clone3:PivotTo(cframe)
	clone3.Parent = workspace.Runtime
	local clone4 = maid:Clone(shared.ChestOpening.Ball)
	clone4:PivotTo(cframe)
	clone4.Parent = workspace.Runtime
	local clone5 = maid:Clone(shared.ChestOpening.TierDisplay)
	clone5:PivotTo(cframe)
	clone5.Parent = workspace.Runtime
	local colorCorrectionEffect2 = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect2.Parent = currentCamera
	maid:Add(colorCorrectionEffect2)
	local colorCorrectionEffect3 = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect3.Parent = currentCamera
	maid:Add(colorCorrectionEffect3)
	task.spawn(pcall, function()
		clone2.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId))
	end)
	v5:EquipSwordTo(clone2, localPlayer:GetAttribute("CurrentlyEquippedSword"))
	local v7 = {
		[clone.Humanoid.Animator] = script.Camera,
		[clone2.Humanoid.Animator] = script.Character,
		[clone3.AnimationController.Animator] = script.Chest,
		[clone4.AnimationController.Animator] = script.Ball
	}
	local preloadAnimations = v2.preloadAnimations(v7)
	local preloadSounds = v2.preloadSounds({
		Sound = script.Sound,
		SwordSlash = script.SwordSlash,
		Star1 = script.Star1,
		Star2 = script.Star2,
		Star3 = script.Star3,
		Star4 = script.Star4,
		Star5 = script.Star5
	})
	local v8 = false
	preloadAnimations[clone.Humanoid.Animator]:GetMarkerReachedSignal("Fade"):Once(function()
		v8 = true
		v4.fastTween(colorCorrectionEffect, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			TintColor = Color3.new(0, 0, 0)
		})
	end)

	if data.CutsceneLoaded then
		data.CutsceneLoaded()
	end

	data.Map.Parent = workspace
	maid:Add(function()
		data.Map.Parent = nil
	end)
	local cutscene = data.Map:WaitForChild("Cutscene")
	clone:PivotTo(cutscene.Camera:GetPivot())
	clone2:PivotTo(cutscene.Character:GetPivot())
	clone4:PivotTo(cutscene.Ball:GetPivot())
	clone3:PivotTo(cutscene.Chest:GetPivot())
	clone5:PivotTo(cutscene.Chest:GetPivot())
	clone5.Base.SurfaceGui.Enabled = false
	local reward = extra and extra.Reward

	if reward then
		clone5.Base.SurfaceGui.Card.Title.TextLabel.Text = reward.DisplayName
		clone5.Base.SurfaceGui.Card.Vector.Image = reward.Icon
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
	end)
	maid:Add(RunService.PreRender:Connect(function(_: number)
		currentCamera.CFrame = clone.CutsceneCameraPart.CFrame
	end))
	local thread = coroutine.running()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resume()
		v3.Thread.SafeResume(thread)
	end

	local thread2

	if data.PredictedTimeout then
		thread2 = task.delay(data.PredictedTimeout - workspace:GetServerTimeNow(), resume)
	end

	local v9 = {
		VFX = updateCrateVFX.VFX1,
		Emote = script.Character,
		Play = play
	}
	local folder = Instance.new("Folder")
	maid:Add(folder)
	folder.Name = "EmoteVFX_Storage"
	folder.Parent = cutscene
	local v10 = v9.Play(v9, cutscene, true)

	if v10 then
		maid:Add(v10)
	end

	maid:Add(function()
		v9.Play(v9, cutscene, false)
	end)
	local v11 = {
		VFX = updateCrateVFX.ChestVFX,
		Emote = script.Chest,
		Play = play
	}
	local folder2 = Instance.new("Folder")
	maid:Add(folder2)
	folder2.Name = "EmoteVFX_Storage"
	folder2.Parent = clone3
	local v12 = v11.Play(v11, clone3, true)

	if v12 then
		maid:Add(v12)
	end

	maid:Add(function()
		v11.Play(v11, clone3, false)
	end)

	if extra and (extra.Tier or 0) < 5 then
		for i = extra.Tier + 1, 5 do
			local folder3 = folder2:FindFirstChild(`6. Chest Star{i} (Enable)`, true)

			if not folder3 then
				continue
			end

			for _, descendant in folder3:GetDescendants() do
				if descendant:IsA("ParticleEmitter") then
					descendant.Rate = 0
				elseif descendant:IsA("Sound") then
					descendant.Volume = 0
				end
			end
		end
	end

	local v13 = {
		VFX = updateCrateVFX.BallVFX,
		Emote = script.Chest,
		Play = play
	}
	local folder3 = Instance.new("Folder")
	maid:Add(folder3)
	folder3.Name = "EmoteVFX_Storage"
	folder3.Parent = clone4
	local v14 = v13.Play(v13, clone4, true)

	if v14 then
		maid:Add(v14)
	end

	maid:Add(function()
		v13.Play(v13, clone4, false)
	end)
	local v15 = {
		VFX = updateCrateVFX.CamVFX,
		Emote = script.Camera,
		Play = play
	}
	local folder4 = Instance.new("Folder")
	maid:Add(folder4)
	folder4.Name = "EmoteVFX_Storage"
	folder4.Parent = clone
	local v16 = v15.Play(v15, clone, true)

	if v16 then
		maid:Add(v16)
	end

	maid:Add(function()
		v15.Play(v15, clone, false)
	end)
	task.delay(0.5, function()
		v4.fastTween(colorCorrectionEffect2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = 1,
			Contrast = -1
		})
		task.wait(0.5)
		v4.fastTween(colorCorrectionEffect2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Contrast = 0
		})
	end)
	task.delay(4.8, function()
		v4.fastTween(colorCorrectionEffect2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = 1,
			Contrast = -1
		})
		task.wait(0.5)
		v4.fastTween(colorCorrectionEffect2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Contrast = 0
		})
	end)
	task.delay(11.75, function()
		v4.fastTween(colorCorrectionEffect2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = 1,
			Contrast = -1
		})
	end)
	task.delay(2.9, function()
		v4.fastTween(colorCorrectionEffect2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = -2,
			Contrast = 5,
			Saturation = -1
		})
		task.wait(0.5)
		preloadSounds.SwordSlash:Play()
		v4.fastTween(colorCorrectionEffect2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		})
	end)
	task.delay(7.25, function()
		v4.fastTween(colorCorrectionEffect2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = -2,
			Contrast = 5,
			Saturation = -1
		})
		task.wait(0.5)
		v4.fastTween(colorCorrectionEffect2, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		})
	end)
	task.delay(7.5, function()
		local clockTime = Lighting.ClockTime
		v4.fastTween(Lighting, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {
			ClockTime = 22
		})
		maid:Add(function()
			Lighting.ClockTime = clockTime
		end)
	end)
	task.delay(8, function()
		clone5.Base.SurfaceGui.Enabled = true
		v4.fastTween(clone5.Base, TweenInfo.new(1.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Position = clone5.Base.Position + createVector(0, 19.5, 0)
		})
		task.delay(0.25, function()
			if extra.Tier == 5 then
				preloadSounds.Star5:Play()
			elseif extra.Tier == 4 then
				preloadSounds.Star4:Play()
			elseif extra.Tier == 3 then
				preloadSounds.Star3:Play()
			elseif extra.Tier == 2 then
				preloadSounds.Star2:Play()
			else
				preloadSounds.Star1:Play()
			end
		end)
		maid:Connect(RunService.RenderStepped, function()
			local position = clone5.Base.Position
			clone5.Base.CFrame = CFrame.lookAt(position, currentCamera.CFrame.Position)
		end)
	end)
	local thread3 = task.spawn(function()
		preloadSounds.Sound:Play()
		v2.playAndWaitAnimations(preloadAnimations)
		resume() -- equivalent call inferred; original call site unknown
	end)
	coroutine.yield()
	print("FINISHED")
	v3.Thread.SafeCancel(thread3)

	if thread2 then
		v3.Thread.SafeCancel(thread2)
	end

	if colorCorrectionEffect.TintColor == Color3.new(0, 0, 0) then
		task.wait(0.45)
		v4.fastTween(colorCorrectionEffect, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			TintColor = Color3.new(1, 1, 1)
		}).Completed:Once(function()
			colorCorrectionEffect:Destroy()
		end)
	else
		colorCorrectionEffect:Destroy()
	end

	maid:Clean()
	task.defer(function()
		ReplicatedStorage2.Remotes.ResetFOV:Fire()
	end)

	if data.CutsceneFinished then
		data.CutsceneFinished()
	end
end