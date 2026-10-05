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
require3(ReplicatedStorage2.Shared.FastUtils)
local v5 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Finishers)
local _ = ReplicatedStorage2.Remotes
local bunny = ReplicatedStorage2.Misc.DataFinishers.Bunny
local currentCamera = workspace.CurrentCamera
return function(parent, parent2, cFrame: CFrame, p: number)
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = parent2:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart2) then
		return
	end

	local maid = v.new()
	local localPlayer = Players.LocalPlayer
	local v6 = parent == localPlayer.Character or not Players:GetPlayerFromCharacter(parent)
	local v7 = parent2 == localPlayer.Character or not Players:GetPlayerFromCharacter(parent2)
	local v8 = v6 and v7
	local currentlySpectating = v3:GetCurrentlySpectating()
	local v9

	if currentlySpectating == nil then
		v9 = false
	else
		v9 = currentlySpectating.Character and (currentlySpectating.Character == parent or currentlySpectating.Character == parent2)
	end

	local v10

	if v8 then
		v10 = 0
	else
		v10 = p - workspace:GetServerTimeNow()
		maid:Add(task.delay((bunny:GetAttribute("Duration") or 0) + v10 + 0.1, function()
			maid:Clean()
		end))
	end

	if v6 or v7 or v9 or v8 then
		local clone = maid:Clone(ReplicatedStorage2.Misc.FinisherCameraRig)
		clone.HumanoidRootPart.CFrame = cFrame
		clone.Parent = workspace.Runtime
		maid:AttachToInstance(clone)
		local track = clone.Humanoid.Animator:LoadAnimation(script.Animations.Camera)
		local tracks = {}
		local thread

		if not (v9 and not v8) then
			if v6 then
				table.insert(tracks, parent.Humanoid.Animator:LoadAnimation(script.Animations.Player1))
			end

			if v7 then
				table.insert(tracks, parent2.Humanoid.Animator:LoadAnimation(script.Animations.Player2))
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

		if v8 then
			while coroutine.status(thread) ~= "dead" and coroutine.status(thread2) ~= "dead" do
				task.wait()
			end
		elseif v10 > 0 then
			task.wait(v10)
		end

		v2.Thread.SafeCancel(thread2)

		if thread then
			v2.Thread.SafeCancel(thread)
		end

		if not (parent.Parent and parent2.Parent) then
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
			humanoidRootPart2:PivotTo(cFrame * CFrame.new(0, 0, -5.71) * CFrame.Angles(0, 3.141592653589793, 0))
		end))
		track.TimePosition = 0
		track:Play(0)

		for _, v11 in tracks do
			v11.TimePosition = 0
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
		if v10 > 0 then
			task.wait(v10)
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
	local instance = v5:GetInstance(script.Name)
	local v11 = {
		VFX = instance.VFX1,
		Emote = script.Animations.Player1,
		Play = play
	}
	local folder = Instance.new("Folder")
	maid:Add(folder)
	folder.Name = "EmoteVFX_Storage"
	folder.Parent = parent
	local v12 = v11.Play(v11, parent, true)

	if v12 then
		maid:Add(v12)
	end

	maid:Add(function()
		v11.Play(v11, parent, false)
	end)
	local v13 = {
		VFX = instance.VFX2,
		Emote = script.Animations.Player2,
		Play = play
	}
	local folder2 = Instance.new("Folder")
	maid:Add(folder2)
	folder2.Name = "EmoteVFX_Storage"
	folder2.Parent = parent2
	local v14 = v13.Play(v13, parent2, true)

	if v14 then
		maid:Add(v14)
	end

	maid:Add(function()
		v13.Play(v13, parent2, false)
	end)
	maid:Add(task.delay(5.5, function()
		maid:Clean()
	end))
	return maid
end