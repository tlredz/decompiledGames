local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
game:GetService("TweenService")
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))

function ScaleModel(folder, modelScale, p)
	local modelScale2 = folder:GetAttribute("ModelScale")
	local v = modelScale2 == nil and 1 or modelScale2
	local v2 = p or folder:GetPivot().Position
	local v3 = modelScale / v

	for _, part in ipairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local position = part.Position
		local v4 = part.CFrame - position
		local v5 = position - v2
		part.Size *= Vector3.new(v3, v3, v3)
		part.CFrame = v4 + v2 + v5 * v3
	end

	folder:SetAttribute("ModelScale", modelScale)
end

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

local V = FX:WaitForChild("TigerEffects").V
return function(data)
	local player = data.player
	local hrp = data.hrp
	local _ = data.isForTransformation

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	if (hrp.Position - currentCamera.CFrame.Position).Magnitude > 600 then
		return
	end

	if data.Awakened then
		local char = data.char

		for _, attachment in pairs(V.ChargeAwaken:GetChildren()) do
			if not attachment:IsA("Attachment") then
				continue
			end

			local clone = attachment:Clone()
			Util.SetParentOverrideWithColor(clone, hrp, player, "LeopardFruitVFXColor")
			emitAll(clone)
			Util.Debris:AddItem(clone, 2.5)
		end

		local awakeningTimer = data.AwakeningTimer
		local clone = V.UntransformSmoke.Steam1:Clone()
		local clone2 = V.UntransformSmoke.Steam2:Clone()
		local clone3 = V.UntransformSmoke.Attachment:Clone()
		Util.SetParentOverrideWithColor(clone, hrp, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone2, hrp, player, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(clone3, hrp, player, "LeopardFruitVFXColor")
		Util.Debris:AddItem(clone, awakeningTimer + 3)
		Util.Debris:AddItem(clone2, awakeningTimer + 3)
		Util.Debris:AddItem(clone3, awakeningTimer + 3)

		if data.overheating and data.overheating:IsDescendantOf(char) then
			local overheating = data.overheating

			repeat
				task.wait()
			until not (overheating and overheating:IsDescendantOf(Workspace))
		else
			task.wait(awakeningTimer)
		end

		clone.Enabled = false
		clone2.Enabled = false

		for _, emitter in pairs(clone3:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.wait(1.5)
		emitAll(clone3.Emit)
	else
		Util.Sound:Play("TigerPressureKick", hrp, nil, 1 + math.random(-7, 7) / 100, 2)
		Util.Sound:Play("M1Hit3", hrp, nil, 1 + math.random(-7, 7) / 100, 4)

		for _, attachment in pairs(V.Charge:GetChildren()) do
			if not attachment:IsA("Attachment") then
				continue
			end

			local clone = attachment:Clone()
			Util.SetParentOverrideWithColor(clone, hrp, player, "LeopardFruitVFXColor")
			emitAll(clone)
			Util.Debris:AddItem(clone, 2.5)
		end

		for _, attachment in pairs(V.untrhead:GetChildren()) do
			if not attachment:IsA("Attachment") then
				continue
			end

			local clone = attachment:Clone()
			Util.SetParentOverrideWithColor(clone, hrp.Parent:FindFirstChild("Head"), player, "LeopardFruitVFXColor")
			emitAll(clone)
			Util.Debris:AddItem(clone, 2.5)
		end
	end
end