local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
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

local function hit(player, _, _, enemyHrp, stage)
	if not (enemyHrp and enemyHrp:IsDescendantOf(Workspace)) then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	if (enemyHrp.Position - currentCamera.CFrame.Position).Magnitude > 400 then
		return
	end

	if stage == 1 then
		Util.Sound:Play("CTTeleport", enemyHrp, 100, 1 + math.random(-15, -10) / 100, 9)
		local clone = FX:WaitForChild("TigerEffects").M1s.m1_1.M1Swipe:Clone()
		Util.SetParentOverrideWithColor(clone, enemyHrp, player, "LeopardFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 1)
		local clone2 = FX:WaitForChild("TigerEffects").M1s.m1_1.third:Clone()
		Util.SetParentOverrideWithColor(clone2, enemyHrp, player, "LeopardFruitVFXColor")
		emitAll(clone2)
		Util.Debris:AddItem(clone2, 1)
		local clone3 = FX:WaitForChild("TigerEffects").M1s.m1_1.SlashL:Clone()
		Util.SetParentOverrideWithColor(clone3, enemyHrp, player, "LeopardFruitVFXColor")
		emitAll(clone3)
		Util.Debris:AddItem(clone3, 1)
		local clone4 = FX:WaitForChild("TigerEffects").M1s.m1_1.SlashL2:Clone()
		Util.SetParentOverrideWithColor(clone4, enemyHrp, player, "LeopardFruitVFXColor")
		emitAll(clone4)
		Util.Debris:AddItem(clone4, 1)
		local clone5 = FX:WaitForChild("TigerEffects").M1s.m1_1.SlashL3:Clone()
		Util.SetParentOverrideWithColor(clone5, enemyHrp, player, "LeopardFruitVFXColor")
		emitAll(clone5)
		Util.Debris:AddItem(clone5, 1)
	elseif stage == 2 then
		Util.Sound:Play("CTTeleport", enemyHrp, 100, 1 + math.random(-10, -5) / 100, 9)
		local clone = FX:WaitForChild("TigerEffects").M1s.m1_1.M1Swipe:Clone()
		Util.SetParentOverrideWithColor(clone, enemyHrp, player, "LeopardFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 1)
		local clone2 = FX:WaitForChild("TigerEffects").M1s.m1_1.third:Clone()
		Util.SetParentOverrideWithColor(clone2, enemyHrp, player, "LeopardFruitVFXColor")
		emitAll(clone2)
		Util.Debris:AddItem(clone2, 1)
		local clone3 = FX:WaitForChild("TigerEffects").M1s.m1_2.SlashR:Clone()
		Util.SetParentOverrideWithColor(clone3, enemyHrp, player, "LeopardFruitVFXColor")
		emitAll(clone3)
		Util.Debris:AddItem(clone3, 1)
		local clone4 = FX:WaitForChild("TigerEffects").M1s.m1_2.SlashR2:Clone()
		Util.SetParentOverrideWithColor(clone4, enemyHrp, player, "LeopardFruitVFXColor")
		emitAll(clone4)
		Util.Debris:AddItem(clone4, 1)
		local clone5 = FX:WaitForChild("TigerEffects").M1s.m1_2.SlashR3:Clone()
		Util.SetParentOverrideWithColor(clone5, enemyHrp, player, "LeopardFruitVFXColor")
		emitAll(clone5)
		Util.Debris:AddItem(clone5, 1)
	elseif stage == 3 then
		Util.Sound:Play("CTTeleport", enemyHrp, 100, 1 + math.random(-5, 5) / 100, 9)
		local clone = FX:WaitForChild("TigerEffects").M1s.m1_1.M1Swipe:Clone()
		Util.SetParentOverrideWithColor(clone, enemyHrp, player, "LeopardFruitVFXColor")
		emitAll(clone)
		Util.Debris:AddItem(clone, 1)
		local clone2 = FX:WaitForChild("TigerEffects").M1s.m1_3.third:Clone()
		Util.SetParentOverrideWithColor(clone2, enemyHrp, player, "LeopardFruitVFXColor")
		emitAll(clone2)
		Util.Debris:AddItem(clone2, 1)
	end
end

return function(data)
	local player = data.player
	local hrp = data.hrp
	local enemyHrp = data.enemyHrp
	local stage = data.stage
	local cf = data.cf

	if (cf.p - Workspace.CurrentCamera.CFrame.p).magnitude > 1000 or not hrp or not hrp.Parent:FindFirstChild("TigerRig") then
		return
	end

	hit(player, hrp, cf, enemyHrp, stage)
end