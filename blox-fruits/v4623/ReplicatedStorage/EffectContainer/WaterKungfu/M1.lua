local _ = game.Players.LocalPlayer
local _ = workspace._WorldOrigin
local currentCamera = workspace.CurrentCamera
local Util = require(game.ReplicatedStorage.Util)
game:GetService("TweenService")
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local M1 = FX:WaitForChild("WaterKungfu").M1

local function Emit(emitter)
	if not emitter then
		return
	end

	if emitter:IsA("ParticleEmitter") then
		local emitDelay = emitter:GetAttribute("EmitDelay") or 0
		local emitDuration = emitter:GetAttribute("EmitDuration")
		task.delay(emitDelay, function()
			emitter:Emit(emitter:GetAttribute("EmitCount"))

			if emitDuration then
				emitter.Enabled = true
				task.delay(emitDuration, function()
					emitter.Enabled = false
				end)
			end
		end)
	else
		for _, emitter2 in pairs(emitter:GetDescendants()) do
			if not emitter2:IsA("ParticleEmitter") then
				continue
			end

			local emitDelay = emitter2:GetAttribute("EmitDelay") or 0
			local v = emitter2
			local v2 = emitter2:GetAttribute("EmitDuration")
			task.delay(emitDelay, function()
				v:Emit(v:GetAttribute("EmitCount"))

				if v2 then
					v.Enabled = true
					task.delay(v2, function()
						v.Enabled = false
					end)
				end
			end)
		end
	end
end

local function DisableAllFXs(folder)
	for _, effect in pairs(folder:GetDescendants()) do
		if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
			continue
		end

		effect.Enabled = false
	end
end

return function(player)
	local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local position = humanoidRootPart.Position

	if (currentCamera.CFrame.p - position).Magnitude > 500 then
		return
	end

	local combo = player.Combo
	local character = player.Character

	if not (character and character:FindFirstChild("RightHand")) then
		return
	end

	local folder = Instance.new("Folder", workspace._WorldOrigin)
	Util.Debris:AddItem(folder, 3)

	if combo == 1 or combo == 3 then
		local rightHand = character:FindFirstChild("RightHand")

		if not rightHand then
			return
		end

		Util.Sound:Play("BF_WaterFu_M1_Punch_0" .. tostring(combo), rightHand)
		local clone = M1.FistTrail:Clone()
		clone.CFrame = rightHand.CFrame
		clone.Parent = folder
		task.spawn(function()
			local v = tick() + 0.4

			while tick() < v do
				if rightHand then
					clone.CFrame = rightHand.CFrame
				end

				task.wait()
			end

			DisableAllFXs(clone)
		end)
		task.wait(0.25)
		local clone2 = M1.FistFX.WKF_FistFX:Clone()
		clone2.Parent = rightHand
		Util.Debris:AddItem(clone2, 2)
		Emit(clone2)
	else
		local leftHand = character:FindFirstChild("LeftHand")

		if not leftHand then
			return
		end

		Util.Sound:Play("BF_WaterFu_M1_Punch_0" .. tostring(combo), leftHand)
		local clone = M1.FistTrail:Clone()
		clone.CFrame = leftHand.CFrame
		clone.Parent = folder
		task.spawn(function()
			local v = tick() + 0.4

			while tick() < v do
				if leftHand then
					clone.CFrame = leftHand.CFrame
				end

				task.wait()
			end

			DisableAllFXs(clone)
		end)
		task.wait(0.25)
		local clone2 = M1.FistFX.WKF_FistFX:Clone()
		clone2.Parent = leftHand
		Util.Debris:AddItem(clone2, 2)
		Emit(clone2)
	end
end