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
local jackolantern = ReplicatedStorage2.Misc.DataFinishers.Jackolantern
local currentCamera = workspace.CurrentCamera
return function(parent, parent2, cframe: CFrame, p: number)
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
		maid:Add(task.delay((jackolantern:GetAttribute("Duration") or 0) + v10 + 0.1, function()
			maid:Clean()
		end))
	end

	if v6 or v7 or v9 or v8 then
		local clone = maid:Clone(ReplicatedStorage2.Misc.FinisherCameraRig)
		clone.HumanoidRootPart.CFrame = cframe * CFrame.new(2.6514053344726562, -2.384185791015625e-7, -1.993896484375) * CFrame.fromOrientation(
			0,
			0.05235987755982989,
			0
		)
		clone.Parent = workspace.Runtime
		maid:AttachToInstance(clone)
		local track = clone.Humanoid.Animator:LoadAnimation(script.Animations.Camera)
		local tracks = {}
		local thread

		if not (v9 and not v8) then
			if v6 then
				table.insert(tracks, parent.Humanoid.Animator:LoadAnimation(script.Animations.Player1))
				table.insert(tracks, parent.Humanoid.Animator:LoadAnimation(script.Animations.Pumpkin))
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
			humanoidRootPart:PivotTo(cframe)
			humanoidRootPart2:PivotTo(cframe)
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

	local _0Pumpkin = folder:FindFirstChild("0. Pumpkin")

	if _0Pumpkin and _0Pumpkin:FindFirstChild("Pumpkin") then
		for _, child in folder:GetChildren() do
			local pumpkin_weld = child:FindFirstChild("pumpkin_weld")

			if pumpkin_weld and pumpkin_weld:IsA("BasePart") then
				v2.Physics.CreateWeld(pumpkin_weld, _0Pumpkin.Pumpkin:FindFirstChild("Emitters"))
			end
		end

		maid:Add(_0Pumpkin.Pumpkin)
		_0Pumpkin.Pumpkin.Parent = parent
	end

	maid:Add(function()
		v11.Play(v11, parent, false)
	end)

	if v9 or v8 then
		for _, v13 in {
			{ 153, 3 },
			{ 187, 3 },
			{ 214, 3 }
		} do
			local v14 = v13
			maid:Add(task.delay(v13[1] / 60, function()
				pcall(function()
					local clone = maid:Clone(folder.Impact)
					clone.Parent = currentCamera
					maid:Add(task.delay(v14[2] / 60, function()
						maid:Remove(clone)
					end))
				end)
			end))
		end
	end

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
	maid:Add(task.delay(9, function()
		maid:Clean()
	end))
	return maid
end