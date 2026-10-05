local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
game:GetService("Debris")
local v = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Controllers.UI.SpectateController)
local play = require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
local v6 = require3(ReplicatedStorage2.Shared.FastUtils)
local v7 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Finishers)
local _ = ReplicatedStorage2.Remotes
local voidWeaver = ReplicatedStorage2.Misc.DataFinishers["Void Weaver"]
local currentCamera = workspace.CurrentCamera
return function(parent, parent2, cframe: CFrame, p: number)
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = parent2:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart2) then
		return
	end

	local maid = v.new()
	local localPlayer = Players.LocalPlayer
	local v8 = parent == localPlayer.Character or not Players:GetPlayerFromCharacter(parent)
	local v9 = parent2 == localPlayer.Character or not Players:GetPlayerFromCharacter(parent2)
	local v10 = v8 and v9
	local currentlySpectating = v4:GetCurrentlySpectating()
	local v11

	if currentlySpectating == nil then
		v11 = false
	else
		v11 = currentlySpectating.Character and (currentlySpectating.Character == parent or currentlySpectating.Character == parent2)
	end

	local v12

	if v10 then
		v12 = 0
	else
		v12 = p - workspace:GetServerTimeNow()
		maid:Add(task.delay((voidWeaver:GetAttribute("Duration") or 0) + v12 + 0.1, function()
			maid:Clean()
		end))
	end

	if v8 or v9 or v11 or v10 then
		local clone = maid:Clone(ReplicatedStorage2.Misc.FinisherCameraRig)
		clone.HumanoidRootPart.CFrame = cframe * CFrame.new(0, 2.66, 0) * CFrame.new(-1.44, -0.35, -0.68)
		clone.Parent = workspace.Runtime
		maid:AttachToInstance(clone)
		local track = clone.Humanoid.Animator:LoadAnimation(script.Animations.Camera)
		local tracks = {}
		local thread

		if not (v11 and not v10) then
			if v8 then
				table.insert(tracks, parent.Humanoid.Animator:LoadAnimation(script.Animations.Player1))
			end

			if v9 then
				table.insert(tracks, parent2.Humanoid.Animator:LoadAnimation(script.Animations.Player2))
			end

			thread = task.spawn(function()
				for _, v13 in tracks do
					v13:Play(0)
				end

				while true do
					local flag = false

					for _, v14 in tracks do
						if v14.Length ~= 0 then
							continue
						end

						flag = true
						break
					end

					if flag then
						task.wait()
					else
						for _, v14 in tracks do
							v14:Stop(0)
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

		if v10 then
			while coroutine.status(thread) ~= "dead" and coroutine.status(thread2) ~= "dead" do
				task.wait()
			end
		elseif v12 > 0 then
			task.wait(v12)
		end

		v3.Thread.SafeCancel(thread2)

		if thread then
			v3.Thread.SafeCancel(thread)
		end

		if not (parent.Parent and parent2.Parent) then
			maid:Clean()
			return
		end

		if v11 then
			workspace:SetAttribute("DisableSpectateFinisher", os.clock() + 60)
			maid:Add(function()
				workspace:SetAttribute("DisableSpectateFinisher", nil)
			end)
			v4:Leave()
			v4:SetVisibility(false)
		end

		maid:Add(RunService.PostSimulation:Connect(function()
			humanoidRootPart:PivotTo(cframe * CFrame.new(0, 2.66, 0))
			humanoidRootPart2:PivotTo(cframe * CFrame.new(0, 2.66, 0) * CFrame.new(0.57, -0.22, 0.32))
		end))
		track.TimePosition = 0
		track:Play(0)

		for _, v13 in tracks do
			v13.TimePosition = 0
			v13:Play(0)
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

			for _, v13 in tracks do
				v13:Stop()
				v13:Destroy()
			end
		end)
		currentCamera.FieldOfView = 70
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
		if v12 > 0 then
			task.wait(v12)
		end

		if not (parent.Parent and parent2.Parent) then
			maid:Clean()
			return
		end
	end

	parent:RemoveTag("GiveSwordNPC")

	for _, child in parent:GetChildren() do
		if child:GetAttribute("_equippedSword") or child:GetAttribute("_swordAccessory") then
			child:Destroy()
		end
	end

	maid:Add(parent.ChildAdded:Connect(function(child)
		if child:GetAttribute("_equippedSword") or child:GetAttribute("_swordAccessory") then
			task.delay(0, function()
				child:Destroy()
			end)
		end
	end))
	local instance = v7:GetInstance(script.Name)
	local v13 = {
		VFX = instance.VFX1,
		Emote = script.Animations.Player1,
		Play = play
	}
	local folder = Instance.new("Folder")
	maid:Add(folder)
	folder.Name = "EmoteVFX_Storage"
	folder.Parent = parent
	local v14 = v13.Play(v13, parent, true)

	if v14 then
		maid:Add(v14)
	end

	maid:Add(function()
		v13.Play(v13, parent, false)
	end)
	local v15 = {
		VFX = instance.VFX2,
		Emote = script.Animations.Player2,
		Play = play
	}
	local folder2 = Instance.new("Folder")
	maid:Add(folder2)
	folder2.Name = "EmoteVFX_Storage"
	folder2.Parent = parent2
	local v16 = v15.Play(v15, parent2, true)

	if v16 then
		maid:Add(v16)
	end

	maid:Add(function()
		v15.Play(v15, parent2, false)
	end)
	maid:Add(task.delay(7.1, function()
		maid:Clean()
	end))
	local clockTime = Lighting.ClockTime
	local v17 = false
	local v18 = false
	maid:Add(task.delay(1.2166666666666666, function()
		v18 = true
		v6.fastTween(Lighting, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
			ClockTime = 4.8
		})
	end))

	local function resetCycle()
		if not v18 or v17 then
			return
		end

		v17 = true
		local replion = v2.Client:GetReplion("Data")
		local fastTween = v6.fastTween
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local clockTime2

		if replion then
			clockTime2 = replion:Get("Settings.Misc.Night Mode.Enabled") and 20.8 or 11.2
		else
			clockTime2 = clockTime
		end

		fastTween(Lighting, tweenInfo, {
			ClockTime = clockTime2
		})
	end

	maid:Add(task.delay(5, resetCycle))
	maid:Add(resetCycle)
	return maid
end