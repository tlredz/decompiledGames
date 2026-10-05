local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
game:GetService("SoundService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Shared.FastUtils)
require3(ReplicatedStorage2.Shared.ReplicatedInstances.Finishers)
require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
local v3 = require3(ReplicatedStorage2.Controllers.UI.SpectateController)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local animations = script.Animations
local dualSeaSovereign = ReplicatedStorage2.Misc.DataFinishers["Dual Sea Sovereign"]

local function finisher(instance, instance2, cFrame: CFrame, p: number)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart2) then
		return
	end

	local maid = v.new()
	local character = localPlayer.Character
	local v4 = instance == character or not game.Players:GetPlayerFromCharacter(instance)
	local v5 = instance2 == character or not game.Players:GetPlayerFromCharacter(instance2)
	local v6 = v4 and v5
	local currentlySpectating = v3:GetCurrentlySpectating()
	local character2 = currentlySpectating and currentlySpectating.Character
	local v7 = character2 == instance or character2 == instance2
	local v8

	if v6 then
		v8 = 0
	else
		v8 = p - workspace:GetServerTimeNow()
		maid:Add(task.delay((dualSeaSovereign:GetAttribute("Duration") or 0) + v8 + 0.1, function()
			maid:Clean()
		end))
	end

	if v4 or v5 or v7 or v6 then
		local clone = maid:Clone(ReplicatedStorage2.Misc.FinisherCameraRig2)
		clone.RootPart.CFrame = cFrame
		clone.Parent = workspace.Runtime
		maid:AttachToInstance(clone)
		local track = clone.Humanoid.Animator:LoadAnimation(animations.Camera)
		local tracks = {}
		local thread

		if not (v7 and not v6) then
			if v4 then
				table.insert(tracks, instance.Humanoid.Animator:LoadAnimation(animations.Player1))
			end

			if v5 then
				table.insert(tracks, instance2.Humanoid.Animator:LoadAnimation(animations.Player2))
			end

			thread = task.spawn(function()
				for _, v9 in tracks do
					v9:Play(0)
				end

				while true do
					local flag = false

					for _, v10 in tracks do
						if v10.Length ~= 0 then
							continue
						end

						flag = true
						break
					end

					if flag then
						task.wait()
					else
						for _, v10 in tracks do
							v10:Stop(0)
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

		if v6 then
			while coroutine.status(thread) ~= "dead" and coroutine.status(thread2) ~= "dead" do
				task.wait()
			end
		elseif v8 > 0 then
			task.wait(v8)
		end

		v2.Thread.SafeCancel(thread2)

		if thread then
			v2.Thread.SafeCancel(thread)
		end

		if not (instance.Parent and instance2.Parent) then
			maid:Clean()
			return
		end

		if v7 then
			workspace:SetAttribute("DisableSpectateFinisher", os.clock() + 60)
			maid:Add(function()
				workspace:SetAttribute("DisableSpectateFinisher", nil)
			end)
			v3:Leave()
			v3:SetVisibility(false)
		end

		maid:Connect(RunService.PostSimulation, function()
			humanoidRootPart:PivotTo(cFrame)
			humanoidRootPart2:PivotTo(cFrame)
		end)
		track.TimePosition = 0
		track:Play(0)

		for _, v9 in tracks do
			v9.TimePosition = 0
			v9:Play(0)
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

			for _, v9 in tracks do
				v9:Stop()
				v9:Destroy()
			end
		end)
		currentCamera.FieldOfView = 70
		currentCamera.CameraType = Enum.CameraType.Scriptable
		maid:Connect(RunService.Heartbeat, function()
			currentCamera.CFrame = clone.CamPart.CFrame
		end)
		maid:Connect(track.Stopped, function()
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") or currentCamera.CameraSubject
			maid:Clean()
		end)
	else
		if v8 > 0 then
			task.wait(v8)
		end

		if not (instance.Parent and instance2.Parent) then
			maid:Clean()
			return
		end
	end

	maid:Add(task.delay(4.51, function()
		maid:Clean()
	end))
	return maid
end

return finisher