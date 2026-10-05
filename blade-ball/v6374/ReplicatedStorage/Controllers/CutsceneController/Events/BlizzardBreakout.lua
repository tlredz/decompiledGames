local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Debris = game:GetService("Debris")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Packages.Promise)
local v3 = require3(ReplicatedStorage2.Shared.CutsceneUtil)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local v5 = require3(ReplicatedStorage2.Shared.FastUtils)
require3(ReplicatedStorage2.Controllers.UI.DialogueController)
local play = require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local blizzardBreakoutVFX = ReplicatedStorage2.Misc.BlizzardBreakoutVFX
local shared = script:FindFirstAncestorWhichIsA("ModuleScript").Shared
local cframe = CFrame.new(0, 1e20, 0)
return function(data)
	if data.CutsceneStarted then
		data.CutsceneStarted()
	end

	local maid = v.new()
	local clone = maid:Clone(script.CamCharacter)
	clone:PivotTo(cframe)
	clone.Parent = workspace.Runtime
	local clone2 = maid:Clone(shared.SnowmanBoss)
	clone2:PivotTo(cframe)
	clone2.Parent = workspace.Runtime
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Parent = currentCamera
	maid:Add(function()
		Debris:AddItem(colorCorrectionEffect, 2)
	end)
	local v8 = v3.preloadAnimations({
		[clone2.Humanoid.Animator] = script.Boss,
		[clone.AnimationController.Animator] = script.Camera
	})
	local preloadSounds = v3.preloadSounds({
		Sound = script.Sound
	})

	if data.CutsceneLoaded then
		data.CutsceneLoaded()
	end

	local FLOOR = data.Map.FLOOR
	clone:PivotTo(FLOOR:GetPivot())
	clone2:PivotTo(FLOOR:GetPivot())
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
	local v9 = {}

	for _, child in script.FieldOfViewValues:GetChildren() do
		v9[tonumber(child.Name)] = child.Value
	end

	local v10 = 0

	for k, _ in pairs(v9) do
		if v10 < k then
			v10 = k
		end
	end

	local v11 = 0
	local v12 = 0
	maid:Add(RunService.PreRender:Connect(function(dt: number)
		currentCamera.CFrame = clone.CamPart.CFrame
		v12 += dt

		while v12 >= 0.016666666666666666 do
			v12 -= 0.016666666666666666
			v11 += 1
			local fieldOfView = v9[v11]

			if fieldOfView then
				currentCamera.FieldOfView = fieldOfView
			end

			if v10 <= v11 then
				v11 = v10
			end
		end
	end))
	local thread = coroutine.running()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resume()
		v4.Thread.SafeResume(thread)
	end

	local thread2

	if data.PredictedTimeout then
		thread2 = task.delay(data.PredictedTimeout - workspace:GetServerTimeNow(), resume)
	end

	local v13 = {
		VFX = blizzardBreakoutVFX.Floor,
		Emote = script.Camera,
		Play = play
	}
	local folder = Instance.new("Folder")
	maid:Add(folder)
	folder.Name = "EmoteVFX_Storage"
	folder.Parent = data.Map
	local v14 = v13.Play(v13, data.Map, true)

	if v14 then
		maid:Add(v14)
	end

	maid:Add(function()
		v13.Play(v13, data.Map, false)
	end)
	local v15 = {
		VFX = blizzardBreakoutVFX.Outfit,
		Emote = script.Camera,
		Play = play
	}
	local folder2 = Instance.new("Folder")
	maid:Add(folder2)
	folder2.Name = "EmoteVFX_Storage"
	folder2.Parent = clone2.Outfit
	local v16 = v15.Play(v15, clone2.Outfit, true)

	if v16 then
		maid:Add(v16)
	end

	maid:Add(function()
		if clone2 and clone2:FindFirstChild("Outfit") then
			v15.Play(v15, clone2.Outfit, false)
		end
	end)
	local v17 = {
		VFX = blizzardBreakoutVFX.Camera,
		Emote = script.Camera,
		Play = play
	}
	local folder3 = Instance.new("Folder")
	maid:Add(folder3)
	folder3.Name = "EmoteVFX_Storage"
	folder3.Parent = clone
	local v18 = v17.Play(v17, clone, true)

	if v18 then
		maid:Add(v18)
	end

	maid:Add(function()
		v17.Play(v17, clone, false)
	end)
	task.delay(0.5, function()
		v5.fastTween(colorCorrectionEffect, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = 1,
			Contrast = -1
		})
		task.wait(0.5)
		v5.fastTween(colorCorrectionEffect, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Contrast = 0
		})
	end)
	maid:AddPromise(v2.delay(13.5):andThen(function()
		v5.fastTween(colorCorrectionEffect, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = 1,
			Contrast = -1
		})
		task.wait(1)
		v5.fastTween(colorCorrectionEffect, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			Brightness = 0,
			Contrast = 0
		})
	end))
	local thread3 = task.spawn(function()
		preloadSounds.Sound:Play()
		v3.playAndWaitAnimations(v8)
		resume() -- equivalent call inferred; original call site unknown
	end)
	coroutine.yield()
	v4.Thread.SafeCancel(thread3)

	if thread2 then
		v4.Thread.SafeCancel(thread2)
	end

	maid:Clean()
	task.defer(function()
		ReplicatedStorage2.Remotes.ResetFOV:Fire()
	end)

	if data.CutsceneFinished then
		data.CutsceneFinished()
	end
end