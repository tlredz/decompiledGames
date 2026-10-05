local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("SoundService")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("Debris")
local v = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Controllers.UI.SpectateController)
local v4 = require3(ReplicatedStorage2.Shared.FastUtils)
require3(ReplicatedStorage2.Shared.ReplicatedInstances.Finishers)
local _ = ReplicatedStorage2.Remotes
local dualGalaxyNunchucks = ReplicatedStorage2.Misc.DataFinishers["Dual Galaxy Nunchucks"]
local currentCamera = workspace.CurrentCamera
return function(parent, instance, cFrame: CFrame, p: number)
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart2) then
		return
	end

	local maid = v.new()
	local localPlayer = Players.LocalPlayer
	local v5 = parent == localPlayer.Character or not Players:GetPlayerFromCharacter(parent)
	local v6 = instance == localPlayer.Character or not Players:GetPlayerFromCharacter(instance)
	local v7 = v5 and v6
	local currentlySpectating = v3:GetCurrentlySpectating()
	local v8

	if currentlySpectating == nil then
		v8 = false
	else
		v8 = currentlySpectating.Character and (currentlySpectating.Character == parent or currentlySpectating.Character == instance)
	end

	local v9

	if v7 then
		v9 = 0
	else
		v9 = p - workspace:GetServerTimeNow()
		maid:Add(task.delay((dualGalaxyNunchucks:GetAttribute("Duration") or 0) + v9 + 0.1, function()
			maid:Clean()
		end))
	end

	local clone = maid:Clone(script.sfx)
	clone.Volume = 0
	clone.Parent = localPlayer.PlayerGui

	if v5 or v6 or v8 then
		local clone2 = maid:Clone(ReplicatedStorage2.Misc.FinisherCameraRig)
		clone2.HumanoidRootPart.CFrame = cFrame
		clone2.Parent = workspace.Runtime
		maid:AttachToInstance(clone2)
		local track = clone2.Humanoid.Animator:LoadAnimation(script.Animations.Camera)
		local tracks = {}
		local thread

		if not (v8 and not v7) then
			if v5 then
				table.insert(tracks, parent.Humanoid.Animator:LoadAnimation(script.Animations.Player1))
			end

			if v6 then
				table.insert(tracks, instance.Humanoid.Animator:LoadAnimation(script.Animations.Player2))
			end

			thread = task.spawn(function()
				for _, v10 in tracks do
					v10:Play(0)
				end

				while true do
					local flag = false

					for _, v11 in tracks do
						if v11.Length ~= 0 then
							continue
						end

						flag = true
						break
					end

					if flag then
						task.wait()
					else
						for _, v11 in tracks do
							v11:Stop(0)
						end

						break
					end
				end
			end)
		end

		local thread2 = task.spawn(function()
			track:Play(0)

			while track.Length == 0 do
				task.wait()
			end

			track:Stop(0)
		end)
		local thread3 = task.spawn(function()
			clone:Play()

			while not clone.IsLoaded do
				task.wait()
			end

			clone:Stop()
		end)

		if v7 then
			while coroutine.status(thread) ~= "dead" and coroutine.status(thread2) ~= "dead" do
				task.wait()
			end
		elseif v9 > 0 then
			task.wait(v9)
		end

		v2.Thread.SafeCancel(thread3)
		clone.TimePosition = 0
		v2.Thread.SafeCancel(thread2)

		if thread then
			v2.Thread.SafeCancel(thread)
		end

		if not (parent.Parent and instance.Parent) then
			maid:Clean()
			return
		end

		if v8 then
			workspace:SetAttribute("DisableSpectateFinisher", os.clock() + 60)
			maid:Add(function()
				workspace:SetAttribute("DisableSpectateFinisher", nil)
			end)
			v3:Leave()
			v3:SetVisibility(false)
		end

		maid:Add(RunService.PostSimulation:Connect(function()
			humanoidRootPart:PivotTo(cFrame)
			humanoidRootPart2:PivotTo(cFrame)
		end))
		clone.Volume = script.sfx.Volume
		clone:Play()
		track:Play(0)

		for _, v10 in tracks do
			v10:Play(0)
		end

		maid:Add(function()
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") or currentCamera.CameraSubject
			task.defer(function()
				ReplicatedStorage2.Remotes.ResetFOV:Fire()
			end)
		end)
		maid:Add(function()
			track:Stop()
			track:Destroy()

			for _, v10 in tracks do
				v10:Stop()
				v10:Destroy()
			end
		end)
		currentCamera.FieldOfView = 45
		maid:Add(task.delay(0.5, function()
			maid:Add(v4.fastTween(currentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 80
			}))
		end))
		maid:Add(task.delay(0.6666666666666666, function()
			maid:Add(v4.fastTween(currentCamera, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 40
			}))
		end))
		maid:Add(task.delay(1.1333333333333333, function()
			maid:Add(v4.fastTween(
				currentCamera,
				TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					FieldOfView = 90
				}
			))
		end))
		maid:Add(task.delay(2, function()
			maid:Add(v4.fastTween(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 70
			}))
		end))
		maid:Add(task.delay(3, function()
			maid:Add(v4.fastTween(currentCamera, TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 40
			}))
		end))
		maid:Add(task.delay(3.1666666666666665, function()
			maid:Add(v4.fastTween(currentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 90
			}))
		end))
		currentCamera.CameraType = Enum.CameraType.Scriptable
		maid:Add(RunService.Heartbeat:Connect(function()
			currentCamera.CFrame = clone2.CutsceneCameraPart.CFrame
		end))
		maid:Add(track.Stopped:Connect(function()
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") or currentCamera.CameraSubject
			maid:Clean()
		end))
	else
		if v9 > 0 then
			task.wait(v9)
		end

		if not (parent.Parent and instance.Parent) then
			maid:Clean()
			return
		end
	end

	local folder = v2.Physics.CloneAndWeld(
		parent,
		finisherParticles.SpinnyTrail,
		CFrame.identity,
		parent:FindFirstChild("Torso"),
		maid
	)
	folder.Parent = parent
	local cloneAndWeld = v2.Physics.CloneAndWeld(
		parent,
		finisherParticles.Hit,
		CFrame.identity,
		instance:FindFirstChild("Torso"),
		maid
	)
	cloneAndWeld.Parent = parent
	maid:Add(task.delay(0.16666666666666666, function()
		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	end))
	maid:Add(task.delay(3.0833333333333335, function()
		v2.Visual:PlayEffects(cloneAndWeld)
	end))
	return maid
end