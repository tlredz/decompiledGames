local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Shared.FastUtils)
local v4 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Finishers)
local play = require3(ReplicatedStorage2.Shared.EmoteTypes.EnableAndEmit)
local v6 = require3(ReplicatedStorage2.Controllers.UI.SpectateController)
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local animations = script.Animations
local zeusLightning = ReplicatedStorage2.Misc.DataFinishers["Zeus' Lightning"]

local function finisher(instance, instance2, cFrame: CFrame, p: number)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart2) then
		return
	end

	local maid = v.new()
	local character = localPlayer.Character
	local v7 = instance == character or not game.Players:GetPlayerFromCharacter(instance)
	local v8 = instance2 == character or not game.Players:GetPlayerFromCharacter(instance2)
	local v9 = v7 and v8
	local currentlySpectating = v6:GetCurrentlySpectating()
	local character2 = currentlySpectating and currentlySpectating.Character
	local v10 = character2 == instance or character2 == instance2
	local v11

	if v9 then
		v11 = 0
	else
		v11 = p - workspace:GetServerTimeNow()
		maid:Add(task.delay((zeusLightning:GetAttribute("Duration") or 0) + v11 + 0.1, function()
			maid:Clean()
		end))
	end

	if v7 or v8 or v10 or v9 then
		local clone = maid:Clone(ReplicatedStorage2.Misc.FinisherCameraRig)
		clone.HumanoidRootPart.CFrame = cFrame
		clone.Parent = workspace.Runtime
		maid:AttachToInstance(clone)
		local track = clone.Humanoid.Animator:LoadAnimation(animations.Camera)
		local tracks = {}
		local thread

		if not (v10 and not v9) then
			if v7 then
				table.insert(tracks, instance.Humanoid.Animator:LoadAnimation(animations.Player1))
			end

			if v8 then
				table.insert(tracks, instance2.Humanoid.Animator:LoadAnimation(animations.Player2))
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

		if not (instance.Parent and instance2.Parent) then
			maid:Clean()
			return
		end

		if v10 then
			workspace:SetAttribute("DisableSpectateFinisher", os.clock() + 60)
			maid:Add(function()
				workspace:SetAttribute("DisableSpectateFinisher", nil)
			end)
			v6:Leave()
			v6:SetVisibility(false)
		end

		maid:Connect(RunService.PostSimulation, function()
			humanoidRootPart:PivotTo(cFrame)
			humanoidRootPart2:PivotTo(cFrame)
		end)
		track.TimePosition = 0
		track:Play(0)

		for _, v12 in tracks do
			v12.TimePosition = 0
			v12:Play(0)
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

			for _, v12 in tracks do
				v12:Stop()
				v12:Destroy()
			end
		end)
		currentCamera.FieldOfView = 70
		currentCamera.CameraType = Enum.CameraType.Scriptable
		maid:Connect(RunService.Heartbeat, function()
			currentCamera.CFrame = clone.CutsceneCameraPart.CFrame
		end)
		maid:Connect(track.Stopped, function()
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") or currentCamera.CameraSubject
			maid:Clean()
		end)
	else
		if v11 > 0 then
			task.wait(v11)
		end

		if not (instance.Parent and instance2.Parent) then
			maid:Clean()
			return
		end
	end

	local instance3 = v4:GetInstance(script.Name)
	local sfx = instance3:FindFirstChild("sfx")

	if sfx then
		local clone = maid:Clone(sfx)
		clone.Parent = SoundService
		clone:Play()
	end

	local v12 = {
		VFX = instance3.VFX1,
		Emote = animations.Player1,
		Play = play
	}
	local v13 = maid:Add(v2.Inst.simple("Folder", "EmoteVFX_Storage", instance))

	if v10 or v9 then
		maid:Add(task.delay(0.3333333333333333, pcall, function()
			local finisherCameraRig = workspace.Runtime:FindFirstChild("FinisherCameraRig")

			if not finisherCameraRig then
				return
			end

			for _, v14 in v13:QueryDescendants("#CamWeldEnable > Weld,#CamWeldEmit > Weld"), nil, nil do
				v14.Part1 = finisherCameraRig.CutsceneCameraPart
			end
		end))
		maid:Add(task.delay(4.083333333333333, xpcall, function()
			local v14 = maid:Add(v13["7. Lighting Flash (Lighting)"].Flash)
			local brightness = v14.Brightness
			v14.Brightness = 0
			local contrast = v14.Contrast
			v14.Contrast = 0
			local saturation = v14.Saturation
			v14.Saturation = 0
			v14.Enabled = true
			v14.Parent = currentCamera

			for _ = 0, 71, 7 do
				local v15 = maid:Add(v3.fastTween(v14, TweenInfo.new(0.016666666666666666), {
					Brightness = brightness,
					Contrast = contrast,
					Saturation = saturation
				}))
				task.wait(0.05)
				maid:Remove(v15)
				local v16 = maid:Add(v3.fastTween(v14, TweenInfo.new(0.016666666666666666), {
					Brightness = 0,
					Contrast = 0,
					Saturation = 0
				}))
				task.wait(0.06666666666666667)
				maid:Remove(v16)
			end
		end, warn))
	end

	local v14 = v12:Play(instance, true)

	if v14 then
		maid:Add(v14)
	end

	maid:Add(function()
		v12:Play(instance, false)
	end)
	local v15 = {
		VFX = instance3.VFX2,
		Emote = animations.Player2,
		Play = play
	}
	maid:Add(v2.Inst.simple("Folder", "EmoteVFX_Storage", instance2))
	local v16 = v15:Play(instance2, true)

	if v16 then
		maid:Add(v16)
	end

	maid:Add(function()
		v15:Play(instance2, false)
	end)
	maid:Add(task.delay(6.5, function()
		maid:Clean()
	end))
	return maid
end

return finisher