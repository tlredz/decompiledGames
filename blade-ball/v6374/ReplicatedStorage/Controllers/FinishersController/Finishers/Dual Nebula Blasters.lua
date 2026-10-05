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
local _ = ReplicatedStorage2.Remotes
local dualNebulaBlasters = ReplicatedStorage2.Misc.DataFinishers["Dual Nebula Blasters"]
local v4 = require3(ReplicatedStorage2.Shared.FastUtils)
local v5 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Finishers)
local currentCamera = workspace.CurrentCamera
return function(parent, parent2, cFrame: CFrame, p: number)
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = parent2:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart2) then
		return
	end

	local instance = v5:GetInstance("Dual Nebula Blasters")

	if not instance then
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
		maid:Add(task.delay((dualNebulaBlasters:GetAttribute("Duration") or 0) + v10 + 0.1, function()
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
			humanoidRootPart2:PivotTo(cFrame)
		end))
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
			maid:Add(v4.fastTween(
				currentCamera,
				TweenInfo.new(1.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					FieldOfView = 90
				}
			))
		end))
		maid:Add(task.delay(3.5, function()
			maid:Add(v4.fastTween(
				currentCamera,
				TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					FieldOfView = 55
				}
			))
		end))
		maid:Add(task.delay(3.9166666666666665, function()
			maid:Add(v4.fastTween(currentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 90
			}))
		end))
		maid:Add(task.delay(3.9166666666666665, function()
			maid:Add(v4.fastTween(currentCamera, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 70
			}))
		end))
		maid:Add(task.delay(5.166666666666667, function()
			maid:Add(v4.fastTween(
				currentCamera,
				TweenInfo.new(0.275, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
				{
					FieldOfView = 105
				}
			))
		end))
		maid:Add(task.delay(6, function()
			maid:Add(v4.fastTween(currentCamera, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				FieldOfView = 70
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
		if v10 > 0 then
			task.wait(v10)
		end

		if not (parent.Parent and parent2.Parent) then
			maid:Clean()
			return
		end
	end

	local cloneAndWeld = v2.Physics.CloneAndWeld(
		parent,
		instance.TorsoFlex,
		CFrame.identity,
		parent:FindFirstChild("Torso"),
		maid
	)
	cloneAndWeld.Parent = parent
	local cloneAndWeld2 = v2.Physics.CloneAndWeld(
		parent,
		instance.GunEmitLeft1,
		CFrame.identity,
		parent:FindFirstChild("sord", true),
		maid
	)
	cloneAndWeld2.Parent = parent
	local cloneAndWeld3 = v2.Physics.CloneAndWeld(
		parent,
		instance.GunEmitRight2,
		CFrame.identity,
		parent:FindFirstChild("sordz2", true),
		maid
	)
	cloneAndWeld3.Parent = parent
	local cloneAndWeld4 = v2.Physics.CloneAndWeld(
		parent2,
		instance.VictimTorsoEmit,
		CFrame.identity,
		parent2:FindFirstChild("Torso"),
		maid
	)
	cloneAndWeld4.Parent = parent2
	local folder = v2.Physics.CloneAndWeld(
		parent,
		instance.TorsoFlex2,
		CFrame.identity,
		parent:FindFirstChild("Torso"),
		maid
	)
	folder.Parent = parent
	local folder2 = v2.Physics.CloneAndWeld(parent, instance.FloorMain, CFrame.new(0, -2.98, 0), nil, maid)
	folder2.Parent = parent
	local cloneAndWeld5 = v2.Physics.CloneAndWeld(parent, instance.GunEmitLaser, CFrame.identity, nil, maid)
	cloneAndWeld5.Parent = parent
	maid:Add(task.defer(function()
		cloneAndWeld.sfx:Play()
	end))
	maid:Add(task.delay(0.5333333333333333, function()
		v2.Visual:PlayEffects(cloneAndWeld)
	end))
	maid:Add(task.delay(1.7666666666666666, function()
		for _ = 1, 21 do
			v2.Visual:PlayEffects(cloneAndWeld2)
			v2.Visual:PlayEffects(cloneAndWeld4)
			task.wait(0.075)

			if maid._cleaning then
				break
			end

			v2.Visual:PlayEffects(cloneAndWeld3)
			v2.Visual:PlayEffects(cloneAndWeld4)
		end
	end))
	maid:Add(task.delay(3.5833333333333335, function()
		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	end))
	maid:Add(task.delay(4.116666666666666, function()
		for _, emitter in folder:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end))
	maid:Add(task.delay(4.133333333333334, function()
		for _, emitter in folder2:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end
	end))
	maid:Add(task.delay(6.3, function()
		for _, emitter in folder2:GetDescendants() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end))
	maid:Add(task.delay(5.166666666666667, function()
		v2.Visual:PlayEffects(cloneAndWeld5)
	end))
	maid:Add(task.delay(6.833333333333333, function()
		maid:Clean()
	end))
	return maid
end