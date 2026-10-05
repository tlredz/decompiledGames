local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local TweenService = game:GetService("TweenService")
local sound = Util.Sound
local currentCamera = workspace.CurrentCamera
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local C = FX:WaitForChild("Diamond").C
local _WorldOrigin = workspace._WorldOrigin
local WrapHighlight = require(game.ReplicatedStorage.Util.WrapHighlight)
local random = Random.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }

local function ParticleState(folder, enabled, p)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Trail")) then
			continue
		end

		if p and effect:GetAttribute("Color") == true then
			effect.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		end

		if enabled == nil then
			effect:Emit(effect:GetAttribute("EmitCount"))
		else
			effect.Enabled = enabled
		end
	end
end

return function(data)
	local origin = data.Origin

	if (currentCamera.CFrame.p - origin).Magnitude > 700 then
		return
	end

	local stage = data.Stage
	local player = data.Player

	if stage == 1 then
		local folder = Instance.new("Folder")
		folder.Name = "DiamondBlindHold"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DiamondFruitVFXColor")
		local holding = data.Holding
		local HRP = data.HRP
		local clone = C.Shine:Clone()
		clone.CFrame = HRP.CFrame
		Util.SetParentOverrideWithColor(clone, folder, player, "DiamondFruitVFXColor")
		local v = sound:Play("DIAMOND_ShimmerCharge_Loop_01_V2", origin)
		ParticleState(clone)
		task.spawn(function()
			if holding and holding.Value then
				holding.Changed:Wait()

				if v then
					sound:FadeOut(v, 0.2)
				end
			end
		end)

		if holding then
			task.spawn(function()
				task.wait(0.5)

				if holding.Value then
					local clone2 = C.ReadySignal:Clone()
					clone2.CFrame = HRP.CFrame
					Util.SetParentOverrideWithColor(clone2, folder, player, "DiamondFruitVFXColor")
					clone2.Flare:Emit(4)
					sound:Play("DIAMOND_Shimmer_ChargeMaxIndicator_01", origin)
				end
			end)
		end

		task.spawn(function()
			for _ = 1, 7 do
				task.spawn(function()
					local clone2 = C.Bezier:Clone()
					local position2 = HRP.Position + Vector3.new(
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30)
					)
					local v3 = HRP.Position + Vector3.new(
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30)
					)
					local v4 = HRP.Position + Vector3.new(
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30),
						random:NextNumber(-30, 30)
					)
					local position = HRP.Position
					clone2.Position = position2
					Util.SetParentOverrideWithColor(clone2, folder, player, "DiamondFruitVFXColor")
					local lastTime = tick()

					while tick() - lastTime < 0.1 do
						local v5 = (tick() - lastTime) / 0.1
						local v6 = position2 + (v3 - position2) * v5
						local v7 = v3 + (v4 - v3) * v5
						local v8 = v4 + (position - v4) * v5
						local v9 = v6 + (v7 - v6) * v5
						clone2.Position = v9 + (v7 + (v8 - v7) * v5 - v9) * v5
						task.wait()
					end

					clone2.Position = position
				end)
				task.wait(random:NextNumber(0.015, 0.03))
			end
		end)
		task.wait(0.2)

		for _, effect in pairs(clone:GetDescendants()) do
			if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
				effect.Enabled = false
			end
		end

		task.wait(4)
		folder:Destroy()
	else
		local caughtPlayers = data.CaughtPlayers
		local blindTime = data.BlindTime
		local humanoidRootPart = data.HumanoidRootPart
		local _ = data.Player
		local scaleBuff = data.ScaleBuff
		local v = 1

		if scaleBuff then
			v = scaleBuff >= 0.5 and 2 or v + scaleBuff
		end

		local parent = humanoidRootPart.Parent
		local Players = game:GetService("Players")
		local localPlayer = Players.LocalPlayer
		local folder = Instance.new("Folder")
		folder.Name = "DiamondBlindEffect"
		Util.SetParentOverrideWithColor(folder, _WorldOrigin, player, "DiamondFruitVFXColor")
		local clone = C.Main:Clone()

		if v > 1 then
			Util.ResizeModel(clone, v, origin)
		end

		clone.Weld.Part0 = humanoidRootPart
		Util.SetParentOverrideWithColor(clone, folder, player, "DiamondFruitVFXColor")
		ParticleState(clone)
		sound:Play("DIAMOND_DiamondShimmerExplosion_01", clone.Position)
		local clone2 = WrapHighlight(C.Highlight):Clone()
		Util.SetParentOverrideWithColor(clone2, parent, player, "DiamondFruitVFXColor")
		TweenService:Create(clone2, TweenInfo.new(blindTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			FillTransparency = 1
		}):Play()
		task.delay(blindTime, clone2.Destroy, clone2)

		if caughtPlayers[localPlayer.Name] then
			local clone3 = C.Screen:Clone()
			clone3.CFrame = workspace.CurrentCamera.CFrame

			for _, emitter in clone3:GetDescendants() do
				if emitter:IsA("ParticleEmitter") and emitter.Name == "Blur" then
					emitter.Lifetime = NumberRange.new(blindTime + 1, blindTime + 1)
				end
			end

			Util.SetParentOverrideWithColor(clone3, folder, player, "DiamondFruitVFXColor")
			ParticleState(clone3)
			local number = Random.new():NextNumber(0, 100000000000000)
			RunService:BindToRenderStep(
				localPlayer.Name .. "Camera Effect" .. number,
				Enum.RenderPriority.Camera.Value,
				function()
					clone3.CFrame = workspace.CurrentCamera.CFrame
				end
			)
			task.wait(blindTime)

			for _, effect in pairs(clone3:GetDescendants()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect.Enabled = false
				end
			end

			task.delay(1, function()
				RunService:UnbindFromRenderStep(localPlayer.Name .. "Camera Effect" .. number)
			end)
		end

		task.wait(3)
		folder:Destroy()
	end
end