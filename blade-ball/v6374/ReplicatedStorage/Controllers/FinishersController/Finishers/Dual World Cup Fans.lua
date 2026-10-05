local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3("@game/ReplicatedStorage/Packages/Trove")
require3("@game/ReplicatedStorage/Packages/Freeze")
local v2 = require3("@game/ReplicatedStorage/Common/Utils")
require3("@game/ReplicatedStorage/Shared/FastUtils")
local v3 = require3("@game/ReplicatedStorage/Shared/ReplicatedInstances/Finishers")
local play = require3("@game/ReplicatedStorage/Shared/EmoteTypes/EnableAndEmit")
local v5 = require3("@game/ReplicatedStorage/Controllers/UI/SpectateController")
local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local animations = script.Animations
local dualWorldCupFans = ReplicatedStorage2.Misc.DataFinishers["Dual World Cup Fans"]

local function finisher(instance, instance2, cFrame: CFrame, p: number)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart2) then
		return
	end

	local maid = v.new()
	local character = localPlayer.Character
	local v6 = instance == character or not Players:GetPlayerFromCharacter(instance)
	local v7 = instance2 == character or not Players:GetPlayerFromCharacter(instance2)
	local v8 = v6 and v7
	local currentlySpectating = v5:GetCurrentlySpectating()
	local character2 = currentlySpectating and currentlySpectating.Character
	local v9 = character2 == instance or character2 == instance2
	local v10

	if v8 then
		v10 = 0
	else
		v10 = p - workspace:GetServerTimeNow()
		maid:Add(task.delay((dualWorldCupFans:GetAttribute("Duration") or 0) + v10 + 0.1, function()
			maid:Clean()
		end))
	end

	if v6 or v7 or v9 or v8 then
		local clone = maid:Clone(ReplicatedStorage2.Misc.FinisherCameraRig2)
		clone.RootPart.CFrame = cFrame
		clone.Parent = workspace.Runtime
		maid:AttachToInstance(clone)
		local track = clone.Humanoid.Animator:LoadAnimation(animations.Camera)
		local tracks = {}
		local thread

		if not (v9 and not v8) then
			if v6 then
				table.insert(tracks, instance.Humanoid.Animator:LoadAnimation(animations.Player1))
			end

			if v7 then
				table.insert(tracks, instance2.Humanoid.Animator:LoadAnimation(animations.Player2))
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

		if not (instance.Parent and instance2.Parent) then
			maid:Clean()
			return
		end

		if v9 then
			workspace:SetAttribute("DisableSpectateFinisher", os.clock() + 60)
			maid:Add(function()
				workspace:SetAttribute("DisableSpectateFinisher", nil)
			end)
			v5:Leave()
			v5:SetVisibility(false)
		end

		maid:Connect(RunService.PostSimulation, function()
			humanoidRootPart:PivotTo(cFrame)
			humanoidRootPart2:PivotTo(cFrame)
		end)
		track.TimePosition = 0
		track:Play(0)

		for _, v11 in tracks do
			v11.TimePosition = 0
			v11:Play(0)
		end

		maid:Add(function()
			currentCamera.CameraType = Enum.CameraType.Custom
			local v11 = currentCamera
			local cameraSubject

			if localPlayer.Character then
				cameraSubject = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
			else
				cameraSubject = currentCamera.CameraSubject
			end

			v11.CameraSubject = cameraSubject
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
		maid:Connect(RunService.Heartbeat, function()
			currentCamera.CFrame = clone.CamPart.CFrame
		end)
		maid:Connect(track.Stopped, function()
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid") or currentCamera.CameraSubject
			maid:Clean()
		end)
	else
		if v10 > 0 then
			task.wait(v10)
		end

		if not (instance.Parent and instance2.Parent) then
			maid:Clean()
			return
		end
	end

	local instance3 = v3:GetInstance(script.Name)
	local sfx = instance3:FindFirstChild("sfx")

	if sfx then
		local clone = maid:Clone(sfx)
		clone.Parent = SoundService
		clone:Play()
	end

	local v11 = {
		VFX = instance3.VFX,
		Emote = animations.Player1,
		Play = play
	}
	maid:Add(v2.Inst.simple("Folder", "EmoteVFX_Storage", instance))
	local v12 = v11:Play(instance, true)

	if v12 then
		maid:Add(v12)
	end

	maid:Add(function()
		v11:Play(instance, false)
	end)
	maid:Add(task.delay(9, function()
		maid:Clean()
	end))
	return maid
end

return finisher