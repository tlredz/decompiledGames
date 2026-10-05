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
require3(ReplicatedStorage2.Packages.Promise)
local v2 = require3(ReplicatedStorage2.Shared.CutsceneUtil)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Shared.FastUtils)
require3(ReplicatedStorage2.Controllers.UI.DialogueController)
require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
local v5 = require3(script.GoldenSkiesEffects)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local _ = script:FindFirstAncestorWhichIsA("ModuleScript").Shared
local cframe = CFrame.new(0, 1e20, 0)
return function(data)
	if data.CutsceneStarted then
		data.CutsceneStarted()
	end

	local maid = v.new()
	local extra = data.Extra or {}
	local startTime = extra.StartTime
	local v6 = extra.EndTime - startTime
	local preloadSounds = v2.preloadSounds({
		Sound = script.Sound
	})
	local clone = maid:Clone(ReplicatedStorage2.Assets.Events.AdminAbuse.CutsceneInstances)
	clone:PivotTo(cframe)
	clone.Parent = workspace.Runtime
	local camera = clone.Camera
	local awokein = clone.Awokein
	local v7 = {
		[camera.Humanoid.Animator] = script.Camera,
		[awokein.Humanoid.Animator] = script.Awokein
	}
	local preloadAnimations = v2.preloadAnimations(v7)

	for _, preloadAnimation in preloadAnimations do
		preloadAnimation.Looped = false
	end

	if data.CutsceneLoaded then
		data.CutsceneLoaded(true)
	end

	clone:PivotTo(extra.FloorPosition)
	currentCamera.CameraType = Enum.CameraType.Scriptable
	maid:Add(currentCamera.Changed:Connect(function()
		if currentCamera.CameraType ~= Enum.CameraType.Scriptable then
			currentCamera.CameraType = Enum.CameraType.Scriptable
		end
	end))
	maid:Add(RunService.PreRender:Connect(function(_: number)
		currentCamera.CFrame = camera.CutsceneCameraPart.CFrame
	end))
	maid:Add(function()
		currentCamera.CameraType = Enum.CameraType.Custom
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")

		if humanoid then
			currentCamera.CameraSubject = humanoid
		end
	end)

	if v6 > 25 then
		preloadAnimations[awokein.Humanoid.Animator]:GetMarkerReachedSignal("HammerHit"):Once(function()
			maid:Add(v4.fastTween(currentCamera, TweenInfo.new(8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				FieldOfView = 60
			}))
			v5.execute(awokein.HumanoidRootPart, extra.FloorPosition)
		end)
		task.delay(v6, function()
			v5.stop()
		end)
	end

	local thread = coroutine.running()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function resume()
		v3.Thread.SafeResume(thread)
	end

	local thread2

	if data.PredictedTimeout then
		thread2 = task.delay(data.PredictedTimeout - workspace:GetServerTimeNow(), resume)
	end

	local thread3 = task.spawn(function()
		preloadSounds.Sound:Play()
		v2.playAndWaitAnimations(preloadAnimations)
		resume() -- equivalent call inferred; original call site unknown
	end)
	coroutine.yield()
	v3.Thread.SafeCancel(thread3)

	if thread2 then
		v3.Thread.SafeCancel(thread2)
	end

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	v4.fastTween(Lighting.ColorCorrection, tweenInfo, {
		Brightness = 1
	})
	v4.fastTween(Lighting.Bloom, tweenInfo, {
		Intensity = 1,
		Size = 50
	})
	v4.fastTween(currentCamera, tweenInfo, {
		FieldOfView = 70
	})
	task.wait(tweenInfo.Time)
	maid:Clean()
	v4.fastTween(Lighting.ColorCorrection, tweenInfo, {
		Brightness = 0
	})
	v4.fastTween(Lighting.Bloom, tweenInfo, {
		Intensity = 0.3,
		Size = 5
	})
	task.defer(function()
		ReplicatedStorage2.Remotes.ResetFOV:Fire()
	end)

	if data.CutsceneFinished then
		data.CutsceneFinished()
	end
end