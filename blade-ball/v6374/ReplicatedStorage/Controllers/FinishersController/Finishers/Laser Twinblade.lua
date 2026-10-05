local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("Debris")
local v = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Controllers.UI.SpectateController)
local v4 = require3(ReplicatedStorage2.Controllers.FinishersController.ParticleUtils)
local v5 = require3(ReplicatedStorage2.Shared.FastUtils)
require3(ReplicatedStorage2.Shared.ReplicatedInstances.Finishers)
local _ = ReplicatedStorage2.Remotes
local laserTwinblade = ReplicatedStorage2.Misc.DataFinishers["Laser Twinblade"]
local currentCamera = workspace.CurrentCamera
return function(instance, instance2, cFrame: CFrame, p: number)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart2) then
		return
	end

	local maid = v.new()
	local localPlayer = Players.LocalPlayer
	local v6 = instance == localPlayer.Character or not Players:GetPlayerFromCharacter(instance)
	local v7 = instance2 == localPlayer.Character or not Players:GetPlayerFromCharacter(instance2)
	local v8 = v6 and v7
	local currentlySpectating = v3:GetCurrentlySpectating()
	local v9

	if currentlySpectating == nil then
		v9 = false
	else
		v9 = currentlySpectating.Character and (currentlySpectating.Character == instance or currentlySpectating.Character == instance2)
	end

	local v10

	if v8 then
		v10 = 0
	else
		v10 = p - workspace:GetServerTimeNow()
		maid:Add(task.delay((laserTwinblade:GetAttribute("Duration") or 0) + v10 + 0.1, function()
			maid:Clean()
		end))
	end

	local clone = maid:Clone(script.sfx)
	clone.Volume = 0
	clone.Parent = localPlayer.PlayerGui

	if v6 or v7 or v9 or v8 then
		local clone2 = maid:Clone(ReplicatedStorage2.Misc.FinisherCameraRig)
		clone2.HumanoidRootPart.CFrame = cFrame
		clone2.Parent = workspace.Runtime
		maid:AttachToInstance(clone2)
		local track = clone2.Humanoid.Animator:LoadAnimation(script.Animations.Camera)
		local tracks = {}
		local thread

		if not (v9 and not v8) then
			if v6 then
				table.insert(tracks, instance.Humanoid.Animator:LoadAnimation(script.Animations.Player1))
			end

			if v7 then
				table.insert(tracks, instance2.Humanoid.Animator:LoadAnimation(script.Animations.Player2))
			end

			thread = task.spawn(function()
				for _, v11 in tracks do
					v11:Play(0)
				end

				while true do
					local flag = false

					for _, v12 in tracks do
						if v12.Length ~= 0 then
							continue
						end

						flag = true
						break
					end

					if flag then
						task.wait()
					else
						for _, v12 in tracks do
							v12:Stop(0)
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

		if v8 then
			while coroutine.status(thread) ~= "dead" and coroutine.status(thread2) ~= "dead" do
				task.wait()
			end
		elseif v10 > 0 then
			task.wait(v10)
		end

		v2.Thread.SafeCancel(thread3)
		clone.TimePosition = 0
		v2.Thread.SafeCancel(thread2)

		if thread then
			v2.Thread.SafeCancel(thread)
		end

		if not (instance.Parent and instance2.Parent) then
			maid:Clean()
			return
		end

		if v9 then
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

		for _, v11 in tracks do
			v11:Play(0)
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

			for _, v11 in tracks do
				v11:Stop()
				v11:Destroy()
			end
		end)
		currentCamera.FieldOfView = 45
		maid:Add(task.delay(1.6666666666666667, function()
			maid:Add(v5.fastTween(
				currentCamera,
				TweenInfo.new(1.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					FieldOfView = 90
				}
			))
		end))
		maid:Add(task.delay(3.5, function()
			maid:Add(v5.fastTween(
				currentCamera,
				TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					FieldOfView = 55
				}
			))
		end))
		maid:Add(task.delay(3.9166666666666665, function()
			maid:Add(v5.fastTween(currentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 90
			}))
		end))
		maid:Add(task.delay(3.9166666666666665, function()
			maid:Add(v5.fastTween(currentCamera, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 70
			}))
		end))
		maid:Add(task.delay(5.166666666666667, function()
			maid:Add(v5.fastTween(
				currentCamera,
				TweenInfo.new(0.275, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					FieldOfView = 105
				}
			))
		end))
		maid:Add(task.delay(6, function()
			maid:Add(v5.fastTween(currentCamera, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 70
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
		if v10 > 0 then
			task.wait(v10)
		end

		if not (instance.Parent and instance2.Parent) then
			maid:Clean()
			return
		end
	end

	maid:Add(task.delay(2.5, function()
		local clone2 = finisherParticles:Clone()
		clone2:PivotTo(cFrame)
		clone2.Parent = workspace.Runtime
		v4.emitParticles({ clone2 })
		maid:Add(function()
			task.delay(1.13, function()
				if clone2 then
					clone2:Destroy()
					clone2 = nil
				end
			end)
		end)
		maid:Add(task.delay(0.95, function()
			v4.disableParticles({ clone2 })
			maid:Add(task.delay(1.13, function()
				if clone2 then
					clone2:Destroy()
					clone2 = nil
				end
			end))
		end))
	end))
	return maid
end