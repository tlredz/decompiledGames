local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.Shared.CutsceneUtil)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Shared.FastUtils)
require3(ReplicatedStorage2.Controllers.UI.DialogueController)
require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local shared = script:FindFirstAncestorWhichIsA("ModuleScript").Shared
local cframe = CFrame.new(0, 1e20, 0)
return function(data)
	if data.CutsceneStarted then
		data.CutsceneStarted()
	end

	local maid = v.new()
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Parent = currentCamera
	local clone = maid:Clone(shared.R15Camera)
	clone:PivotTo(cframe)
	clone.Parent = workspace.Runtime
	local clone2 = maid:Clone(shared.Character)
	clone2:PivotTo(cframe)
	clone2.Parent = workspace.Runtime
	task.spawn(pcall, function()
		clone2.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId))
	end)
	local v5 = {
		[clone.Humanoid.Animator] = script.Camera,
		[clone2.Humanoid.Animator] = script.Character
	}
	local clones = {}

	for i = 1, 5 do
		local clone3 = maid:Clone(shared.Drone)
		clone3:PivotTo(cframe)
		clone3.Parent = workspace.Runtime
		v5[clone3.AnimationController.Animator] = script[`Drone{i}`]
		table.insert(clones, clone3)
	end

	local preloadAnimations = v2.preloadAnimations(v5)
	local preloadSounds = v2.preloadSounds({
		Sound = script.Sound
	})
	local v6 = false
	preloadAnimations[clone.Humanoid.Animator]:GetMarkerReachedSignal("Fade"):Once(function()
		v6 = true
		v4.fastTween(colorCorrectionEffect, TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
			TintColor = Color3.new(0, 0, 0)
		})
	end)

	if data.CutsceneLoaded then
		data.CutsceneLoaded()
	end

	clone:PivotTo(data.Map.Cutscene.Camera:GetPivot())
	clone2:PivotTo(data.Map.Cutscene.Character:GetPivot())

	for _, v7 in clones do
		v7:PivotTo(data.Map.Cutscene.ObjectCenter:GetPivot())
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
		currentCamera.FieldOfView = 70
	end)

	if data.CutsceneFinished then
		data.CutsceneFinished()
	end
end