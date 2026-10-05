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
local play = require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
local v5 = require3(ReplicatedStorage2.Shared.FastUtils)
local v6 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Finishers)
local _ = ReplicatedStorage2.Remotes
local chimerasBane = ReplicatedStorage2.Misc.DataFinishers["Chimera's Bane"]
local currentCamera = workspace.CurrentCamera
return function(parent, instance, cFrame: CFrame, p: number)
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart2) then
		return
	end

	local maid = v.new()
	local localPlayer = Players.LocalPlayer
	local v7 = parent == localPlayer.Character or not Players:GetPlayerFromCharacter(parent)
	local v8 = instance == localPlayer.Character or not Players:GetPlayerFromCharacter(instance)
	local v9 = v7 and v8
	local currentlySpectating = v3:GetCurrentlySpectating()
	local v10

	if currentlySpectating == nil then
		v10 = false
	else
		v10 = currentlySpectating.Character and (currentlySpectating.Character == parent or currentlySpectating.Character == instance)
	end

	local v11

	if v9 then
		v11 = 0
	else
		v11 = p - workspace:GetServerTimeNow()
		maid:Add(task.delay((chimerasBane:GetAttribute("Duration") or 0) + v11 + 0.1, function()
			maid:Clean()
		end))
	end

	if v7 or v8 or v10 then
		local clone = maid:Clone(ReplicatedStorage2.Misc.FinisherCameraRig)
		clone.HumanoidRootPart.CFrame = cFrame
		clone.Parent = workspace.Runtime
		maid:AttachToInstance(clone)
		local track = clone.Humanoid.Animator:LoadAnimation(script.Animations.Camera)
		local tracks = {}
		local thread

		if not (v10 and not v9) then
			if v7 then
				table.insert(tracks, parent.Humanoid.Animator:LoadAnimation(script.Animations.Player1))
			end

			if v8 then
				table.insert(tracks, instance.Humanoid.Animator:LoadAnimation(script.Animations.Player2))
			end

			thread = task.spawn(function()
				for _, v12 in tracks do
					v12:Play(0)
				end

				while true do
					local flag = false

					for _, v13 in tracks do
						if v13.Length ~= 0 then
							continue
						end

						flag = true
						break
					end

					if flag then
						task.wait()
					else
						for _, v13 in tracks do
							v13:Stop(0)
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

		if v9 then
			while coroutine.status(thread) ~= "dead" and coroutine.status(thread2) ~= "dead" do
				task.wait()
			end
		elseif v11 > 0 then
			task.wait(v11)
		end

		v2.Thread.SafeCancel(thread2)

		if thread then
			v2.Thread.SafeCancel(thread)
		end

		if not (parent.Parent and instance.Parent) then
			maid:Clean()
			return
		end

		if v10 then
			workspace:SetAttribute("DisableSpectateFinisher", os.clock() + 60)
			maid:Add(function()
				workspace:SetAttribute("DisableSpectateFinisher", nil)
			end)
			v3:Leave()
			v3:SetVisibility(false)
		end

		maid:Add(RunService.PostSimulation:Connect(function()
			humanoidRootPart:PivotTo(cFrame)
			humanoidRootPart2:PivotTo(cFrame * CFrame.new(0, 0, -11.3) * CFrame.Angles(0, 3.141592653589793, 0))
		end))
		track:Play(0)

		for _, v12 in tracks do
			v12:Play(0)
		end

		maid:Add(function()
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") or currentCamera.CameraSubject
			task.defer(function()
				currentCamera.FieldOfView = 70
			end)
		end)
		maid:Add(function()
			track:Stop()
			track:Destroy()

			for _, v12 in tracks do
				v12:Stop()
				v12:Destroy()
			end
		end)
		currentCamera.FieldOfView = 45
		maid:Add(task.delay(0, function()
			maid:Add(v5.fastTween(currentCamera, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 90
			}))
		end))
		maid:Add(task.delay(2, function()
			maid:Add(v5.fastTween(
				currentCamera,
				TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					FieldOfView = 65
				}
			))
		end))
		maid:Add(task.delay(4.333333333333333, function()
			maid:Add(v5.fastTween(currentCamera, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 80
			}))
		end))
		currentCamera.CameraType = Enum.CameraType.Scriptable
		maid:Add(RunService.Heartbeat:Connect(function()
			currentCamera.CFrame = clone.CutsceneCameraPart.CFrame
		end))
		maid:Add(track.Stopped:Connect(function()
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") or currentCamera.CameraSubject
			maid:Clean()
		end))
	else
		if v11 > 0 then
			task.wait(v11)
		end

		if not (parent.Parent and instance.Parent) then
			maid:Clean()
			return
		end
	end

	local v12 = {
		VFX = v6:GetInstance(script.Name).VFX,
		Emote = script.Animations.Player1,
		Play = play
	}
	local folder = Instance.new("Folder")
	maid:Add(folder)
	folder.Name = "EmoteVFX_Storage"
	folder.Parent = parent
	local v13 = v12.Play(v12, parent, true)

	if v13 then
		maid:Add(v13)
	end

	maid:Add(function()
		v12.Play(v12, parent, false)
	end)
	maid:Add(task.delay(5, function()
		maid:Clean()
	end))
	return maid
end