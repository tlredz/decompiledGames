local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local eagleF = FX:WaitForChild("Eagle").EagleF
local _WorldOrigin = workspace._WorldOrigin
local Util = require(ReplicatedStorage:WaitForChild("Util"))
Random.new()

local function ParticleState(folder, enabled, p)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if p and effect:GetAttribute("Color") == true then
			effect.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			if effect:GetAttribute("EmitDelay") then
				local v = effect
				delay(effect:GetAttribute("EmitDelay"), function()
					v:Emit(v:GetAttribute("EmitCount"))
				end)
			else
				effect:Emit(effect:GetAttribute("EmitCount"))
			end
		else
			effect.Enabled = enabled
		end
	end
end

local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map }
return function(data)
	local player = data.player
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	local stage = data.Stage
	local root = data.Root

	if stage == 1 then
		local holding = data.Holding

		if not (holding and holding.Value) then
			return
		end

		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor", true)
		local v = Util.Sound:Play("EagleFt_F_Hold_01_V1", root)
		local clone = eagleF.Hold:Clone()
		clone.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor", true)
		os.clock()
		local lastTime = os.clock()

		while true do
			if os.clock() - lastTime >= 0.05 then
				lastTime = os.clock()
				task.spawn(function()
					local clone2 = eagleF.Bezier:Clone()
					clone2.Trail.Lifetime = random:NextNumber(0.07, 0.14)
					local position2 = root.Position + Vector3.new(
						random:NextNumber(-20, 20),
						random:NextNumber(-20, 20),
						random:NextNumber(-20, 20)
					)
					local v3 = root.Position + Vector3.new(
						random:NextNumber(-20, 20),
						random:NextNumber(-20, 20),
						random:NextNumber(-20, 20)
					)
					local v4 = root.Position + Vector3.new(
						random:NextNumber(-20, 20),
						random:NextNumber(-20, 20),
						random:NextNumber(-20, 20)
					)
					local position = root.Position
					clone2.Position = position2
					Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor", true)
					Util.SyncColorsOnChange(clone2, player, "EagleFruitVFXColor", true)

					for i = 0, 1, 0.1 do
						local v5 = position2 + (v3 - position2) * i
						local v6 = v3 + (v4 - v3) * i
						local v7 = v4 + (position - v4) * i
						local v8 = v5 + (v6 - v5) * i
						clone2.Position = v8 + (v6 + (v7 - v6) * i - v8) * i
						task.wait(0.015)
					end
				end)
			end

			task.wait()

			if holding:IsDescendantOf(workspace) and holding.Value then
				continue
			end

			if v then
				Util.Sound:FadeOut(v, 0.2)
			end

			for _, effect in pairs(clone:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			task.wait(5)
			folder:Destroy()
			return
		end
	elseif stage == 2 then
		local folder = Instance.new("Folder")
		folder.Name = "EffectsFolder"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "EagleFruitVFXColor", true)
		Util.Debris:AddItem(folder, 10)
		local boostTime = data.BoostTime
		local GUID = HttpService:GenerateGUID(false)
		local Players = game:GetService("Players")
		local clone

		if player == Players.LocalPlayer then
			clone = eagleF.ScreenEffect:Clone()
			clone.CFrame = root.CFrame
			Util.SetParentOverrideWithColor(clone, folder, player, "EagleFruitVFXColor", true)
			local _ = currentCamera.CFrame.LookVector
			TweenService:Create(currentCamera, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
				FieldOfView = 100
			}):Play()
			RunService:BindToRenderStep("Speed Camera Effect" .. GUID, Enum.RenderPriority.Camera.Value, function()
				clone.CFrame = currentCamera.CFrame
			end)
		else
			clone = nil
		end

		local clone2 = eagleF.Explosion2:Clone()
		clone2.Position = root.Position
		Util.SetParentOverrideWithColor(clone2, folder, player, "EagleFruitVFXColor", true)
		ParticleState(clone2)
		local parent = root.Parent
		local Players2 = game:GetService("Players")

		if parent == Players2.LocalPlayer.Character then
			Util.CameraShaker:ShakeOnce(10, 14, 0.1, 0.25)
		end

		Util.Sound:Play("EagleFt_F_Launch_03_V1", root)
		local clone3 = eagleF.Wind:Clone()
		clone3.Weld.Part0 = root
		Util.SetParentOverrideWithColor(clone3, folder, player, "EagleFruitVFXColor", true)
		Util.SyncColorsOnChange(clone3, player, "EagleFruitVFXColor", true)

		for _, effect in pairs(clone3:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = true
			end
		end

		task.delay(boostTime, function()
			if clone then
				RunService:UnbindFromRenderStep("Speed Camera Effect" .. GUID)
				local folder2 = clone

				for _, effect in pairs(folder2:GetDescendants()) do
					if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
						effect.Enabled = false
					end
				end

				TweenService:Create(currentCamera, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
					FieldOfView = 70
				}):Play()
			end

			local folder2 = clone3

			for _, effect in pairs(folder2:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end
		end)
	end
end